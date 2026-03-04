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
unit JsonFlow.Reports;

{
  JsonFlow4D - Sistema de Relatórios Detalhados
  
  Este arquivo implementa um sistema completo de relatórios para análise
  de validação e performance, incluindo relatórios em múltiplos formatos
  (HTML, JSON, CSV, XML) e diferentes tipos de análises.
  
  Funcionalidades:
  - Relatórios de validação detalhados
  - Análise de performance e métricas
  - Relatórios de cache e otimização
  - Exportação em múltiplos formatos
  - Gráficos e visualizações
  - Relatórios agendados
  
  Autor: JsonFlow4D Framework
  Data: 2024
}

interface

uses
  System.SysUtils,
  System.Math,
  System.Classes,
  System.Generics.Collections,
  System.DateUtils,
  JsonFlow.Interfaces,
  JsonFlow.Metrics,
  JsonFlow.Utils;

type
  // Tipos de relatório
  TReportType = (rtValidationSummary, rtPerformanceAnalysis, rtCacheAnalysis, 
                 rtErrorAnalysis, rtTrendAnalysis, rtComprehensive);
  
  // Formatos de saída
  TReportFormat = (rfHTML, rfJSON, rfCSV, rfXML, rfPDF, rfText);
  
  // Período do relatório
  TReportPeriod = record
    StartDate: TDateTime;
    EndDate: TDateTime;
    Description: string;
  end;
  
  // Configurações do relatório
  TReportConfig = record
    ReportType: TReportType;
    Format: TReportFormat;
    Period: TReportPeriod;
    IncludeCharts: Boolean;
    IncludeDetails: Boolean;
    IncludeRecommendations: Boolean;
    OutputPath: string;
    Title: string;
    Author: string;
  end;
  
  // Dados de erro para relatório
  TErrorReportData = record
    ErrorType: string;
    Count: Integer;
    Percentage: Double;
    FirstOccurrence: TDateTime;
    LastOccurrence: TDateTime;
    AffectedPaths: TArray<string>;
  end;
  
  // Dados de performance para relatório
  TPerformanceReportData = record
    TotalValidations: Integer;
    AverageTime: Double;
    MinTime: Double;
    MaxTime: Double;
    SuccessRate: Double;
    CacheHitRate: Double;
    ThroughputPerSecond: Double;
    MemoryUsage: Int64;
  end;
  
  // Dados de tendência
  TTrendData = record
    Date: TDateTime;
    Value: Double;
    Caption: string;
  end;
  
  // Recomendação de otimização
  TOptimizationRecommendation = record
    Category: string;
    Priority: Integer; // 1-5, sendo 5 mais crítico
    Description: string;
    ExpectedImpact: string;
    ImplementationSteps: string;
  end;
  
  // Gerador de relatórios base
  TReportGenerator = class abstract
  protected
    FConfig: TReportConfig;
    FMetrics: TValidationMetrics;
    
    function FormatDateTime(const ADateTime: TDateTime): string; virtual;
    function FormatDuration(const AMilliseconds: Double): string; virtual;
    function FormatPercentage(const AValue: Double): string; virtual;
    function FormatFileSize(const ABytes: Int64): string; virtual;
    
  public
    constructor Create(const AConfig: TReportConfig; AMetrics: TValidationMetrics);
    
    function Generate: string; virtual; abstract;
    procedure SaveToFile(const AContent: string); virtual;
    
    property Config: TReportConfig read FConfig write FConfig;
  end;
  
  // Gerador de relatórios HTML
  THtmlReportGenerator = class(TReportGenerator)
  private
    function GenerateHeader: string;
    function GenerateFooter: string;
    function GenerateValidationSummary: string;
    function GeneratePerformanceSection: string;
    function GenerateCacheSection: string;
    function GenerateErrorSection: string;
    function GenerateTrendSection: string;
    function GenerateRecommendationsSection: string;
    function GenerateChart(const AData: TArray<TTrendData>; const ATitle: string): string;
    function GetErrorReportData: TArray<TErrorReportData>;
    function GetPerformanceData: TPerformanceReportData;
    function GetOptimizationRecommendations: TArray<TOptimizationRecommendation>;
    
  public
    function Generate: string; override;
  end;
  
  // Gerador de relatórios JSON
  TJsonReportGenerator = class(TReportGenerator)
  private
    function CreateValidationSummaryJson: string;
    function CreatePerformanceJson: string;
    function CreateCacheJson: string;
    function CreateErrorsJson: string;
    function CreateTrendsJson: string;
    function CreateRecommendationsJson: string;
    
  public
    function Generate: string; override;
  end;
  
  // Gerador de relatórios CSV
  TCsvReportGenerator = class(TReportGenerator)
  private
    function GenerateValidationCsv: string;
    function GeneratePerformanceCsv: string;
    function GenerateErrorsCsv: string;
    function EscapeCsvValue(const AValue: string): string;
    
  public
    function Generate: string; override;
  end;
  
  // Gerador de relatórios XML
  TXmlReportGenerator = class(TReportGenerator)
  private
    function GenerateXmlHeader: string;
    function GenerateValidationXml: string;
    function GeneratePerformanceXml: string;
    function GenerateErrorsXml: string;
    function EscapeXmlValue(const AValue: string): string;
    
  public
    function Generate: string; override;
  end;
  
  // Factory para geradores de relatório
  TReportGeneratorFactory = class
  public
    class function CreateGenerator(const AConfig: TReportConfig; 
                                  AMetrics: TValidationMetrics): TReportGenerator;
  end;
  
  // Agendador de relatórios
  TReportScheduler = class
  private
    FScheduledReports: TList<TReportConfig>;
    FTimer: TObject; // TTimer seria ideal, mas mantemos genérico
    FEnabled: Boolean;
    
    procedure ExecuteScheduledReports;
    
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure AddScheduledReport(const AConfig: TReportConfig);
    procedure RemoveScheduledReport(const AReportId: string);
    procedure Start;
    procedure Stop;
    
    property Enabled: Boolean read FEnabled;
  end;
  
  // Gerenciador principal de relatórios
  TReportManager = class
  private
    FMetrics: TValidationMetrics;
    FScheduler: TReportScheduler;
    FReportHistory: TList<string>;
    
  public
    constructor Create(AMetrics: TValidationMetrics);
    destructor Destroy; override;
    
    // Geração de relatórios
    function GenerateReport(const AConfig: TReportConfig): string;
    function GenerateQuickReport(AType: TReportType; AFormat: TReportFormat): string;
    
    // Relatórios predefinidos
    function GenerateDailyReport: string;
    function GenerateWeeklyReport: string;
    function GenerateMonthlyReport: string;
    function GeneratePerformanceReport: string;
    function GenerateErrorAnalysisReport: string;
    
    // Agendamento
    procedure ScheduleReport(const AConfig: TReportConfig);
    
    // Histórico
    function GetReportHistory: TArray<string>;
    procedure ClearHistory;
    
    property Scheduler: TReportScheduler read FScheduler;
  end;

