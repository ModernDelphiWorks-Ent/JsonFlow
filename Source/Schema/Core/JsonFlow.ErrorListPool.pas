{
  ------------------------------------------------------------------------------
  JsonFlow
  Fluent and expressive JSON manipulation API for Delphi.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ../../JsonFlow.inc}
unit JsonFlow.ErrorListPool;

interface

uses
  System.Generics.Collections,
  System.SyncObjs,
  JsonFlow.Objects,
  JsonFlow.Interfaces;

type
  /// <summary>
  /// Pool de listas de erro para otimização de performance
  /// Reutiliza listas ao invés de criar/destruir constantemente
  /// </summary>
  TErrorListPool = class
  private
    class var FInstance: TErrorListPool;
    class var FLockInstance: TCriticalSection;
  private
    FPool: TStack<TList<TValidationError>>;
    FLock: TCriticalSection;
    FMaxPoolSize: Integer;
    FCreatedCount: Integer;
    FReuseCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    class function Instance: TErrorListPool;
    class procedure FreeInstance;
    
    /// <summary>
    /// Obtém uma lista do pool ou cria uma nova se necessário
    /// </summary>
    function GetList: TList<TValidationError>;
    
    /// <summary>
    /// Retorna uma lista para o pool para reutilização
    /// </summary>
    procedure ReturnList(AList: TList<TValidationError>);
    
    /// <summary>
    /// Limpa o pool liberando todas as listas
    /// </summary>
    procedure Clear;
    
    /// <summary>
    /// Retorna estatísticas do pool
    /// </summary>
    procedure GetStats(out APoolSize, ACreatedCount, AReuseCount: Integer);
    
    property MaxPoolSize: Integer read FMaxPoolSize write FMaxPoolSize;
  end;

implementation

uses
  System.SysUtils;

{ TErrorListPool }

constructor TErrorListPool.Create;
begin
  inherited;
  FPool := TStack<TList<TValidationError>>.Create;
  FLock := TCriticalSection.Create;
  FMaxPoolSize := 50; // Limite padrão do pool
  FCreatedCount := 0;
  FReuseCount := 0;
end;

destructor TErrorListPool.Destroy;
begin
  Clear;
  FPool.Free;
  FLock.Free;
  inherited;
end;

class function TErrorListPool.Instance: TErrorListPool;
begin
  if not Assigned(FInstance) then
  begin
    if not Assigned(FLockInstance) then
      FLockInstance := TCriticalSection.Create;
      
    FLockInstance.Enter;
    try
      if not Assigned(FInstance) then
        FInstance := TErrorListPool.Create;
    finally
      FLockInstance.Leave;
    end;
  end;
  Result := FInstance;
end;

class procedure TErrorListPool.FreeInstance;
begin
  if Assigned(FLockInstance) then
  begin
    FLockInstance.Enter;
    try
      if Assigned(FInstance) then
      begin
        FInstance.Free;
        FInstance := nil;
      end;
    finally
      FLockInstance.Leave;
    end;
    FLockInstance.Free;
    FLockInstance := nil;
  end;
end;

function TErrorListPool.GetList: TList<TValidationError>;
begin
  FLock.Enter;
  try
    if FPool.Count > 0 then
    begin
      Result := FPool.Pop;
      Inc(FReuseCount);
    end
    else
    begin
      Result := TList<TValidationError>.Create;
      Inc(FCreatedCount);
    end;
    
    // Garantir que a lista está limpa
    Result.Clear;
  finally
    FLock.Leave;
  end;
end;

procedure TErrorListPool.ReturnList(AList: TList<TValidationError>);
begin
  if not Assigned(AList) then
    Exit;
    
  FLock.Enter;
  try
    // Limpar a lista antes de retornar ao pool
    AList.Clear;
    
    // Adicionar ao pool apenas se não exceder o limite
    if FPool.Count < FMaxPoolSize then
      FPool.Push(AList)
    else
      AList.Free; // Liberar se o pool estiver cheio
  finally
    FLock.Leave;
  end;
end;

procedure TErrorListPool.Clear;
var
  LList: TList<TValidationError>;
begin
  FLock.Enter;
  try
    while FPool.Count > 0 do
    begin
      LList := FPool.Pop;
      LList.Free;
    end;
    FCreatedCount := 0;
    FReuseCount := 0;
  finally
    FLock.Leave;
  end;
end;

procedure TErrorListPool.GetStats(out APoolSize, ACreatedCount, AReuseCount: Integer);
begin
  FLock.Enter;
  try
    APoolSize := FPool.Count;
    ACreatedCount := FCreatedCount;
    AReuseCount := FReuseCount;
  finally
    FLock.Leave;
  end;
end;

initialization
  TErrorListPool.FLockInstance := TCriticalSection.Create;

finalization
  try
    TErrorListPool.FreeInstance;
  except
    // Ignora erros durante finalização para evitar access violations
  end;

end.
