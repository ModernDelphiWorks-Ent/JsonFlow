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
unit JsonFlow.Metrics;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  System.DateUtils;

type
  /// <summary>
  /// Estrutura para armazenar dados de uma validação individual
  /// </summary>
  TValidationRecord = record
    Timestamp: TDateTime;
    Success: Boolean;
    ExecutionTime: Int64; // em milissegundos
    SchemaHash: Cardinal;
    ErrorCount: Integer;
  end;

  /// <summary>
  /// Classe para coleta e análise de métricas de validação
  /// Fornece estatísticas detalhadas sobre performance e uso
  /// </summary>
  TValidationMetrics = class
  private
    FLock: TCriticalSection;
    FValidationHistory: TList<TValidationRecord>;
    FTotalValidations: Int64;
    FSuccessfulValidations: Int64;
    FFailedValidations: Int64;
    FTotalExecutionTime: Int64;
    FCacheHits: Int64;
    FCacheMisses: Int64;
    FMaxHistorySize: Integer;
    FStartTime: TDateTime;
    
    procedure CleanupOldRecords;
    function CalculatePercentile(const AValues: TArray<Int64>; APercentile: Double): Int64;
  public
    constructor Create;
    destructor Destroy; override;
    
    /// <summary>
    /// Registra uma validação executada
    /// </summary>
    procedure RecordValidation(ASuccess: Boolean; AExecutionTime: Int64; 
      ASchemaHash: Cardinal = 0; AErrorCount: Integer = 0);
    
    /// <summary>
    /// Registra um acerto no cache
    /// </summary>
    procedure RecordCacheHit;
    
    /// <summary>
    /// Registra uma falha no cache
    /// </summary>
    procedure RecordCacheMiss;
    
    /// <summary>
    /// Reseta todas as métricas
    /// </summary>
    procedure Reset;
    
    /// <summary>
    /// Retorna a taxa de sucesso das validações (0-100)
    /// </summary>
    function GetSuccessRate: Double;
    
    /// <summary>
    /// Retorna a taxa de acerto do cache (0-100)
    /// </summary>
    function GetCacheHitRate: Double;
    
    /// <summary>
    /// Retorna o tempo médio de execução em milissegundos
    /// </summary>
    function GetAverageExecutionTime: Double;
    
    /// <summary>
    /// Retorna o tempo mediano de execução em milissegundos
    /// </summary>
    function GetMedianExecutionTime: Int64;
    
    /// <summary>
    /// Retorna o percentil 95 do tempo de execução
    /// </summary>
    function GetP95ExecutionTime: Int64;
    
    /// <summary>
    /// Retorna o número de validações por segundo
    /// </summary>
    function GetValidationsPerSecond: Double;
    
    /// <summary>
    /// Retorna estatísticas dos últimos N minutos
    /// </summary>
    function GetRecentStats(AMinutes: Integer): string;
    
    /// <summary>
    /// Gera um relatório completo das métricas
    /// </summary>
    function GenerateReport: string;
    
    /// <summary>
    /// Gera relatório em formato JSON
    /// </summary>
    function GenerateJSONReport: string;
    
    /// <summary>
    /// Exporta métricas para arquivo CSV
    /// </summary>
    procedure ExportToCSV(const AFileName: string);
    
    // Propriedades somente leitura
    property TotalValidations: Int64 read FTotalValidations;
    property SuccessfulValidations: Int64 read FSuccessfulValidations;
    property FailedValidations: Int64 read FFailedValidations;
    property CacheHits: Int64 read FCacheHits;
    property CacheMisses: Int64 read FCacheMisses;
    property MaxHistorySize: Integer read FMaxHistorySize write FMaxHistorySize;
  end;

  /// <summary>
  /// Singleton para acesso global às métricas
  /// </summary>
  TGlobalMetrics = class
  private
    class var FInstance: TValidationMetrics;
    class var FLock: TCriticalSection;
  public
    class function Instance: TValidationMetrics;
    class procedure FreeInstance;
  end;

