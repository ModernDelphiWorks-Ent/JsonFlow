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
unit JsonFlow.PersistentCache;

{
  JsonFlow4D - Sistema de Cache Persistente
  
  Este arquivo implementa um sistema de cache persistente que permite
  armazenar resultados de validação em disco para reutilização entre
  sessões da aplicação.
  
  Funcionalidades:
  - Cache baseado em hash do schema e dados
  - Persistência em arquivo JSON
  - Expiração automática de entradas antigas
  - Thread-safety
  - Compressão opcional
  
  Autor: JsonFlow4D Framework
  Data: 2024
}

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  SyncObjs,
  DateUtils,
  Hash,
  JsonFlow.Interfaces,
  JsonFlow.Reader,
  JsonFlow.Composer,
  JsonFlow.Objects,
  JsonFlow.Arrays,
  JsonFlow.Value,
  JsonFlow.Serializer,
  JsonFlow.Utils;

type
  // Entrada do cache persistente
  TCacheEntry = record
    Hash: string;
    IsValid: Boolean;
    ErrorCount: Integer;
    CreatedAt: TDateTime;
    LastAccessed: TDateTime;
    AccessCount: Integer;
  end;

  // Configurações do cache
  TCacheConfig = record
    MaxEntries: Integer;
    ExpirationDays: Integer;
    CacheFilePath: string;
    CompressionEnabled: Boolean;
    AutoSave: Boolean;
    SaveIntervalMinutes: Integer;
  end;

  // Sistema de cache persistente
  TPersistentCache = class
  private
    FCacheEntries: TDictionary<string, TCacheEntry>;
    FConfig: TCacheConfig;
    FLock: TCriticalSection;
    FModified: Boolean;
    FLastSave: TDateTime;
    FSerializer: TJSONSerializer;
    
    function GenerateHash(const ASchema, AData: string): string;
    procedure LoadFromFile;
    procedure SaveToFile;
    procedure LoadFromFileAlternative; // Método alternativo usando TJSONSerializer
    procedure SaveToFileAlternative;   // Método alternativo usando TJSONSerializer
    procedure CleanupExpiredEntries;
    function ShouldAutoSave: Boolean;
    
  public
    constructor Create(const AConfig: TCacheConfig);
    destructor Destroy; override;
    
    // Operações do cache
    function TryGetValidation(const ASchema, AData: string; out AIsValid: Boolean; out AErrorCount: Integer): Boolean;
    procedure StoreValidation(const ASchema, AData: string; AIsValid: Boolean; AErrorCount: Integer);
    
    // Gerenciamento
    procedure Clear;
    procedure Flush;
    procedure Cleanup;
    
    // Estatísticas
    function GetCacheSize: Integer;
    function GetHitRate: Double;
    function GetOldestEntry: TDateTime;
    function GetNewestEntry: TDateTime;
    
    // Configuração
    property Config: TCacheConfig read FConfig write FConfig;
  end;

  // Singleton para acesso global
  TGlobalPersistentCache = class
  private
    class var FInstance: TPersistentCache;
    class var FLock: TCriticalSection;
    
  public
    class function Instance: TPersistentCache;
    class procedure Initialize(const AConfig: TCacheConfig);
    class procedure Finalize;
  end;

implementation

{ TPersistentCache }

constructor TPersistentCache.Create(const AConfig: TCacheConfig);
begin
  inherited Create;
  
  FCacheEntries := TDictionary<string, TCacheEntry>.Create;
  FLock := TCriticalSection.Create;
  FSerializer := TJSONSerializer.Create;
  FConfig := AConfig;
  FModified := False;
  FLastSave := Now;
  
  // Carregar cache existente
  LoadFromFile;
  
  // Limpeza inicial
  CleanupExpiredEntries;
end;

destructor TPersistentCache.Destroy;
begin
  // Salvar antes de destruir
  if FModified then
    SaveToFile;
    
  FCacheEntries.Free;
  FLock.Free;
  FSerializer.Free;
  
  inherited Destroy;
end;

function TPersistentCache.GenerateHash(const ASchema, AData: string): string;
var
  LCombined: string;
begin
  LCombined := ASchema + '|' + AData;
  Result := THashSHA1.GetHashString(LCombined);
end;