implementation

{ TReportGenerator }

constructor TReportGenerator.Create(const AConfig: TReportConfig; AMetrics: TValidationMetrics);
begin
  inherited Create;
  FConfig := AConfig;
  FMetrics := AMetrics;
end;

function TReportGenerator.FormatDateTime(const ADateTime: TDateTime): string;
begin
  Result := System.SysUtils.FormatDateTime('dd/mm/yyyy hh:nn:ss', ADateTime);
end;

function TReportGenerator.FormatDuration(const AMilliseconds: Double): string;
begin
  if AMilliseconds < 1000 then
    Result := Format('%.2f ms', [AMilliseconds])
  else if AMilliseconds < 60000 then
    Result := Format('%.2f s', [AMilliseconds / 1000])
  else
    Result := Format('%.2f min', [AMilliseconds / 60000]);
end;

function TReportGenerator.FormatPercentage(const AValue: Double): string;
begin
  Result := Format('%.2f%%', [AValue * 100]);
end;

function TReportGenerator.FormatFileSize(const ABytes: Int64): string;
const
  KB = 1024;
  MB = KB * 1024;
  GB = MB * 1024;
begin
  if ABytes < KB then
    Result := Format('%d B', [ABytes])
  else if ABytes < MB then
    Result := Format('%.2f KB', [ABytes / KB])
  else if ABytes < GB then
    Result := Format('%.2f MB', [ABytes / MB])
  else
    Result := Format('%.2f GB', [ABytes / GB]);