implementation

uses
  System.Math,
  System.StrUtils;

{ TValidationMetrics }

constructor TValidationMetrics.Create;
begin
  inherited;
  FLock := TCriticalSection.Create;
  FValidationHistory := TList<TValidationRecord>.Create;
  FMaxHistorySize := 10000; // Manter últimas 10k validações
  FStartTime := Now;
  Reset;
end;

destructor TValidationMetrics.Destroy;
begin
  FValidationHistory.Free;
  FLock.Free;
  inherited;
end;

procedure TValidationMetrics.RecordValidation(ASuccess: Boolean; AExecutionTime: Int64;
  ASchemaHash: Cardinal; AErrorCount: Integer);
var
  LRecord: TValidationRecord;
begin
  FLock.Enter;
  try
    Inc(FTotalValidations);
    Inc(FTotalExecutionTime, AExecutionTime);
    
    if ASuccess then
      Inc(FSuccessfulValidations)
    else
      Inc(FFailedValidations);
    
    // Adicionar ao histórico
    LRecord.Timestamp := Now;
    LRecord.Success := ASuccess;
    LRecord.ExecutionTime := AExecutionTime;
    LRecord.SchemaHash := ASchemaHash;
    LRecord.ErrorCount := AErrorCount;
    
    FValidationHistory.Add(LRecord);
    
    // Limpar registros antigos se necessário
    CleanupOldRecords;
  finally
    FLock.Leave;
  end;
end;

procedure TValidationMetrics.RecordCacheHit;
begin
  FLock.Enter;
  try
    Inc(FCacheHits);
  finally
    FLock.Leave;
  end;
end;

procedure TValidationMetrics.RecordCacheMiss;
begin
  FLock.Enter;
  try
    Inc(FCacheMisses);
  finally
    FLock.Leave;
  end;
end;

procedure TValidationMetrics.Reset;
begin
  FLock.Enter;
  try
    FTotalValidations := 0;
    FSuccessfulValidations := 0;
    FFailedValidations := 0;
    FTotalExecutionTime := 0;
    FCacheHits := 0;
    FCacheMisses := 0;
    FValidationHistory.Clear;
    FStartTime := Now;
  finally
    FLock.Leave;
  end;
end;

function TValidationMetrics.GetSuccessRate: Double;
begin
  FLock.Enter;
  try
    if FTotalValidations = 0 then
      Result := 0
    else
      Result := (FSuccessfulValidations / FTotalValidations) * 100;
  finally
    FLock.Leave;
  end;
end;

function TValidationMetrics.GetCacheHitRate: Double;
var
  LTotalCacheAccess: Int64;
begin
  FLock.Enter;
  try
    LTotalCacheAccess := FCacheHits + FCacheMisses;
    if LTotalCacheAccess = 0 then
      Result := 0
    else
      Result := (FCacheHits / LTotalCacheAccess) * 100;
  finally
    FLock.Leave;
  end;
end;

function TValidationMetrics.GetAverageExecutionTime: Double;
begin
  FLock.Enter;
  try
    if FTotalValidations = 0 then
      Result := 0
    else
      Result := FTotalExecutionTime / FTotalValidations;
  finally
    FLock.Leave;
  end;
end;

function TValidationMetrics.GetMedianExecutionTime: Int64;
var
  LTimes: TArray<Int64>;
  I: Integer;
begin
  FLock.Enter;
  try
    SetLength(LTimes, FValidationHistory.Count);
    for I := 0 to FValidationHistory.Count - 1 do
      LTimes[I] := FValidationHistory[I].ExecutionTime;
    
    if Length(LTimes) = 0 then
      Result := 0
    else
      Result := CalculatePercentile(LTimes, 50.0);
  finally
    FLock.Leave;
  end;
end;

function TValidationMetrics.GetP95ExecutionTime: Int64;
var
  LTimes: TArray<Int64>;
  I: Integer;