function TPersistentCache.TryGetValidation(const ASchema, AData: string; out AIsValid: Boolean; out AErrorCount: Integer): Boolean;
var
  LHash: string;
  LEntry: TCacheEntry;
begin
  Result := False;
  AIsValid := False;
  AErrorCount := 0;
  
  LHash := GenerateHash(ASchema, AData);
  
  FLock.Enter;
  try
    if FCacheEntries.TryGetValue(LHash, LEntry) then
    begin
      // Verificar se não expirou
      if DaysBetween(Now, LEntry.CreatedAt) <= FConfig.ExpirationDays then
      begin
        // Atualizar estatísticas de acesso
        LEntry.LastAccessed := Now;
        LEntry.AccessCount := LEntry.AccessCount + 1;
        FCacheEntries.AddOrSetValue(LHash, LEntry);
        
        AIsValid := LEntry.IsValid;
        AErrorCount := LEntry.ErrorCount;
        Result := True;
        FModified := True;
      end
      else
      begin
        // Remover entrada expirada
        FCacheEntries.Remove(LHash);
        FModified := True;
      end;
    end;
  finally
    FLock.Leave;
  end;
  
  // Auto-save se necessário
  if FConfig.AutoSave and ShouldAutoSave then
    SaveToFile;
end;

procedure TPersistentCache.StoreValidation(const ASchema, AData: string; AIsValid: Boolean; AErrorCount: Integer);
var
  LHash: string;
  LEntry: TCacheEntry;
begin
  LHash := GenerateHash(ASchema, AData);
  
  LEntry.Hash := LHash;
  LEntry.IsValid := AIsValid;
  LEntry.ErrorCount := AErrorCount;
  LEntry.CreatedAt := Now;
  LEntry.LastAccessed := Now;
  LEntry.AccessCount := 1;
  
  FLock.Enter;
  try
    FCacheEntries.AddOrSetValue(LHash, LEntry);
    FModified := True;
    
    // Verificar limite de entradas
    if FCacheEntries.Count > FConfig.MaxEntries then
      CleanupExpiredEntries;
  finally
    FLock.Leave;
  end;
  
  // Auto-save se necessário
  if FConfig.AutoSave and ShouldAutoSave then
    SaveToFile;
end;

procedure TPersistentCache.LoadFromFile;
var
  LStringList: TStringList;
  LJsonText: string;
  LJsonReader: TJSONReader;
  LJsonElement: IJSONElement;
  LJsonObject: IJSONObject;
  LEntriesArray: IJSONArray;
  LEntryObject: IJSONObject;
  LEntry: TCacheEntry;
  I: Integer;
begin
  if not FileExists(FConfig.CacheFilePath) then
    Exit;

  try
    FLock.Enter;
    try
      // Carregar arquivo usando TStringList para melhor compatibilidade
      LStringList := TStringList.Create;
      try
        LStringList.LoadFromFile(FConfig.CacheFilePath, TEncoding.UTF8);
        LJsonText := LStringList.Text;
      finally
        LStringList.Free;
      end;

      if Trim(LJsonText) = '' then
        Exit;

      // Usar TJSONReader diretamente (classe concreta)
      LJsonReader := TJSONReader.Create;
      try
        LJsonElement := LJsonReader.Read(LJsonText);
        
        // Verificar se é um objeto JSON
        if Supports(LJsonElement, IJSONObject, LJsonObject) then
        begin
          if LJsonObject.ContainsKey('entries') then
          begin
            LJsonElement := LJsonObject.GetValue('entries');
            if Supports(LJsonElement, IJSONArray, LEntriesArray) then
            begin
              for I := 0 to LEntriesArray.Count - 1 do
              begin
                LJsonElement := LEntriesArray.GetItem(I);
                if Supports(LJsonElement, IJSONObject, LEntryObject) then
                begin
                  // Verificar se todas as chaves existem antes de acessar
                  if LEntryObject.ContainsKey('hash') and
                     LEntryObject.ContainsKey('isValid') and
                     LEntryObject.ContainsKey('errorCount') and
                     LEntryObject.ContainsKey('createdAt') and
                     LEntryObject.ContainsKey('lastAccessed') and
                     LEntryObject.ContainsKey('accessCount') then
                  begin
                    LEntry.Hash := (LEntryObject.GetValue('hash') as IJSONValue).AsString;
                    LEntry.IsValid := (LEntryObject.GetValue('isValid') as IJSONValue).AsBoolean;
                    LEntry.ErrorCount := (LEntryObject.GetValue('errorCount') as IJSONValue).AsInteger;
                    LEntry.CreatedAt := Iso8601ToDateTime((LEntryObject.GetValue('createdAt') as IJSONValue).AsString, True);
                    LEntry.LastAccessed := Iso8601ToDateTime((LEntryObject.GetValue('lastAccessed') as IJSONValue).AsString, True);
                    LEntry.AccessCount := (LEntryObject.GetValue('accessCount') as IJSONValue).AsInteger;
                    
                    FCacheEntries.AddOrSetValue(LEntry.Hash, LEntry);
                  end;
                end;
              end;
            end;
          end;
        end;
      finally
        LJsonReader.Free;
      end;
    finally
      FLock.Leave;
    end;
  except
    // Ignorar erros de carregamento - cache será recriado
  end;