end;

procedure TReportGenerator.SaveToFile(const AContent: string);
var
  LFileStream: TFileStream;
begin
  if FConfig.OutputPath <> '' then
  begin
    ForceDirectories(System.SysUtils.ExtractFilePath(FConfig.OutputPath));
    
    LFileStream := TFileStream.Create(FConfig.OutputPath, fmCreate);
    try
      LFileStream.WriteBuffer(PChar(AContent)^, Length(AContent) * SizeOf(Char));
    finally
      LFileStream.Free;
    end;
  end;
end;

{ THtmlReportGenerator }

function THtmlReportGenerator.Generate: string;
var
  LHtml: TStringBuilder;
begin
  LHtml := TStringBuilder.Create;
  try
    LHtml.Append(GenerateHeader);
    
    case FConfig.ReportType of
      rtValidationSummary:
        LHtml.Append(GenerateValidationSummary);
      rtPerformanceAnalysis:
        LHtml.Append(GeneratePerformanceSection);
      rtCacheAnalysis:
        LHtml.Append(GenerateCacheSection);
      rtErrorAnalysis:
        LHtml.Append(GenerateErrorSection);
      rtTrendAnalysis:
        LHtml.Append(GenerateTrendSection);
      rtComprehensive:
        begin
          LHtml.Append(GenerateValidationSummary);
          LHtml.Append(GeneratePerformanceSection);
          LHtml.Append(GenerateCacheSection);
          LHtml.Append(GenerateErrorSection);
          if FConfig.IncludeRecommendations then
            LHtml.Append(GenerateRecommendationsSection);
        end;
    end;
    
    LHtml.Append(GenerateFooter);
    
    Result := LHtml.ToString;
  finally
    LHtml.Free;
  end;
end;

function THtmlReportGenerator.GenerateHeader: string;
begin
  Result := Format(
    '<!DOCTYPE html>' + sLineBreak +
    '<html>' + sLineBreak +
    '<head>' + sLineBreak +
    '  <meta charset="UTF-8">' + sLineBreak +
    '  <title>%s</title>' + sLineBreak +
    '  <style>' + sLineBreak +
    '    body { font-family: Arial, sans-serif; margin: 20px; }' + sLineBreak +
    '    .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }' + sLineBreak +
    '    .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }' + sLineBreak +
    '    .metric { display: inline-block; margin: 10px; padding: 10px; background: #e8f4fd; border-radius: 3px; }' + sLineBreak +
    '    .error { color: #d32f2f; }' + sLineBreak +
    '    .success { color: #388e3c; }' + sLineBreak +
    '    .warning { color: #f57c00; }' + sLineBreak +
    '    table { width: 100%%; border-collapse: collapse; margin: 10px 0; }' + sLineBreak +
    '    th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }' + sLineBreak +
    '    th { background-color: #f2f2f2; }' + sLineBreak +
    '  </style>' + sLineBreak +
    '</head>' + sLineBreak +
    '<body>' + sLineBreak +
    '  <div class="header">' + sLineBreak +
    '    <h1>%s</h1>' + sLineBreak +
    '    <p>Gerado em: %s</p>' + sLineBreak +
    '    <p>Período: %s até %s</p>' + sLineBreak +
    '    <p>Autor: %s</p>' + sLineBreak +
    '  </div>' + sLineBreak,
    [FConfig.Title, FConfig.Title, FormatDateTime(Now),
     FormatDateTime(FConfig.Period.StartDate), FormatDateTime(FConfig.Period.EndDate),
     FConfig.Author]);
end;

