program AdvancedFeaturesDemo;

{
  JsonFlow4D - Demonstração de Funcionalidades Avançadas
  
  Este programa demonstra o uso das funcionalidades extras implementadas
  na Fase 4 do JsonFlow4D, incluindo:
  
  - Sistema de métricas avançadas
  - Cache persistente
  - Validação assíncrona
  - Geração de relatórios
  - Otimizações de performance
  
  Autor: JsonFlow4D Framework
  Data: 2024
}

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Threading,
  System.Diagnostics,
  System.DateUtils,
  System.Generics.Collections,
  System.Math,
  System.StrUtils;

// Simulação das classes principais (para compilação independente)
type
  TLogLevel = (llDebug, llInfo, llWarning, llError);
  
  TValidationError = class
  private
    FMessage: string;
    FPath: string;
    FErrorType: string;
  public
    constructor Create(const AMessage, APath, AErrorType: string);
    property Message: string read FMessage;
    property Path: string read FPath;
    property ErrorType: string read FErrorType;
  end;
  
  // Simulação do sistema de métricas
  TValidationRecord = record
    Path: string;
    StartTime: TDateTime;
    EndTime: TDateTime;
    Success: Boolean;
    ErrorCount: Integer;
    CacheHit: Boolean;
  end;
  
  TValidationMetrics = class
  private
    FRecords: TList<TValidationRecord>;
    FTotalValidations: Integer;
    FSuccessfulValidations: Integer;
    FCacheHits: Integer;
    FTotalTime: Double;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure RecordValidation(const ARecord: TValidationRecord);
    function GetSuccessRate: Double;
    function GetAverageTime: Double;
    function GetCacheHitRate: Double;
    function GenerateTextReport: string;
    function GenerateJsonReport: string;
    
    property TotalValidations: Integer read FTotalValidations;
    property SuccessfulValidations: Integer read FSuccessfulValidations;
    property CacheHits: Integer read FCacheHits;
  end;
  
  // Simulação do cache persistente
  TCacheConfig = record
    MaxEntries: Integer;
    ExpirationDays: Integer;
    CacheFilePath: string;
    CompressionEnabled: Boolean;
    AutoSave: Boolean;
    SaveIntervalMinutes: Integer;
  end;
  
  TPersistentCache = class
  private
    FConfig: TCacheConfig;
    FCacheData: TDictionary<string, Boolean>;
    FHitCount: Integer;
    FMissCount: Integer;
  public
    constructor Create(const AConfig: TCacheConfig);
    destructor Destroy; override;
    
    function TryGetValidation(const ASchema, AData: string; out AIsValid: Boolean; out AErrorCount: Integer): Boolean;
    procedure StoreValidation(const ASchema, AData: string; AIsValid: Boolean; AErrorCount: Integer);
    function GetHitRate: Double;
    function GetCacheSize: Integer;
    procedure Clear;
  end;
  
  // Simulação do validador assíncrono
  TValidationPriority = (vpLow, vpNormal, vpHigh, vpCritical);
  TAsyncValidationStatus = (avsQueued, avsRunning, avsCompleted, avsCancelled, avsError);
  
  TAsyncValidationResult = record
    TaskId: string;
    Status: TAsyncValidationStatus;
    IsValid: Boolean;
    ErrorCount: Integer;
    StartTime: TDateTime;
    EndTime: TDateTime;
    ErrorMessage: string;
  end;
  
  TValidationCompletedCallback = procedure(const AResult: TAsyncValidationResult) of object;
  
  TAsyncValidator = class
  private
    FTaskCounter: Integer;
    FCompletedTasks: TDictionary<string, TAsyncValidationResult>;
  public
    constructor Create;
    destructor Destroy; override;
    
    function SubmitValidation(const AJsonData: string; const ASchema: string;
                             APriority: TValidationPriority = vpNormal;
                             ACompletedCallback: TValidationCompletedCallback = nil): string;
    function GetTaskResult(const ATaskId: string): TAsyncValidationResult;
    function WaitForTask(const ATaskId: string; ATimeoutMs: Integer = 5000): Boolean;
  end;
  
  // Simulação do gerador de relatórios
  TReportType = (rtValidationSummary, rtPerformanceAnalysis, rtErrorAnalysis);
  TReportFormat = (rfHTML, rfJSON, rfCSV);
  
  TReportConfig = record
    ReportType: TReportType;
    Format: TReportFormat;
    Title: string;
    Author: string;
    OutputPath: string;
  end;
  
  TReportGenerator = class
  private
    FMetrics: TValidationMetrics;
  public
    constructor Create(AMetrics: TValidationMetrics);
    function GenerateReport(const AConfig: TReportConfig): string;
  end;