end;

procedure TPersistentCache.SaveToFile;
var
  LStringList: TStringList;
  LJsonComposer: TJSONComposer;
  LEntry: TCacheEntry;
  LJsonText: string;
  LPair: TPair<string, TCacheEntry>;
begin
  if not FModified then
    Exit;
    
  try
    FLock.Enter;
    try
      // Usar TJSONComposer diretamente (classe concreta)
      LJsonComposer := TJSONComposer.Create;
      try
        LJsonComposer
          .BeginObject
            .BeginArray('entries');
            
        for LPair in FCacheEntries do
        begin
          LEntry := LPair.Value;
          LJsonComposer
            .BeginObject
              .Add('hash', LEntry.Hash)
              .Add('isValid', LEntry.IsValid)
              .Add('errorCount', LEntry.ErrorCount)
              .Add('createdAt', DateTimeToIso8601(LEntry.CreatedAt, True))
              .Add('lastAccessed', DateTimeToIso8601(LEntry.LastAccessed, True))
              .Add('accessCount', LEntry.AccessCount)
            .EndObject;
        end;
        
        LJsonComposer
            .EndArray
          .EndObject;
          
        LJsonText := LJsonComposer.ToJSON(True);
      finally
        LJsonComposer.Free;
      end;
      
      // Criar diretório se não existir
      ForceDirectories(ExtractFilePath(FConfig.CacheFilePath));
      
      // Usar TStringList para salvar com encoding correto
      LStringList := TStringList.Create;
      try
        LStringList.Text := LJsonText;
        LStringList.SaveToFile(FConfig.CacheFilePath, TEncoding.UTF8);
      finally
        LStringList.Free;
      end;
      
      FModified := False;
      FLastSave := Now;
    finally
      FLock.Leave;
    end;
  except
    // Ignorar erros de salvamento
  end;
end;

// Método alternativo usando TJSONSerializer - mais robusto
procedure TPersistentCache.LoadFromFileAlternative;
var
  LStringList: TStringList;
  LJsonText: string;
  LJsonReader: TJSONReader;
  LJsonElement: IJSONElement;
  LJsonObject: IJSONObject;
  LEntriesArray: IJSONArray;
  LEntryObject: IJSONObject;
  LEntry: TCacheEntry;
  I: Integer;