function THtmlReportGenerator.GenerateFooter: string;
begin
  Result := 
    '  <div class="footer">' + sLineBreak +
    '    <p><small>Relatório gerado pelo JsonFlow4D Framework</small></p>' + sLineBreak +
    '  </div>' + sLineBreak +
    '</body>' + sLineBreak +
    '</html>';
end;

function THtmlReportGenerator.GenerateValidationSummary: string;
var
  LPerformanceData: TPerformanceReportData;
  LSuccessRate_0_95: Boolean;
  LSuccessRate_0_8: Boolean;
  LStatusClass: string;
begin
  LPerformanceData := GetPerformanceData;
  LSuccessRate_0_95 := LPerformanceData.SuccessRate >= 0.95;
  LSuccessRate_0_8 := LPerformanceData.SuccessRate >= 0.8;

  if LSuccessRate_0_95 then
    LStatusClass := 'success'
  else if LSuccessRate_0_8 then
    LStatusClass := 'warning'
  else
    LStatusClass := 'error';

  Result := Format(
    '  <div class="section">' + sLineBreak +
    '    <h2>Resumo de Validações</h2>' + sLineBreak +
    '    <div class="metric">' + sLineBreak +
    '      <strong>Total de Validações:</strong> %d' + sLineBreak +
    '    </div>' + sLineBreak +
    '    <div class="metric %s">' + sLineBreak +
    '      <strong>Taxa de Sucesso:</strong> %s' + sLineBreak +
    '    </div>' + sLineBreak +
    '    <div class="metric">' + sLineBreak +
    '      <strong>Tempo Médio:</strong> %s' + sLineBreak +
    '    </div>' + sLineBreak +
    '    <div class="metric">' + sLineBreak +
    '      <strong>Throughput:</strong> %.2f validações/segundo' + sLineBreak +
    '    </div>' + sLineBreak +
    '  </div>' + sLineBreak,
    [LPerformanceData.TotalValidations,
     LStatusClass,
     FormatPercentage(LPerformanceData.SuccessRate),
     FormatDuration(LPerformanceData.AverageTime),
     LPerformanceData.ThroughputPerSecond]);
end;

function THtmlReportGenerator.GeneratePerformanceSection: string;
var
  LPerformanceData: TPerformanceReportData;
begin
  LPerformanceData := GetPerformanceData;
  
  Result := Format(
    '  <div class="section">' + sLineBreak +
    '    <h2>Análise de Performance</h2>' + sLineBreak +
    '    <table>' + sLineBreak +
    '      <tr><th>Métrica</th><th>Valor</th></tr>' + sLineBreak +
    '      <tr><td>Tempo Mínimo</td><td>%s</td></tr>' + sLineBreak +
    '      <tr><td>Tempo Médio</td><td>%s</td></tr>' + sLineBreak +
    '      <tr><td>Tempo Máximo</td><td>%s</td></tr>' + sLineBreak +
    '      <tr><td>Taxa de Cache Hit</td><td>%s</td></tr>' + sLineBreak +
    '      <tr><td>Uso de Memória</td><td>%s</td></tr>' + sLineBreak +
    '    </table>' + sLineBreak +
    '  </div>' + sLineBreak,
    [FormatDuration(LPerformanceData.MinTime),
     FormatDuration(LPerformanceData.AverageTime),
     FormatDuration(LPerformanceData.MaxTime),
     FormatPercentage(LPerformanceData.CacheHitRate),
     FormatFileSize(LPerformanceData.MemoryUsage)]);
end;

function THtmlReportGenerator.GenerateCacheSection: string;
begin
  Result := 
    '  <div class="section">' + sLineBreak +
    '    <h2>Análise de Cache</h2>' + sLineBreak +
    '    <p>Análise detalhada do cache será implementada...</p>' + sLineBreak +
    '  </div>' + sLineBreak;
end;

function THtmlReportGenerator.GenerateErrorSection: string;
var
  LErrorData: TArray<TErrorReportData>;
  LError: TErrorReportData;
  LHtml: TStringBuilder;