begin
  FLock.Enter;
  try
    SetLength(LTimes, FValidationHistory.Count);
    for I := 0 to FValidationHistory.Count - 1 do
      LTimes[I] := FValidationHistory[I].ExecutionTime;
    
    if Length(LTimes) = 0 then
      Result := 0
    else
      Result := CalculatePercentile(LTimes, 95.0);
  finally
    FLock.Leave;
  end;
end;

function TValidationMetrics.GetValidationsPerSecond: Double;
var
  LElapsedSeconds: Double;
begin
  FLock.Enter;
  try
    LElapsedSeconds := SecondsBetween(Now, FStartTime);
    if LElapsedSeconds = 0 then
      Result := 0
    else
      Result := FTotalValidations / LElapsedSeconds;
  finally
    FLock.Leave;
  end;
end;

function TValidationMetrics.GetRecentStats(AMinutes: Integer): string;
var
  LCutoffTime: TDateTime;
  LRecentValidations: Integer;
  LRecentSuccesses: Integer;
  LRecentTime: Int64;
  I: Integer;
begin
  FLock.Enter;
  try
    LCutoffTime := IncMinute(Now, -AMinutes);
    LRecentValidations := 0;
    LRecentSuccesses := 0;
    LRecentTime := 0;
    
    for I := FValidationHistory.Count - 1 downto 0 do
    begin
      if FValidationHistory[I].Timestamp < LCutoffTime then
        Break;
        
      Inc(LRecentValidations);
      Inc(LRecentTime, FValidationHistory[I].ExecutionTime);
      if FValidationHistory[I].Success then
        Inc(LRecentSuccesses);
    end;
    
    Result := Format('Últimos %d minutos: %d validações, %.1f%% sucesso, %.1fms tempo médio',
      [AMinutes, LRecentValidations, 
       IfThen(LRecentValidations > 0, (LRecentSuccesses / LRecentValidations) * 100, 0),
       IfThen(LRecentValidations > 0, LRecentTime / LRecentValidations, 0)]);
  finally
    FLock.Leave;
  end;
end;

function TValidationMetrics.GenerateReport: string;
var
  LBuilder: TStringBuilder;
  LUptime: Double;
begin
  FLock.Enter;
  try
    LBuilder := TStringBuilder.Create;
    try
      LUptime := SecondsBetween(Now, FStartTime);
      
      LBuilder.AppendLine('=== RELATÓRIO DE MÉTRICAS DE VALIDAÇÃO ===');
      LBuilder.AppendLine('');
      LBuilder.AppendLine('ESTATÍSTICAS GERAIS:');
      LBuilder.AppendFormat('  Total de validações: %d', [FTotalValidations]).AppendLine;
      LBuilder.AppendFormat('  Validações bem-sucedidas: %d', [FSuccessfulValidations]).AppendLine;
      LBuilder.AppendFormat('  Validações com falha: %d', [FFailedValidations]).AppendLine;
      LBuilder.AppendFormat('  Taxa de sucesso: %.2f%%', [GetSuccessRate]).AppendLine;
      LBuilder.AppendLine('');
      
      LBuilder.AppendLine('PERFORMANCE:');
      LBuilder.AppendFormat('  Tempo médio de execução: %.2fms', [GetAverageExecutionTime]).AppendLine;
      LBuilder.AppendFormat('  Tempo mediano: %dms', [GetMedianExecutionTime]).AppendLine;
      LBuilder.AppendFormat('  P95 tempo de execução: %dms', [GetP95ExecutionTime]).AppendLine;
      LBuilder.AppendFormat('  Validações por segundo: %.2f', [GetValidationsPerSecond]).AppendLine;
      LBuilder.AppendLine('');
      
      LBuilder.AppendLine('CACHE:');
      LBuilder.AppendFormat('  Cache hits: %d', [FCacheHits]).AppendLine;
      LBuilder.AppendFormat('  Cache misses: %d', [FCacheMisses]).AppendLine;
      LBuilder.AppendFormat('  Taxa de acerto do cache: %.2f%%', [GetCacheHitRate]).AppendLine;
      LBuilder.AppendLine('');
      
      LBuilder.AppendLine('SISTEMA:');
      LBuilder.AppendFormat('  Tempo de atividade: %.0f segundos', [LUptime]).AppendLine;
      LBuilder.AppendFormat('  Registros no histórico: %d', [FValidationHistory.Count]).AppendLine;
      LBuilder.AppendFormat('  Limite do histórico: %d', [FMaxHistorySize]).AppendLine;
      
      Result := LBuilder.ToString;
    finally
      LBuilder.Free;
    end;
  finally
    FLock.Leave;
  end;