// Implementações das classes simuladas

{ TValidationError }

constructor TValidationError.Create(const AMessage, APath, AErrorType: string);
begin
  inherited Create;
  FMessage := AMessage;
  FPath := APath;
  FErrorType := AErrorType;
end;

{ TValidationMetrics }

constructor TValidationMetrics.Create;
begin
  inherited Create;
  FRecords := TList<TValidationRecord>.Create;
  FTotalValidations := 0;
  FSuccessfulValidations := 0;
  FCacheHits := 0;
  FTotalTime := 0;
end;

destructor TValidationMetrics.Destroy;
begin
  FRecords.Free;
  inherited Destroy;
end;

procedure TValidationMetrics.RecordValidation(const ARecord: TValidationRecord);
var
  LDuration: Double;
begin
  FRecords.Add(ARecord);
  Inc(FTotalValidations);
  
  if ARecord.Success then
    Inc(FSuccessfulValidations);
    
  if ARecord.CacheHit then
    Inc(FCacheHits);
    
  LDuration := MilliSecondsBetween(ARecord.EndTime, ARecord.StartTime);
  FTotalTime := FTotalTime + LDuration;
end;

function TValidationMetrics.GetSuccessRate: Double;
begin
  if FTotalValidations > 0 then
    Result := FSuccessfulValidations / FTotalValidations
  else
    Result := 0;
end;

function TValidationMetrics.GetAverageTime: Double;
begin
  if FTotalValidations > 0 then
    Result := FTotalTime / FTotalValidations
  else
    Result := 0;
end;

function TValidationMetrics.GetCacheHitRate: Double;
begin
  if FTotalValidations > 0 then
    Result := FCacheHits / FTotalValidations
  else
    Result := 0;
end;

function TValidationMetrics.GenerateTextReport: string;
begin
  Result := Format(
    'Relatório de Métricas de Validação' + sLineBreak +
    '===================================' + sLineBreak +
    'Total de Validações: %d' + sLineBreak +
    'Validações Bem-sucedidas: %d' + sLineBreak +
    'Taxa de Sucesso: %.2f%%' + sLineBreak +
    'Cache Hits: %d' + sLineBreak +
    'Taxa de Cache Hit: %.2f%%' + sLineBreak +
    'Tempo Médio: %.2f ms' + sLineBreak,
    [FTotalValidations, FSuccessfulValidations, GetSuccessRate * 100,
     FCacheHits, GetCacheHitRate * 100, GetAverageTime]);
end;

function TValidationMetrics.GenerateJsonReport: string;
var
  LJson: TJSONObject;
begin
  LJson := TJSONObject.Create;
  try
    LJson.AddPair('total_validations', TJSONNumber.Create(FTotalValidations));
    LJson.AddPair('successful_validations', TJSONNumber.Create(FSuccessfulValidations));
    LJson.AddPair('success_rate', TJSONNumber.Create(GetSuccessRate));
    LJson.AddPair('cache_hits', TJSONNumber.Create(FCacheHits));
    LJson.AddPair('cache_hit_rate', TJSONNumber.Create(GetCacheHitRate));
    LJson.AddPair('average_time_ms', TJSONNumber.Create(GetAverageTime));
    
    Result := LJson.ToString;
  finally
    LJson.Free;
  end;