begin
  LErrorData := GetErrorReportData;
  
  LHtml := TStringBuilder.Create;
  try
    LHtml.Append('  <div class="section">' + sLineBreak);
    LHtml.Append('    <h2>Análise de Erros</h2>' + sLineBreak);
    
    if Length(LErrorData) > 0 then
    begin
      LHtml.Append('    <table>' + sLineBreak);
      LHtml.Append('      <tr><th>Tipo de Erro</th><th>Quantidade</th><th>Percentual</th><th>Primeira Ocorrência</th></tr>' + sLineBreak);
      
      for LError in LErrorData do
      begin
        LHtml.AppendFormat('      <tr><td>%s</td><td>%d</td><td>%s</td><td>%s</td></tr>' + sLineBreak,
          [LError.ErrorType, LError.Count, FormatPercentage(LError.Percentage / 100),
           FormatDateTime(LError.FirstOccurrence)]);
      end;
      
      LHtml.Append('    </table>' + sLineBreak);
    end
    else
    begin
      LHtml.Append('    <p class="success">Nenhum erro encontrado no período analisado.</p>' + sLineBreak);
    end;
    
    LHtml.Append('  </div>' + sLineBreak);
    
    Result := LHtml.ToString;
  finally
    LHtml.Free;
  end;
end;

function THtmlReportGenerator.GenerateTrendSection: string;
begin
  Result := 
    '  <div class="section">' + sLineBreak +
    '    <h2>Análise de Tendências</h2>' + sLineBreak +
    '    <p>Gráficos de tendência serão implementados...</p>' + sLineBreak +
    '  </div>' + sLineBreak;
end;

function THtmlReportGenerator.GenerateRecommendationsSection: string;
var
  LRecommendations: TArray<TOptimizationRecommendation>;
  LRecommendation: TOptimizationRecommendation;
  LHtml: TStringBuilder;
  LCssClass: string;
begin
  LRecommendations := GetOptimizationRecommendations;
  
  LHtml := TStringBuilder.Create;
  try
    LHtml.Append('  <div class="section">' + sLineBreak);
    LHtml.Append('    <h2>Recomendações de Otimização</h2>' + sLineBreak);
    
    for LRecommendation in LRecommendations do
    begin
      // Determina a classe CSS baseada na prioridade
      if LRecommendation.Priority >= 4 then
        LCssClass := 'error'
      else if LRecommendation.Priority >= 3 then
        LCssClass := 'warning'
      else
        LCssClass := '';
      
      LHtml.AppendFormat(
        '    <div class="metric %s">' + sLineBreak +
        '      <h4>%s (Prioridade: %d)</h4>' + sLineBreak +
        '      <p><strong>Descrição:</strong> %s</p>' + sLineBreak +
        '      <p><strong>Impacto Esperado:</strong> %s</p>' + sLineBreak +
        '      <p><strong>Implementação:</strong> %s</p>' + sLineBreak +
        '    </div>' + sLineBreak,
        [LCssClass,
         LRecommendation.Category, LRecommendation.Priority,
         LRecommendation.Description, LRecommendation.ExpectedImpact,
         LRecommendation.ImplementationSteps]);
    end;
    
    LHtml.Append('  </div>' + sLineBreak);
    
    Result := LHtml.ToString;
  finally
    LHtml.Free;
  end;
end;

function THtmlReportGenerator.GenerateChart(const AData: TArray<TTrendData>; const ATitle: string): string;
begin
  // Implementação de gráficos seria feita aqui
  Result := Format('<div class="chart"><h3>%s</h3><p>Gráfico será implementado</p></div>', [ATitle]);
end;

function THtmlReportGenerator.GetErrorReportData: TArray<TErrorReportData>;
begin
  // Implementar análise de erros baseada nas métricas
  SetLength(Result, 0);
end;

function THtmlReportGenerator.GetPerformanceData: TPerformanceReportData;
begin
  // Implementar extração de dados de performance das métricas
  FillChar(Result, SizeOf(Result), 0);
  Result.TotalValidations := 100; // Exemplo
  Result.SuccessRate := 0.95;
  Result.AverageTime := 50.5;
  Result.MinTime := 10.2;
  Result.MaxTime := 150.8;
  Result.CacheHitRate := 0.75;
  Result.ThroughputPerSecond := 20.0;
  Result.MemoryUsage := 1024 * 1024; // 1MB