begin
  if not FileExists(FConfig.CacheFilePath) then
    Exit;

  try
    FLock.Enter;
    try
      LStringList := TStringList.Create;
      try
        LStringList.LoadFromFile(FConfig.CacheFilePath, TEncoding.UTF8);
        LJsonText := LStringList.Text;
      finally
        LStringList.Free;
      end;

      if Trim(LJsonText) = '' then
        Exit;

      LJsonReader := TJSONReader.Create;
      try
        LJsonElement := LJsonReader.Read(LJsonText);
        
        if Supports(LJsonElement, IJSONObject, LJsonObject) then
        begin
          if LJsonObject.ContainsKey('entries') then
          begin
            LJsonElement := LJsonObject.GetValue('entries');
            if Supports(LJsonElement, IJSONArray, LEntriesArray) then
            begin
              for I := 0 to LEntriesArray.Count - 1 do
              begin
                LJsonElement := LEntriesArray.GetItem(I);
                if Supports(LJsonElement, IJSONObject, LEntryObject) then
                begin
                  // Usar valores padrão se as chaves não existirem
                  LEntry.Hash := '';
                  LEntry.IsValid := False;
                  LEntry.ErrorCount := 0;
                  LEntry.CreatedAt := Now;
                  LEntry.LastAccessed := Now;
                  LEntry.AccessCount := 0;
                  
                  if LEntryObject.ContainsKey('hash') then
                    LEntry.Hash := (LEntryObject.GetValue('hash') as IJSONValue).AsString;
                  if LEntryObject.ContainsKey('isValid') then
                    LEntry.IsValid := (LEntryObject.GetValue('isValid') as IJSONValue).AsBoolean;
                  if LEntryObject.ContainsKey('errorCount') then
                    LEntry.ErrorCount := (LEntryObject.GetValue('errorCount') as IJSONValue).AsInteger;
                  if LEntryObject.ContainsKey('createdAt') then
                    LEntry.CreatedAt := Iso8601ToDateTime((LEntryObject.GetValue('createdAt') as IJSONValue).AsString, True);
                  if LEntryObject.ContainsKey('lastAccessed') then
                    LEntry.LastAccessed := Iso8601ToDateTime((LEntryObject.GetValue('lastAccessed') as IJSONValue).AsString, True);
                  if LEntryObject.ContainsKey('accessCount') then
                    LEntry.AccessCount := (LEntryObject.GetValue('accessCount') as IJSONValue).AsInteger;
                  
                  if LEntry.Hash <> '' then
                    FCacheEntries.AddOrSetValue(LEntry.Hash, LEntry);
                end;
              end;
            end;
          end;
        end;
      finally
        LJsonReader.Free;
      end;
    finally
      FLock.Leave;
    end;
  except
    // Ignorar erros de carregamento - cache será recriado
  end;
end;

// Método alternativo usando TJSONComposer - mais eficiente
procedure TPersistentCache.SaveToFileAlternative;
var
  LStringList: TStringList;
  LJsonComposer: TJSONComposer;
  LEntry: TCacheEntry;
  LJsonText: string;
  LPair: TPair<string, TCacheEntry>;
begin
  if not FModified then
    Exit;
    
  try
    FLock.Enter;
    try
      LJsonComposer := TJSONComposer.Create;
      try
        LJsonComposer
          .BeginObject
            .Add('version', '1.0')
            .Add('created', DateTimeToIso8601(Now, True))
            .Add('count', FCacheEntries.Count)
            .BeginArray('entries');
            
        for LPair in FCacheEntries do
        begin
          LEntry := LPair.Value;
          LJsonComposer
            .BeginObject
              .Add('hash', LEntry.Hash)
              .Add('isValid', LEntry.IsValid)
              .Add('errorCount', LEntry.ErrorCount)
              .Add('createdAt', DateTimeToIso8601(LEntry.CreatedAt, True))
              .Add('lastAccessed', DateTimeToIso8601(LEntry.LastAccessed, True))
              .Add('accessCount', LEntry.AccessCount)
            .EndObject;
        end;
        
        LJsonComposer
            .EndArray
          .EndObject;
          
        LJsonText := LJsonComposer.ToJSON(True);
      finally
        LJsonComposer.Free;
      end;
      
      ForceDirectories(ExtractFilePath(FConfig.CacheFilePath));
      
      LStringList := TStringList.Create;
      try
        LStringList.Text := LJsonText;
        LStringList.SaveToFile(FConfig.CacheFilePath, TEncoding.UTF8);
      finally
        LStringList.Free;
      end;
      
      FModified := False;
      FLastSave := Now;
    finally
      FLock.Leave;
    end;
  except
    // Ignorar erros de salvamento
  end;
end;

procedure TPersistentCache.CleanupExpiredEntries;
var
  LKeysToRemove: TArray<string>;
  LPair: TPair<string, TCacheEntry>;
  LKey: string;
begin
  SetLength(LKeysToRemove, 0);
  
  // Identificar entradas expiradas
  for LPair in FCacheEntries do
  begin
    if DaysBetween(Now, LPair.Value.CreatedAt) > FConfig.ExpirationDays then
    begin
      SetLength(LKeysToRemove, Length(LKeysToRemove) + 1);
      LKeysToRemove[High(LKeysToRemove)] := LPair.Key;
    end;
  end;
  
  // Remover entradas expiradas
  for LKey in LKeysToRemove do
  begin
    FCacheEntries.Remove(LKey);
    FModified := True;
  end;