end;

{ TPersistentCache }

constructor TPersistentCache.Create(const AConfig: TCacheConfig);
begin
  inherited Create;
  FConfig := AConfig;
  FCacheData := TDictionary<string, Boolean>.Create;
  FHitCount := 0;
  FMissCount := 0;
end;

destructor TPersistentCache.Destroy;
begin
  FCacheData.Free;
  inherited Destroy;
end;

function TPersistentCache.TryGetValidation(const ASchema, AData: string; out AIsValid: Boolean; out AErrorCount: Integer): Boolean;
var
  LKey: string;
begin
  LKey := ASchema + '|' + AData;
  
  if FCacheData.TryGetValue(LKey, AIsValid) then
  begin
    Inc(FHitCount);
    AErrorCount := IfThen(AIsValid, 0, 1);
    Result := True;
  end
  else
  begin
    Inc(FMissCount);
    AIsValid := False;
    AErrorCount := 0;
    Result := False;
  end;
end;

procedure TPersistentCache.StoreValidation(const ASchema, AData: string; AIsValid: Boolean; AErrorCount: Integer);
var
  LKey: string;
begin
  LKey := ASchema + '|' + AData;
  FCacheData.AddOrSetValue(LKey, AIsValid);
end;

function TPersistentCache.GetHitRate: Double;
var
  LTotal: Integer;
begin
  LTotal := FHitCount + FMissCount;
  if LTotal > 0 then
    Result := FHitCount / LTotal
  else
    Result := 0;
end;

function TPersistentCache.GetCacheSize: Integer;
begin
  Result := FCacheData.Count;
end;

procedure TPersistentCache.Clear;
begin
  FCacheData.Clear;
  FHitCount := 0;
  FMissCount := 0;
end;

{ TAsyncValidator }

constructor TAsyncValidator.Create;
begin
  inherited Create;
  FTaskCounter := 0;
  FCompletedTasks := TDictionary<string, TAsyncValidationResult>.Create;
end;

destructor TAsyncValidator.Destroy;
begin
  FCompletedTasks.Free;
  inherited Destroy;
end;

function TAsyncValidator.SubmitValidation(const AJsonData: string; const ASchema: string;
  APriority: TValidationPriority; ACompletedCallback: TValidationCompletedCallback): string;
var
  LTaskId: string;
  LResult: TAsyncValidationResult;
begin
  Inc(FTaskCounter);
  LTaskId := Format('TASK_%d', [FTaskCounter]);
  
  // Simular validação assíncrona
  TTask.Run(
    procedure
    begin
      Sleep(Random(100) + 50); // Simular tempo de processamento
      
      LResult.TaskId := LTaskId;
      LResult.Status := avsCompleted;
      LResult.IsValid := Random(10) > 2; // 80% de sucesso
      LResult.ErrorCount := IfThen(LResult.IsValid, 0, Random(3) + 1);
      LResult.StartTime := Now;
      LResult.EndTime := Now;
      LResult.ErrorMessage := '';
      
      FCompletedTasks.AddOrSetValue(LTaskId, LResult);
      
      if Assigned(ACompletedCallback) then
        ACompletedCallback(LResult);
    end);
  
  Result := LTaskId;
end;

function TAsyncValidator.GetTaskResult(const ATaskId: string): TAsyncValidationResult;
begin
  if not FCompletedTasks.TryGetValue(ATaskId, Result) then
    raise Exception.CreateFmt('Task %s not found', [ATaskId]);
end;

function TAsyncValidator.WaitForTask(const ATaskId: string; ATimeoutMs: Integer): Boolean;
var
  LStartTime: TDateTime;