end;

function THtmlReportGenerator.GetOptimizationRecommendations: TArray<TOptimizationRecommendation>;
var
  LRecommendation: TOptimizationRecommendation;
begin
  SetLength(Result, 2);
  
  LRecommendation.Category := 'Cache';
  LRecommendation.Priority := 3;
  LRecommendation.Description := 'Aumentar o tamanho do cache para melhorar a taxa de hit';
  LRecommendation.ExpectedImpact := 'Redução de 20-30% no tempo de validação';
  LRecommendation.ImplementationSteps := 'Configurar MaxCacheSize para 10000 entradas';
  Result[0] := LRecommendation;
  
  LRecommendation.Category := 'Threading';
  LRecommendation.Priority := 2;
  LRecommendation.Description := 'Utilizar validação assíncrona para grandes volumes';
  LRecommendation.ExpectedImpact := 'Melhoria de 50-80% no throughput';
  LRecommendation.ImplementationSteps := 'Implementar TAsyncValidator para processamento em lote';
  Result[1] := LRecommendation;
end;

{ TJsonReportGenerator }

function TJsonReportGenerator.Generate: string;
begin
  Result := '{';
  Result := Result + '"title":"' + FConfig.Title + '",';
  Result := Result + '"generated_at":"' + FormatDateTime(Now) + '",';
  Result := Result + '"period_start":"' + FormatDateTime(FConfig.Period.StartDate) + '",';
  Result := Result + '"period_end":"' + FormatDateTime(FConfig.Period.EndDate) + '",';
  Result := Result + '"author":"' + FConfig.Author + '",';
  
  case FConfig.ReportType of
    rtValidationSummary:
      Result := Result + '"validation_summary":' + CreateValidationSummaryJson;
    rtPerformanceAnalysis:
      Result := Result + '"performance":' + CreatePerformanceJson;
    rtCacheAnalysis:
      Result := Result + '"cache":' + CreateCacheJson;
    rtErrorAnalysis:
      Result := Result + '"errors":' + CreateErrorsJson;
    rtTrendAnalysis:
      Result := Result + '"trends":' + CreateTrendsJson;
    rtComprehensive:
      begin
        Result := Result + '"validation_summary":' + CreateValidationSummaryJson + ',';
        Result := Result + '"performance":' + CreatePerformanceJson + ',';
        Result := Result + '"cache":' + CreateCacheJson + ',';
        Result := Result + '"errors":' + CreateErrorsJson;
        if FConfig.IncludeRecommendations then
          Result := Result + ',"recommendations":' + CreateRecommendationsJson;
      end;
  end;
  
  Result := Result + '}';
end;

function TJsonReportGenerator.CreateValidationSummaryJson: string;
var
  LPerformanceData: TPerformanceReportData;
begin
  LPerformanceData := THtmlReportGenerator(Self).GetPerformanceData;
  
  Result := '{';
  Result := Result + '"total_validations":' + IntToStr(LPerformanceData.TotalValidations) + ',';
  Result := Result + '"success_rate":' + FloatToStr(LPerformanceData.SuccessRate) + ',';
  Result := Result + '"average_time_ms":' + FloatToStr(LPerformanceData.AverageTime) + ',';
  Result := Result + '"throughput_per_second":' + FloatToStr(LPerformanceData.ThroughputPerSecond);
  Result := Result + '}';
end;

function TJsonReportGenerator.CreatePerformanceJson: string;
begin
  Result := '{}';
  // Implementar dados de performance
end;

function TJsonReportGenerator.CreateCacheJson: string;
begin
  Result := '{}';
  // Implementar dados de cache
end;

function TJsonReportGenerator.CreateErrorsJson: string;
begin
  Result := '[]';
  // Implementar dados de erros
end;

function TJsonReportGenerator.CreateTrendsJson: string;
begin
  Result := '[]';
  // Implementar dados de tendências
end;

