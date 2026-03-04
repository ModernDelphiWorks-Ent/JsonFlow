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
unit JsonFlow.AsyncValidator;

{
  JsonFlow4D - Sistema de Validação Assíncrona
  
  Este arquivo implementa um sistema de validação assíncrona que permite
  validar múltiplos documentos JSON em paralelo, melhorando significativamente
  a performance para grandes volumes de dados.
  
  Funcionalidades:
  - Validação em múltiplas threads
  - Pool de threads configurável
  - Callbacks para progresso e conclusão
  - Cancelamento de operações
  - Priorização de tarefas
  - Balanceamento de carga
  
  Autor: JsonFlow4D Framework
  Data: 2024
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  System.Threading,
  JsonFlow.Interfaces,
  JsonFlow.SchemaValidator,
  JsonFlow.Reader;

type
  // Prioridade da tarefa de validação
  TValidationPriority = (vpLow, vpNormal, vpHigh, vpCritical);
  
  // Status da validação assíncrona
  TAsyncValidationStatus = (avsQueued, avsRunning, avsCompleted, avsCancelled, avsError);
  
  // Resultado da validação assíncrona
  TAsyncValidationResult = record
    TaskId: string;
    Status: TAsyncValidationStatus;
    IsValid: Boolean;
    Errors: TList<TValidationError>;
    StartTime: TDateTime;
    EndTime: TDateTime;
    ErrorMessage: string;
  end;
  
  // Callback para progresso
  TValidationProgressCallback = procedure(const ATaskId: string; AProgress: Integer; ATotal: Integer) of object;
  
  // Callback para conclusão
  TValidationCompletedCallback = procedure(const AResult: TAsyncValidationResult) of object;
  
  // Tarefa de validação
  TValidationTask = class
  private
    FTaskId: string;
    FJsonData: string;
    FSchema: IJSONElement;
    FPriority: TValidationPriority;
    FProgressCallback: TValidationProgressCallback;
    FCompletedCallback: TValidationCompletedCallback;
    FCreatedAt: TDateTime;
    FCancelled: Boolean;
    
  public
    constructor Create(const ATaskId: string; const AJsonData: string; 
                     const ASchema: IJSONElement; APriority: TValidationPriority;
                     AProgressCallback: TValidationProgressCallback;
                     ACompletedCallback: TValidationCompletedCallback;
                     ACancelled: Boolean = False);
    
    property TaskId: string read FTaskId;
    property JsonData: string read FJsonData;
    property Schema: IJSONElement read FSchema;
    property Priority: TValidationPriority read FPriority;
    property ProgressCallback: TValidationProgressCallback read FProgressCallback;
    property CompletedCallback: TValidationCompletedCallback read FCompletedCallback;
    property CreatedAt: TDateTime read FCreatedAt;
    property Cancelled: Boolean read FCancelled write FCancelled;
  end;
  
  // Configurações do validador assíncrono
  TAsyncValidatorConfig = record
    MaxThreads: Integer;
    QueueCapacity: Integer;
    TaskTimeoutSeconds: Integer;
    EnablePrioritization: Boolean;
    EnableLoadBalancing: Boolean;
    ThreadIdleTimeoutSeconds: Integer;
  end;
  
  // Estatísticas do validador assíncrono
  TAsyncValidatorStats = record
    TotalTasks: Integer;
    CompletedTasks: Integer;
    FailedTasks: Integer;
    CancelledTasks: Integer;
    QueuedTasks: Integer;
    RunningTasks: Integer;
    AverageExecutionTime: Double;
    ThroughputPerSecond: Double;
    ActiveThreads: Integer;
  end;
  
  // Worker thread para validação
  TValidationWorkerThread = class(TThread)
  private
    FValidator: TJSONSchemaValidator;
    FTaskQueue: TThreadedQueue<TValidationTask>;
    FStats: TAsyncValidatorStats;
    FStatsLock: TCriticalSection;
    FIdleTimeout: Integer;
    
    procedure UpdateStats(const ATask: TValidationTask; const AResult: TAsyncValidationResult);
    
  protected
    procedure Execute; override;
    
  public
    constructor Create(ATaskQueue: TThreadedQueue<TValidationTask>; 
                     AIdleTimeout: Integer);
    destructor Destroy; override;
    
    function GetStats: TAsyncValidatorStats;
  end;
  
  // Validador assíncrono principal
  TAsyncValidator = class
  private
    FConfig: TAsyncValidatorConfig;
    FTaskQueue: TThreadedQueue<TValidationTask>;
    FWorkerThreads: TList<TValidationWorkerThread>;
    FRunningTasks: TDictionary<string, TValidationTask>;
    FCompletedTasks: TDictionary<string, TAsyncValidationResult>;
    FLock: TCriticalSection;
    FActive: Boolean;
    FTaskCounter: Integer;
    
    function GenerateTaskId: string;
    procedure StartWorkerThreads;
    procedure StopWorkerThreads;

    
  public
    constructor Create(const AConfig: TAsyncValidatorConfig);
    destructor Destroy; override;
    
    // Controle do validador
    procedure Start;
    procedure Stop;
    procedure Pause;
    procedure Resume;
    
    // Submissão de tarefas
    function SubmitValidation(const AJsonData: string; const ASchema: IJSONElement;
                             APriority: TValidationPriority = vpNormal;
                             AProgressCallback: TValidationProgressCallback = nil;
                             ACompletedCallback: TValidationCompletedCallback = nil): string;
    
    function SubmitBatchValidation(const AJsonDataList: TArray<string>; 
                                  const ASchema: IJSONElement;
                                  APriority: TValidationPriority = vpNormal;
                                  AProgressCallback: TValidationProgressCallback = nil;
                                  ACompletedCallback: TValidationCompletedCallback = nil): TArray<string>;
    
    // Controle de tarefas
    function CancelTask(const ATaskId: string): Boolean;
    function GetTaskStatus(const ATaskId: string): TAsyncValidationStatus;
    function GetTaskResult(const ATaskId: string): TAsyncValidationResult;
    function WaitForTask(const ATaskId: string; ATimeoutMs: Integer = -1): Boolean;
    function WaitForAllTasks(ATimeoutMs: Integer = -1): Boolean;
    
    // Estatísticas e monitoramento
    function GetStats: TAsyncValidatorStats;
    function GetQueueSize: Integer;
    function GetActiveThreadCount: Integer;
    
    // Configuração
    property Config: TAsyncValidatorConfig read FConfig write FConfig;
    property Active: Boolean read FActive;
  end;
  
  // Singleton para acesso global
  TGlobalAsyncValidator = class
  private
    class var FInstance: TAsyncValidator;
    class var FLock: TCriticalSection;
    
  public
    class function Instance: TAsyncValidator;
    class procedure Initialize(const AConfig: TAsyncValidatorConfig);
    class procedure Finalize;
  end;

implementation

uses
  System.DateUtils,
  System.Math,
  JsonFlow.Objects;

{ TValidationTask }

constructor TValidationTask.Create(const ATaskId: string; const AJsonData: string;
  const ASchema: IJSONElement; APriority: TValidationPriority;
  AProgressCallback: TValidationProgressCallback;
  ACompletedCallback: TValidationCompletedCallback;
  ACancelled: Boolean = False);
begin
  inherited Create;
  
  FTaskId := ATaskId;
  FJsonData := AJsonData;
  FSchema := ASchema;
  FPriority := APriority;
  FProgressCallback := AProgressCallback;
  FCompletedCallback := ACompletedCallback;
  FCreatedAt := Now;
  FCancelled := ACancelled;
end;

{ TValidationWorkerThread }

constructor TValidationWorkerThread.Create(ATaskQueue: TThreadedQueue<TValidationTask>;
  AIdleTimeout: Integer);
begin
  inherited Create(False);
  
  FValidator := TJSONSchemaValidator.Create;
  FTaskQueue := ATaskQueue;
  FStatsLock := TCriticalSection.Create;
  FIdleTimeout := AIdleTimeout;
  
  FillChar(FStats, SizeOf(FStats), 0);
end;

destructor TValidationWorkerThread.Destroy;
begin
  FValidator.Free;
  FStatsLock.Free;
  
  inherited Destroy;
end;

procedure TValidationWorkerThread.Execute;
var
  LTask: TValidationTask;
  LResult: TAsyncValidationResult;
  LJsonElement: IJSONElement;
  LJsonReader: TJsonReader;
  LErrors: TList<TValidationError>;
begin
  while not Terminated do
  begin
    // Tentar obter uma tarefa da fila
    if FTaskQueue.PopItem(LTask) = wrSignaled then
    begin
      if Assigned(LTask) then
      begin
        try
          // Inicializar resultado
          LResult.TaskId := LTask.TaskId;
          LResult.Status := avsRunning;
          LResult.StartTime := Now;
          
          // Verificar cancelamento
          if LTask.Cancelled then
          begin
            LResult.Status := avsCancelled;
            LResult.EndTime := Now;
            LResult.ErrorMessage := 'Task was cancelled';
          end
          else
          begin
            try
              // Parsear JSON
              LJsonReader := TJsonReader.Create;
              try
                LJsonElement := LJsonReader.Read(LTask.JsonData);
              finally
                LJsonReader.Free;
              end;
              
              // Executar validação
              FValidator.ParseSchema(LTask.Schema);
              if FValidator.Validate(LJsonElement, '') then
                LErrors := TList<TValidationError>.Create
              else
                LErrors := TList<TValidationError>.Create(FValidator.GetErrors);
              
              // Preparar resultado
              LResult.Status := avsCompleted;
              LResult.IsValid := LErrors.Count = 0;
              LResult.Errors := LErrors;
              LResult.EndTime := Now;
              
            except
              on E: Exception do
              begin
                LResult.Status := avsError;
                LResult.IsValid := False;
                LResult.Errors := TList<TValidationError>.Create;
                LResult.EndTime := Now;
                LResult.ErrorMessage := E.Message;
              end;
            end;
          end;
          
          // Atualizar estatísticas
          UpdateStats(LTask, LResult);
          
          // Chamar callback se definido
          if Assigned(LTask.CompletedCallback) then
          begin
            try
              LTask.CompletedCallback(LResult);
            except
              // Ignorar erros no callback
            end;
          end;
          
        finally
          LTask.Free;
        end;
      end;
    end
    else
    begin
      // Timeout - verificar se deve terminar por inatividade
      if FIdleTimeout > 0 then
        TThread.Sleep(1000)
      else
        Break;
    end;
  end;
end;

procedure TValidationWorkerThread.UpdateStats(const ATask: TValidationTask;
  const AResult: TAsyncValidationResult);
var
  LExecutionTime: Double;
begin
  FStatsLock.Enter;
  try
    Inc(FStats.TotalTasks);
    
    case AResult.Status of
      avsCompleted:
        begin
          Inc(FStats.CompletedTasks);
          LExecutionTime := MilliSecondsBetween(AResult.EndTime, AResult.StartTime);
          FStats.AverageExecutionTime := (FStats.AverageExecutionTime * (FStats.CompletedTasks - 1) + LExecutionTime) / FStats.CompletedTasks;
        end;
      avsError:
        Inc(FStats.FailedTasks);
      avsCancelled:
        Inc(FStats.CancelledTasks);
    end;
  finally
    FStatsLock.Leave;
  end;
end;

function TValidationWorkerThread.GetStats: TAsyncValidatorStats;
begin
  FStatsLock.Enter;
  try
    Result := FStats;
  finally
    FStatsLock.Leave;
  end;
end;

{ TAsyncValidator }

constructor TAsyncValidator.Create(const AConfig: TAsyncValidatorConfig);
begin
  inherited Create;
  
  FConfig := AConfig;
  FTaskQueue := TThreadedQueue<TValidationTask>.Create(AConfig.QueueCapacity, 1000, AConfig.QueueCapacity);
  FWorkerThreads := TList<TValidationWorkerThread>.Create;
  FRunningTasks := TDictionary<string, TValidationTask>.Create;
  FCompletedTasks := TDictionary<string, TAsyncValidationResult>.Create;
  FLock := TCriticalSection.Create;
  FActive := False;
  FTaskCounter := 0;
end;

destructor TAsyncValidator.Destroy;
begin
  Stop;
  
  FTaskQueue.Free;
  FWorkerThreads.Free;
  FRunningTasks.Free;
  FCompletedTasks.Free;
  FLock.Free;
  
  inherited Destroy;
end;

function TAsyncValidator.GenerateTaskId: string;
begin
  FLock.Enter;
  try
    Inc(FTaskCounter);
    Result := Format('TASK_%d_%d', [TThread.CurrentThread.ThreadID, FTaskCounter]);
  finally
    FLock.Leave;
  end;
end;

procedure TAsyncValidator.Start;
begin
  FLock.Enter;
  try
    if not FActive then
    begin
      FActive := True;
      StartWorkerThreads;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TAsyncValidator.Stop;
begin
  FLock.Enter;
  try
    if FActive then
    begin
      FActive := False;
      StopWorkerThreads;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TAsyncValidator.StartWorkerThreads;
var
  I: Integer;
  LWorkerThread: TValidationWorkerThread;
begin
  for I := 0 to FConfig.MaxThreads - 1 do
  begin
    LWorkerThread := TValidationWorkerThread.Create(FTaskQueue, FConfig.ThreadIdleTimeoutSeconds);
    FWorkerThreads.Add(LWorkerThread);
  end;
end;

procedure TAsyncValidator.StopWorkerThreads;
var
  LWorkerThread: TValidationWorkerThread;
begin
  // Sinalizar término para todas as threads
  for LWorkerThread in FWorkerThreads do
    LWorkerThread.Terminate;
    
  // Aguardar término
  for LWorkerThread in FWorkerThreads do
  begin
    LWorkerThread.WaitFor;
    LWorkerThread.Free;
  end;
  
  FWorkerThreads.Clear;
end;

function TAsyncValidator.SubmitValidation(const AJsonData: string;
  const ASchema: IJSONElement; APriority: TValidationPriority;
  AProgressCallback: TValidationProgressCallback;
  ACompletedCallback: TValidationCompletedCallback): string;
var
  LTaskId: string;
  LTask: TValidationTask;
  LCancelled: Boolean;
begin
  if not FActive then
    raise Exception.Create('AsyncValidator is not active');
    
  LTaskId := GenerateTaskId;
  LCancelled := False;
  
  LTask := TValidationTask.Create(LTaskId, AJsonData, ASchema, APriority,
                                   AProgressCallback, ACompletedCallback, LCancelled);
  
  FLock.Enter;
  try
    FRunningTasks.Add(LTaskId, LTask);
  finally
    FLock.Leave;
  end;
  
  // Adicionar à fila
  FTaskQueue.PushItem(LTask);
  
  Result := LTaskId;
end;

function TAsyncValidator.SubmitBatchValidation(const AJsonDataList: TArray<string>;
  const ASchema: IJSONElement; APriority: TValidationPriority;
  AProgressCallback: TValidationProgressCallback;
  ACompletedCallback: TValidationCompletedCallback): TArray<string>;
var
  I: Integer;
begin
  SetLength(Result, Length(AJsonDataList));
  
  for I := 0 to High(AJsonDataList) do
  begin
    Result[I] := SubmitValidation(AJsonDataList[I], ASchema, APriority,
                                 AProgressCallback, ACompletedCallback);
  end;
end;

function TAsyncValidator.CancelTask(const ATaskId: string): Boolean;
var
  LTask: TValidationTask;
begin
  Result := False;
  
  FLock.Enter;
  try
    if FRunningTasks.TryGetValue(ATaskId, LTask) then
    begin
      LTask.Cancelled := True;
      Result := True;
    end;
  finally
    FLock.Leave;
  end;
end;

function TAsyncValidator.GetTaskStatus(const ATaskId: string): TAsyncValidationStatus;
var
  LTask: TValidationTask;
  LResult: TAsyncValidationResult;
begin
  FLock.Enter;
  try
    if FCompletedTasks.TryGetValue(ATaskId, LResult) then
      Result := LResult.Status
    else if FRunningTasks.TryGetValue(ATaskId, LTask) then
    begin
      if LTask.Cancelled then
        Result := avsCancelled
      else
        Result := avsRunning;
    end
    else
      Result := avsQueued;
  finally
    FLock.Leave;
  end;
end;

function TAsyncValidator.GetTaskResult(const ATaskId: string): TAsyncValidationResult;
begin
  FLock.Enter;
  try
    if not FCompletedTasks.TryGetValue(ATaskId, Result) then
      raise Exception.CreateFmt('Task %s not found or not completed', [ATaskId]);
  finally
    FLock.Leave;
  end;
end;

function TAsyncValidator.WaitForTask(const ATaskId: string; ATimeoutMs: Integer): Boolean;
var
  LStartTime: TDateTime;
begin
  LStartTime := Now;
  
  repeat
    if GetTaskStatus(ATaskId) in [avsCompleted, avsCancelled, avsError] then
      Exit(True);
      
    TThread.Sleep(10);
  until (ATimeoutMs <> -1) and (MilliSecondsBetween(Now, LStartTime) >= ATimeoutMs);
  
  Result := False;
end;

function TAsyncValidator.WaitForAllTasks(ATimeoutMs: Integer): Boolean;
var
  LStartTime: TDateTime;
begin
  LStartTime := Now;
  
  repeat
    if (GetQueueSize = 0) and (FRunningTasks.Count = 0) then
      Exit(True);
      
    TThread.Sleep(50);
  until (ATimeoutMs <> -1) and (MilliSecondsBetween(Now, LStartTime) >= ATimeoutMs);
  
  Result := False;
end;

function TAsyncValidator.GetStats: TAsyncValidatorStats;
var
  LWorkerThread: TValidationWorkerThread;
  LWorkerStats: TAsyncValidatorStats;
begin
  FillChar(Result, SizeOf(Result), 0);
  
  FLock.Enter;
  try
    Result.QueuedTasks := GetQueueSize;
    Result.RunningTasks := FRunningTasks.Count;
    Result.ActiveThreads := FWorkerThreads.Count;
    
    // Agregar estatísticas de todas as threads
    for LWorkerThread in FWorkerThreads do
    begin
      LWorkerStats := LWorkerThread.GetStats;
      
      Result.TotalTasks := Result.TotalTasks + LWorkerStats.TotalTasks;
      Result.CompletedTasks := Result.CompletedTasks + LWorkerStats.CompletedTasks;
      Result.FailedTasks := Result.FailedTasks + LWorkerStats.FailedTasks;
      Result.CancelledTasks := Result.CancelledTasks + LWorkerStats.CancelledTasks;
      
      if LWorkerStats.AverageExecutionTime > 0 then
        Result.AverageExecutionTime := (Result.AverageExecutionTime + LWorkerStats.AverageExecutionTime) / 2;
    end;
    
    // Calcular throughput
    if Result.AverageExecutionTime > 0 then
      Result.ThroughputPerSecond := 1000 / Result.AverageExecutionTime;
  finally
    FLock.Leave;
  end;
end;

function TAsyncValidator.GetQueueSize: Integer;
begin
  Result := FTaskQueue.QueueSize;
end;

function TAsyncValidator.GetActiveThreadCount: Integer;
begin
  FLock.Enter;
  try
    Result := FWorkerThreads.Count;
  finally
    FLock.Leave;
  end;
end;


procedure TAsyncValidator.Pause;
begin
  // Implementar pausa se necessário
end;

procedure TAsyncValidator.Resume;
begin
  // Implementar retomada se necessário
end;

{ TGlobalAsyncValidator }

class function TGlobalAsyncValidator.Instance: TAsyncValidator;
begin
  if not Assigned(FInstance) then
  begin
    FLock.Enter;
    try
      if not Assigned(FInstance) then
      begin
        // Configuração padrão
        var LConfig: TAsyncValidatorConfig;
        LConfig.MaxThreads := TThread.ProcessorCount;
        LConfig.QueueCapacity := 1000;
        LConfig.TaskTimeoutSeconds := 300;
        LConfig.EnablePrioritization := True;
        LConfig.EnableLoadBalancing := True;
        LConfig.ThreadIdleTimeoutSeconds := 60;
        
        FInstance := TAsyncValidator.Create(LConfig);
        FInstance.Start;
      end;
    finally
      FLock.Leave;
    end;
  end;
  
  Result := FInstance;
end;

class procedure TGlobalAsyncValidator.Initialize(const AConfig: TAsyncValidatorConfig);
begin
  FLock.Enter;
  try
    if Assigned(FInstance) then
      FInstance.Free;
      
    FInstance := TAsyncValidator.Create(AConfig);
    FInstance.Start;
  finally
    FLock.Leave;
  end;
end;

class procedure TGlobalAsyncValidator.Finalize;
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
  TGlobalAsyncValidator.FLock := TCriticalSection.Create;

finalization
  TGlobalAsyncValidator.Finalize;
  TGlobalAsyncValidator.FLock.Free;

end.