begin
  LStartTime := Now;
  
  repeat
    if FCompletedTasks.ContainsKey(ATaskId) then
      Exit(True);
      
    Sleep(10);
  until MilliSecondsBetween(Now, LStartTime) >= ATimeoutMs;
  
  Result := False;
end;

{ TReportGenerator }

constructor TReportGenerator.Create(AMetrics: TValidationMetrics);
begin
  inherited Create;
  FMetrics := AMetrics;
end;

function TReportGenerator.GenerateReport(const AConfig: TReportConfig): string;
begin
  case AConfig.Format of
    rfHTML:
      Result := Format(
        '<!DOCTYPE html>' + sLineBreak +
        '<html><head><title>%s</title></head>' + sLineBreak +
        '<body>' + sLineBreak +
        '<h1>%s</h1>' + sLineBreak +
        '<p>Autor: %s</p>' + sLineBreak +
        '<h2>Métricas</h2>' + sLineBreak +
        '<pre>%s</pre>' + sLineBreak +
        '</body></html>',
        [AConfig.Title, AConfig.Title, AConfig.Author, FMetrics.GenerateTextReport]);
    
    rfJSON:
      Result := FMetrics.GenerateJsonReport;
    
    rfCSV:
      Result := 'Metric,Value' + sLineBreak +
               Format('Total Validations,%d', [FMetrics.TotalValidations]) + sLineBreak +
               Format('Success Rate,%.2f%%', [FMetrics.GetSuccessRate * 100]) + sLineBreak +
               Format('Cache Hit Rate,%.2f%%', [FMetrics.GetCacheHitRate * 100]) + sLineBreak;
  else
    Result := FMetrics.GenerateTextReport;
  end;
end;

// Procedimentos de demonstração

procedure DemonstrateMetrics;
var
  LMetrics: TValidationMetrics;
  LRecord: TValidationRecord;
  I: Integer;
begin
  WriteLn('=== Demonstração do Sistema de Métricas ===');
  WriteLn;
  
  LMetrics := TValidationMetrics.Create;
  try
    // Simular várias validações
    for I := 1 to 100 do
    begin
      LRecord.Path := Format('/data/item[%d]', [I]);
      LRecord.StartTime := Now;
      Sleep(Random(10) + 1); // Simular tempo de processamento
      LRecord.EndTime := Now;
      LRecord.Success := Random(10) > 1; // 90% de sucesso
      LRecord.ErrorCount := IfThen(LRecord.Success, 0, Random(3) + 1);
      LRecord.CacheHit := Random(10) > 3; // 70% cache hit
      
      LMetrics.RecordValidation(LRecord);
    end;
    
    WriteLn('Relatório de Métricas:');
    WriteLn(LMetrics.GenerateTextReport);
    WriteLn;
    
    WriteLn('Relatório JSON:');
    WriteLn(LMetrics.GenerateJsonReport);
    WriteLn;
    
  finally
    LMetrics.Free;
  end;
end;

procedure DemonstratePersistentCache;
var
  LCache: TPersistentCache;
  LConfig: TCacheConfig;
  LIsValid: Boolean;
  LErrorCount: Integer;
  I: Integer;