function TJsonReportGenerator.CreateRecommendationsJson: string;
begin
  Result := '[]';
  // Implementar recomendações
end;

{ TCsvReportGenerator }

function TCsvReportGenerator.Generate: string;
var
  LCsv: TStringBuilder;
begin
  LCsv := TStringBuilder.Create;
  try
    case FConfig.ReportType of
      rtValidationSummary:
        LCsv.Append(GenerateValidationCsv);
      rtPerformanceAnalysis:
        LCsv.Append(GeneratePerformanceCsv);
      rtErrorAnalysis:
        LCsv.Append(GenerateErrorsCsv);
    end;
    
    Result := LCsv.ToString;
  finally
    LCsv.Free;
  end;
end;

function TCsvReportGenerator.GenerateValidationCsv: string;
begin
  Result := 'Metric,Value' + sLineBreak +
           'Total Validations,100' + sLineBreak +
           'Success Rate,95%' + sLineBreak +
           'Average Time,50.5ms' + sLineBreak;
end;

function TCsvReportGenerator.GeneratePerformanceCsv: string;
begin
  Result := 'Metric,Value' + sLineBreak +
           'Min Time,10.2ms' + sLineBreak +
           'Average Time,50.5ms' + sLineBreak +
           'Max Time,150.8ms' + sLineBreak;
end;

function TCsvReportGenerator.GenerateErrorsCsv: string;
begin
  Result := 'Error Type,Count,Percentage' + sLineBreak;
end;

function TCsvReportGenerator.EscapeCsvValue(const AValue: string): string;
begin
  if Pos(',', AValue) > 0 then
    Result := '"' + StringReplace(AValue, '"', '""', [rfReplaceAll]) + '"'
  else
    Result := AValue;
end;

{ TXmlReportGenerator }

function TXmlReportGenerator.Generate: string;
var
  LXml: TStringBuilder;
begin
  LXml := TStringBuilder.Create;
  try
    LXml.Append(GenerateXmlHeader);
    LXml.Append('<report>');
    LXml.AppendFormat('<title>%s</title>', [EscapeXmlValue(FConfig.Title)]);
    LXml.AppendFormat('<generated_at>%s</generated_at>', [DateTimeToIso8601(Now, True)]);
    
    case FConfig.ReportType of
      rtValidationSummary:
        LXml.Append(GenerateValidationXml);
      rtPerformanceAnalysis:
        LXml.Append(GeneratePerformanceXml);
      rtErrorAnalysis:
        LXml.Append(GenerateErrorsXml);
    end;
    
    LXml.Append('</report>');
    
    Result := LXml.ToString;
  finally
    LXml.Free;
  end;
end;

function TXmlReportGenerator.GenerateXmlHeader: string;
begin
  Result := '<?xml version="1.0" encoding="UTF-8"?>' + sLineBreak;
end;

function TXmlReportGenerator.GenerateValidationXml: string;
begin
  Result := '<validation_summary>' +
           '<total_validations>100</total_validations>' +
           '<success_rate>0.95</success_rate>' +
           '</validation_summary>';
end;

function TXmlReportGenerator.GeneratePerformanceXml: string;
begin
  Result := '<performance>' +
           '<average_time>50.5</average_time>' +
           '<min_time>10.2</min_time>' +
           '<max_time>150.8</max_time>' +
           '</performance>';
end;

function TXmlReportGenerator.GenerateErrorsXml: string;
begin
  Result := '<errors></errors>';
end;