end;

function TValidationMetrics.GenerateJSONReport: string;
begin
  FLock.Enter;
  try
    Result := Format('{' +
                     '  "totalValidations": %d,' + '  "successfulValidations": %d,' +
                     '  "failedValidations": %d,' + '  "successRate": %.2f,' +
                     '  "averageExecutionTime": %.2f,' + '  "medianExecutionTime": %d,' +
                     '  "p95ExecutionTime": %d,' + '  "validationsPerSecond": %.2f,' +
                     '  "cacheHits": %d,' + '  "cacheMisses": %d,' + '  "cacheHitRate": %.2f,' +
                     '  "historySize": %d,' + '  "uptime": %.0f' + '}',
      [FTotalValidations, FSuccessfulValidations, FFailedValidations,
       GetSuccessRate, GetAverageExecutionTime, GetMedianExecutionTime,
       GetP95ExecutionTime, GetValidationsPerSecond, FCacheHits, FCacheMisses,
       GetCacheHitRate, FValidationHistory.Count, SecondsBetween(Now, FStartTime)]);
  finally
    FLock.Leave;
  end;
end;

procedure TValidationMetrics.ExportToCSV(const AFileName: string);
var
  LFile: TextFile;
  I: Integer;
  LRecord: TValidationRecord;
begin
  FLock.Enter;
  try
    AssignFile(LFile, AFileName);
    Rewrite(LFile);
    try
      // Cabeçalho
      Writeln(LFile, 'Timestamp,Success,ExecutionTime,SchemaHash,ErrorCount');
      
      // Dados
      for I := 0 to FValidationHistory.Count - 1 do
      begin
        LRecord := FValidationHistory[I];
        Writeln(LFile, Format('%s,%s,%d,%d,%d',
          [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', LRecord.Timestamp),
           BoolToStr(LRecord.Success, True),
           LRecord.ExecutionTime,
           LRecord.SchemaHash,
           LRecord.ErrorCount]));
      end;
    finally
      CloseFile(LFile);
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TValidationMetrics.CleanupOldRecords;
begin
  while FValidationHistory.Count > FMaxHistorySize do
    FValidationHistory.Delete(0);
end;

function TValidationMetrics.CalculatePercentile(const AValues: TArray<Int64>; APercentile: Double): Int64;
var
  LSortedValues: TArray<Int64>;
  LIndex: Integer;
begin
  if Length(AValues) = 0 then
  begin
    Result := 0;
    Exit;
  end;
  
  LSortedValues := Copy(AValues);
  TArray.Sort<Int64>(LSortedValues);
  
  LIndex := Trunc((APercentile / 100.0) * (Length(LSortedValues) - 1));
  LIndex := Max(0, Min(LIndex, Length(LSortedValues) - 1));
  
  Result := LSortedValues[LIndex];
end;

{ TGlobalMetrics }

class function TGlobalMetrics.Instance: TValidationMetrics;
begin
  if not Assigned(FInstance) then
  begin
    if not Assigned(FLock) then
      FLock := TCriticalSection.Create;
      
    FLock.Enter;
    try
      if not Assigned(FInstance) then
        FInstance := TValidationMetrics.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstance;
end;

class procedure TGlobalMetrics.FreeInstance;
begin
  if Assigned(FLock) then
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
    FLock.Free;
    FLock := nil;
  end;
end;

initialization

finalization
  TGlobalMetrics.FreeInstance;

end.