begin
  WriteLn('=== Demonstração do Cache Persistente ===');
  WriteLn;
  
  // Configurar cache
  LConfig.MaxEntries := 1000;
  LConfig.ExpirationDays := 30;
  LConfig.CacheFilePath := 'demo_cache.json';
  LConfig.CompressionEnabled := False;
  LConfig.AutoSave := True;
  LConfig.SaveIntervalMinutes := 5;
  
  LCache := TPersistentCache.Create(LConfig);
  try
    // Testar cache misses
    WriteLn('Testando cache misses...');
    for I := 1 to 10 do
    begin
      if LCache.TryGetValidation('schema1', Format('data%d', [I]), LIsValid, LErrorCount) then
        WriteLn(Format('Cache HIT para data%d: %s', [I, BoolToStr(LIsValid, True)]))
      else
      begin
        WriteLn(Format('Cache MISS para data%d', [I]));
        // Simular validação e armazenar resultado
        LIsValid := Random(10) > 2;
        LErrorCount := IfThen(LIsValid, 0, 1);
        LCache.StoreValidation('schema1', Format('data%d', [I]), LIsValid, LErrorCount);
      end;
    end;
    
    WriteLn;
    WriteLn('Testando cache hits...');
    // Testar cache hits
    for I := 1 to 5 do
    begin
      if LCache.TryGetValidation('schema1', Format('data%d', [I]), LIsValid, LErrorCount) then
        WriteLn(Format('Cache HIT para data%d: %s', [I, BoolToStr(LIsValid, True)]))
      else
        WriteLn(Format('Cache MISS para data%d', [I]));
    end;
    
    WriteLn;
    WriteLn('Estatísticas do Cache:');
    WriteLn(Format('  Tamanho: %d entradas', [LCache.GetCacheSize]));
    WriteLn(Format('  Taxa de Hit: %.2f%%', [LCache.GetHitRate * 100]));
    WriteLn;
    
  finally
    LCache.Free;
  end;
end;

procedure DemonstrateAsyncValidation;
var
  LAsyncValidator: TAsyncValidator;
  LTaskIds: TArray<string>;
  LResult: TAsyncValidationResult;
  I: Integer;
  LCompletedCount: Integer;
begin
  WriteLn('=== Demonstração da Validação Assíncrona ===');
  WriteLn;
  
  LAsyncValidator := TAsyncValidator.Create;
  try
    SetLength(LTaskIds, 5);
    
    // Submeter várias validações assíncronas
    WriteLn('Submetendo 5 validações assíncronas...');
    for I := 0 to 4 do
    begin
      LTaskIds[I] := LAsyncValidator.SubmitValidation(
        Format('{"id": %d, "name": "test%d"}', [I, I]),
        '{"type": "object", "properties": {"id": {"type": "number"}}}',
        vpNormal,
        nil  // completion callback
      );
      WriteLn(Format('  Task %s submetida', [LTaskIds[I]]));
    end;
    
    WriteLn;
    WriteLn('Aguardando conclusão das tarefas...');
    
    // Aguardar conclusão
    LCompletedCount := 0;
    for I := 0 to 4 do
    begin
      if LAsyncValidator.WaitForTask(LTaskIds[I], 3000) then
      begin
        LResult := LAsyncValidator.GetTaskResult(LTaskIds[I]);
        WriteLn(Format('Task %s: %s (Erros: %d)', 
                      [LResult.TaskId, 
                       IfThen(LResult.IsValid, 'Válida', 'Inválida'),
                       LResult.ErrorCount]));
        Inc(LCompletedCount);
      end
      else
        WriteLn(Format('Task %s: Timeout', [LTaskIds[I]]));
    end;
    
    WriteLn;
    WriteLn(Format('Tarefas concluídas: %d de %d', [LCompletedCount, Length(LTaskIds)]));
    WriteLn;
    
  finally
    LAsyncValidator.Free;
  end;
end;

procedure DemonstrateReports;
var
  LMetrics: TValidationMetrics;
  LReportGenerator: TReportGenerator;
  LConfig: TReportConfig;
  LRecord: TValidationRecord;
  LReport: string;
  I: Integer;