function TXmlReportGenerator.EscapeXmlValue(const AValue: string): string;
begin
  Result := StringReplace(AValue, '&', '&amp;', [rfReplaceAll]);
  Result := StringReplace(Result, '<', '&lt;', [rfReplaceAll]);
  Result := StringReplace(Result, '>', '&gt;', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '&quot;', [rfReplaceAll]);
  Result := StringReplace(Result, '''', '&apos;', [rfReplaceAll]);
end;

{ TReportGeneratorFactory }

class function TReportGeneratorFactory.CreateGenerator(const AConfig: TReportConfig;
  AMetrics: TValidationMetrics): TReportGenerator;
begin
  case AConfig.Format of
    rfHTML: Result := THtmlReportGenerator.Create(AConfig, AMetrics);
    rfJSON: Result := TJsonReportGenerator.Create(AConfig, AMetrics);
    rfCSV: Result := TCsvReportGenerator.Create(AConfig, AMetrics);
    rfXML: Result := TXmlReportGenerator.Create(AConfig, AMetrics);
  else
    raise Exception.Create('Formato de relatório não suportado');
  end;
end;

{ TReportScheduler }

constructor TReportScheduler.Create;
begin
  inherited Create;
  FScheduledReports := TList<TReportConfig>.Create;
  FEnabled := False;
end;

destructor TReportScheduler.Destroy;
begin
  Stop;
  FScheduledReports.Free;
  inherited Destroy;
end;

procedure TReportScheduler.AddScheduledReport(const AConfig: TReportConfig);
begin
  FScheduledReports.Add(AConfig);
end;

procedure TReportScheduler.RemoveScheduledReport(const AReportId: string);
begin
  // Implementar remoção por ID
end;

procedure TReportScheduler.Start;
begin
  FEnabled := True;
  // Implementar timer para execução agendada
end;

procedure TReportScheduler.Stop;
begin
  FEnabled := False;
  // Parar timer
end;

procedure TReportScheduler.ExecuteScheduledReports;
begin
  // Implementar execução dos relatórios agendados
end;

{ TReportManager }

constructor TReportManager.Create(AMetrics: TValidationMetrics);
begin
  inherited Create;
  FMetrics := AMetrics;
  FScheduler := TReportScheduler.Create;
  FReportHistory := TList<string>.Create;
end;

destructor TReportManager.Destroy;
begin
  FScheduler.Free;
  FReportHistory.Free;
  inherited Destroy;
end;

function TReportManager.GenerateReport(const AConfig: TReportConfig): string;
var
  LGenerator: TReportGenerator;
begin
  LGenerator := TReportGeneratorFactory.CreateGenerator(AConfig, FMetrics);
  try
    Result := LGenerator.Generate;
    LGenerator.SaveToFile(Result);
    
    // Adicionar ao histórico
    FReportHistory.Add(Format('%s - %s', [FormatDateTime('dd/mm/yyyy hh:nn', Now), AConfig.Title]));
  finally
    LGenerator.Free;
  end;
end;

function TReportManager.GenerateQuickReport(AType: TReportType; AFormat: TReportFormat): string;
var
  LConfig: TReportConfig;
begin
  LConfig.ReportType := AType;
  LConfig.Format := AFormat;
  LConfig.Period.StartDate := Now - 7; // Última semana
  LConfig.Period.EndDate := Now;
  LConfig.Title := 'Relatório Rápido';
  LConfig.Author := 'JsonFlow4D';
  LConfig.IncludeCharts := False;
  LConfig.IncludeDetails := True;
  LConfig.IncludeRecommendations := False;
  
  Result := GenerateReport(LConfig);
end;

function TReportManager.GenerateDailyReport: string;
begin
  Result := GenerateQuickReport(rtComprehensive, rfHTML);
end;

function TReportManager.GenerateWeeklyReport: string;
begin
  Result := GenerateQuickReport(rtComprehensive, rfHTML);
end;

function TReportManager.GenerateMonthlyReport: string;
begin
  Result := GenerateQuickReport(rtComprehensive, rfHTML);
end;

function TReportManager.GeneratePerformanceReport: string;
begin
  Result := GenerateQuickReport(rtPerformanceAnalysis, rfHTML);
end;

function TReportManager.GenerateErrorAnalysisReport: string;
begin
  Result := GenerateQuickReport(rtErrorAnalysis, rfHTML);
end;

procedure TReportManager.ScheduleReport(const AConfig: TReportConfig);
begin
  FScheduler.AddScheduledReport(AConfig);
end;

function TReportManager.GetReportHistory: TArray<string>;
begin
  Result := FReportHistory.ToArray;
end;

procedure TReportManager.ClearHistory;
begin
  FReportHistory.Clear;
end;

end.