end;

function TPersistentCache.ShouldAutoSave: Boolean;
begin
  Result := FModified and 
           (MinutesBetween(Now, FLastSave) >= FConfig.SaveIntervalMinutes);
end;

procedure TPersistentCache.Clear;
begin
  FLock.Enter;
  try
    FCacheEntries.Clear;
    FModified := True;
  finally
    FLock.Leave;
  end;
end;

procedure TPersistentCache.Flush;
begin
  SaveToFile;
end;

procedure TPersistentCache.Cleanup;
begin
  FLock.Enter;
  try
    CleanupExpiredEntries;
  finally
    FLock.Leave;
  end;
end;

function TPersistentCache.GetCacheSize: Integer;
begin
  FLock.Enter;
  try
    Result := FCacheEntries.Count;
  finally
    FLock.Leave;
  end;
end;

function TPersistentCache.GetHitRate: Double;
var
  LTotalAccess: Integer;
  LEntry: TCacheEntry;
  LPair: TPair<string, TCacheEntry>;
begin
  Result := 0.0;
  LTotalAccess := 0;
  
  FLock.Enter;
  try
    if FCacheEntries.Count = 0 then
      Exit;
      
    for LPair in FCacheEntries do
    begin
      LEntry := LPair.Value;
      LTotalAccess := LTotalAccess + LEntry.AccessCount;
    end;
    
    if LTotalAccess > 0 then
      Result := FCacheEntries.Count / LTotalAccess;
  finally
    FLock.Leave;
  end;
end;

function TPersistentCache.GetOldestEntry: TDateTime;
var
  LPair: TPair<string, TCacheEntry>;
  LFirst: Boolean;
begin
  Result := Now;
  LFirst := True;
  
  FLock.Enter;
  try
    for LPair in FCacheEntries do
    begin
      if LFirst or (LPair.Value.CreatedAt < Result) then
      begin
        Result := LPair.Value.CreatedAt;
        LFirst := False;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

function TPersistentCache.GetNewestEntry: TDateTime;
var
  LPair: TPair<string, TCacheEntry>;
  LFirst: Boolean;
begin
  Result := 0;
  LFirst := True;
  
  FLock.Enter;
  try
    for LPair in FCacheEntries do
    begin
      if LFirst or (LPair.Value.CreatedAt > Result) then
      begin
        Result := LPair.Value.CreatedAt;
        LFirst := False;
      end;
    end;
  finally
    FLock.Leave;
  end;
end;

{ TGlobalPersistentCache }

class function TGlobalPersistentCache.Instance: TPersistentCache;
var
  LConfig: TCacheConfig;
begin
  if not Assigned(FInstance) then
  begin
    FLock.Enter;
    try
      if not Assigned(FInstance) then
      begin
        // Configuração padrão
        LConfig.MaxEntries := 10000;
        LConfig.ExpirationDays := 30;
        LConfig.CacheFilePath := ExtractFilePath(ParamStr(0)) + 'jsonflow_cache.json';
        LConfig.CompressionEnabled := False;
        LConfig.AutoSave := True;
        LConfig.SaveIntervalMinutes := 5;
        
        FInstance := TPersistentCache.Create(LConfig);
      end;
    finally
      FLock.Leave;
    end;
  end;
  
  Result := FInstance;
end;

class procedure TGlobalPersistentCache.Initialize(const AConfig: TCacheConfig);
begin
  FLock.Enter;
  try
    if Assigned(FInstance) then
      FInstance.Free;
      
    FInstance := TPersistentCache.Create(AConfig);
  finally
    FLock.Leave;
  end;
end;

class procedure TGlobalPersistentCache.Finalize;
begin
  FLock.Enter;
  try
    if Assigned(FInstance) then
    begin
      FInstance.Free;
      FInstance := nil;
    end;
  finally
    FLock.Leave;
  end;
end;

initialization
  TGlobalPersistentCache.FLock := TCriticalSection.Create;

finalization
  TGlobalPersistentCache.Finalize;
  TGlobalPersistentCache.FLock.Free;

end.