begin
  WriteLn('=== Demonstração do Sistema de Relatórios ===');
  WriteLn;
  
  // Criar métricas de exemplo
  LMetrics := TValidationMetrics.Create;
  try
    for I := 1 to 50 do
    begin
      LRecord.Path := Format('/api/data[%d]', [I]);
      LRecord.StartTime := Now;
      Sleep(1);
      LRecord.EndTime := Now;
      LRecord.Success := Random(10) > 1;
      LRecord.ErrorCount := IfThen(LRecord.Success, 0, Random(2) + 1);
      LRecord.CacheHit := Random(10) > 4;
      
      LMetrics.RecordValidation(LRecord);
    end;
    
    LReportGenerator := TReportGenerator.Create(LMetrics);
    try
      // Relatório HTML
      LConfig.ReportType := rtValidationSummary;
      LConfig.Format := rfHTML;
      LConfig.Title := 'Relatório de Validação - Demo';
      LConfig.Author := 'JsonFlow4D Demo';
      LConfig.OutputPath := 'demo_report.html';
      
      WriteLn('Gerando relatório HTML...');
      LReport := LReportGenerator.GenerateReport(LConfig);
      WriteLn('Relatório HTML gerado:');
      WriteLn(Copy(LReport, 1, 200) + '...');
      WriteLn;
      
      // Relatório JSON
      LConfig.Format := rfJSON;
      LConfig.OutputPath := 'demo_report.json';
      
      WriteLn('Gerando relatório JSON...');
      LReport := LReportGenerator.GenerateReport(LConfig);
      WriteLn('Relatório JSON:');
      WriteLn(LReport);
      WriteLn;
      
      // Relatório CSV
      LConfig.Format := rfCSV;
      LConfig.OutputPath := 'demo_report.csv';
      
      WriteLn('Gerando relatório CSV...');
      LReport := LReportGenerator.GenerateReport(LConfig);
      WriteLn('Relatório CSV:');
      WriteLn(LReport);
      WriteLn;
      
    finally
      LReportGenerator.Free;
    end;
  finally
    LMetrics.Free;
  end;
end;

procedure DemonstrateIntegratedWorkflow;
var
  LMetrics: TValidationMetrics;
  LCache: TPersistentCache;
  LAsyncValidator: TAsyncValidator;
  LReportGenerator: TReportGenerator;
  LCacheConfig: TCacheConfig;
  LReportConfig: TReportConfig;
  LRecord: TValidationRecord;
  LTaskId: string;
  LIsValid: Boolean;
  LErrorCount: Integer;
  I: Integer;
begin
  WriteLn('=== Demonstração do Fluxo Integrado ===');
  WriteLn;
  
  // Configurar componentes
  LCacheConfig.MaxEntries := 100;
  LCacheConfig.ExpirationDays := 7;
  LCacheConfig.CacheFilePath := 'integrated_cache.json';
  LCacheConfig.AutoSave := True;
  LCacheConfig.SaveIntervalMinutes := 1;
  
  LMetrics := TValidationMetrics.Create;
  LCache := TPersistentCache.Create(LCacheConfig);
  LAsyncValidator := TAsyncValidator.Create;
  LReportGenerator := TReportGenerator.Create(LMetrics);
  
  try
    WriteLn('Executando fluxo integrado de validação...');
    
    // Simular fluxo de validação com cache e métricas
    for I := 1 to 20 do
    begin
      LRecord.Path := Format('/integrated/item[%d]', [I]);
      LRecord.StartTime := Now;
      
      // Verificar cache primeiro
      if LCache.TryGetValidation('integrated_schema', Format('data_%d', [I]), LIsValid, LErrorCount) then
      begin
        LRecord.CacheHit := True;
        LRecord.Success := LIsValid;
        LRecord.ErrorCount := LErrorCount;
      end
      else
      begin
        // Cache miss - executar validação
        LRecord.CacheHit := False;
        
        // Usar validação assíncrona para alguns itens
        if I mod 3 = 0 then
        begin
          LTaskId := LAsyncValidator.SubmitValidation(
            Format('{"item": %d}', [I]),
            '{"type": "object"}',
            vpNormal);
          
          if LAsyncValidator.WaitForTask(LTaskId, 1000) then
          begin
            var LResult := LAsyncValidator.GetTaskResult(LTaskId);
            LRecord.Success := LResult.IsValid;
            LRecord.ErrorCount := LResult.ErrorCount;
          end
          else
          begin
            LRecord.Success := False;
            LRecord.ErrorCount := 1;
          end;
        end
        else
        begin
          // Validação síncrona simulada
          Sleep(Random(5) + 1);
          LRecord.Success := Random(10) > 1;
          LRecord.ErrorCount := IfThen(LRecord.Success, 0, 1);
        end;
        
        // Armazenar no cache
        LCache.StoreValidation('integrated_schema', Format('data_%d', [I]), 
                              LRecord.Success, LRecord.ErrorCount);
      end;
      
      LRecord.EndTime := Now;
      LMetrics.RecordValidation(LRecord);
      
      // Usar variável intermediária para evitar IfThen aninhado
      if LRecord.CacheHit then
        Write('H')
      else if LRecord.Success then
        Write('.')
      else
        Write('E');
    end;
    
    WriteLn;
    WriteLn;
    WriteLn('Legenda: H=Cache Hit, .=Sucesso, E=Erro');
    WriteLn;
    
    // Gerar relatório final
    WriteLn('Estatísticas Finais:');
    WriteLn(Format('  Cache: %d entradas, %.1f%% hit rate', 
                  [LCache.GetCacheSize, LCache.GetHitRate * 100]));
    WriteLn(LMetrics.GenerateTextReport);
    
    // Gerar relatório HTML final
    LReportConfig.ReportType := rtValidationSummary;
    LReportConfig.Format := rfHTML;
    LReportConfig.Title := 'Relatório Integrado - JsonFlow4D';
    LReportConfig.Author := 'Sistema Integrado';
    LReportConfig.OutputPath := 'integrated_report.html';
    
    var LFinalReport := LReportGenerator.GenerateReport(LReportConfig);
    WriteLn;
    WriteLn('Relatório final gerado em: ' + LReportConfig.OutputPath);
    
  finally
    LReportGenerator.Free;
    LAsyncValidator.Free;
    LCache.Free;
    LMetrics.Free;
  end;
end;

// Programa principal
begin
  try
    Randomize;
    
    WriteLn('JsonFlow4D - Demonstração de Funcionalidades Avançadas');
    WriteLn('=========================================================');
    WriteLn;
    
    // Executar demonstrações
    DemonstrateMetrics;
    WriteLn('Pressione ENTER para continuar...');
    ReadLn;
    
    DemonstratePersistentCache;
    WriteLn('Pressione ENTER para continuar...');
    ReadLn;
    
    DemonstrateAsyncValidation;
    WriteLn('Pressione ENTER para continuar...');
    ReadLn;
    
    DemonstrateReports;
    WriteLn('Pressione ENTER para continuar...');
    ReadLn;
    
    DemonstrateIntegratedWorkflow;
    
    WriteLn;
    WriteLn('=== Demonstração Concluída ===');
    WriteLn;
    WriteLn('Funcionalidades demonstradas:');
    WriteLn('✓ Sistema de métricas avançadas');
    WriteLn('✓ Cache persistente com estatísticas');
    WriteLn('✓ Validação assíncrona com callbacks');
    WriteLn('✓ Geração de relatórios em múltiplos formatos');
    WriteLn('✓ Fluxo integrado com todas as funcionalidades');
    WriteLn;
    WriteLn('Arquivos gerados:');
    WriteLn('- demo_report.html');
    WriteLn('- demo_report.json');
    WriteLn('- demo_report.csv');
    WriteLn('- integrated_report.html');
    WriteLn('- demo_cache.json');
    WriteLn('- integrated_cache.json');
    WriteLn;
    WriteLn('Pressione ENTER para sair...');
    ReadLn;
    
  except
    on E: Exception do
    begin
      WriteLn('Erro: ' + E.Message);
      WriteLn('Pressione ENTER para sair...');
      ReadLn;
    end;
  end;
end.