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
unit JsonFlow.Composer.Enhanced;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  System.Variants,
  JsonFlow.Interfaces;

type

  // Cache Statistics
  TCacheStats = record
    TotalEntries: Integer;
    HitCount: Integer;
    MissCount: Integer;
    HitRate: Double;
    MemoryUsage: Integer;
    MaxSize: Integer;
  end;

  // Cache Configuration
  TCacheConfiguration = record
    Enabled: Boolean;
    MaxSize: Integer;
    TTL: Integer; // Time to live in seconds
    AutoCleanup: Boolean;
    CleanupInterval: Integer; // minutes
    
    class function Default: TCacheConfiguration; static;
    class function HighPerformance: TCacheConfiguration; static;
    class function LowMemory: TCacheConfiguration; static;
  end;

  // Batch Operation Types
  TBatchOperationType = (botSetValue, botAddToArray, botRemoveKey, botInsertIntoArray, botReplaceInArray);

  // Batch Operation
  TBatchOperation = record
    OperationType: TBatchOperationType;
    Path: String;
    Value: Variant;
    Index: Integer; // For array operations
  end;

  // Batch Configuration
  TBatchConfiguration = record
    Enabled: Boolean;
    MaxOperations: Integer;
    AutoExecute: Boolean;
    AutoExecuteThreshold: Integer;
    
    class function Default: TBatchConfiguration; static;
    class function HighThroughput: TBatchConfiguration; static;
    class function LowLatency: TBatchConfiguration; static;
  end;

  // Performance Mode
  TPerformanceMode = (pmDefault, pmHighPerformance, pmLowMemory, pmBalanced);

  // Performance Configuration
  TPerformanceConfiguration = record
    Mode: TPerformanceMode;
    CacheConfig: TCacheConfiguration;
    BatchConfig: TBatchConfiguration;
    
    class function Default: TPerformanceConfiguration; static;
    class function HighPerformance: TPerformanceConfiguration; static;
    class function LowMemory: TPerformanceConfiguration; static;
    class function Balanced: TPerformanceConfiguration; static;
  end;

  // Performance Statistics
  TPerformanceStats = record
    CacheStats: TCacheStats;
    BatchOperationsExecuted: Integer;
    TotalOperations: Integer;
    AverageOperationTime: Double;
    MemoryUsage: Integer;
  end;

  // Cache Entry
  TPathCacheEntry = record
    Element: IJSONElement;
    Timestamp: TDateTime;
    AccessCount: Integer;
  end;

  // Enhanced JSON Composer
  TJSONComposerEnhanced = class
  private
    // Composer reference
    FComposer: IJSONComposer;
    
    // Cache fields
    FPathCache: TDictionary<String, TPathCacheEntry>;
    FCacheConfig: TCacheConfiguration;
    FCacheStats: TCacheStats;
    FLastCacheCleanup: TDateTime;
    
    // Batch fields
    FBatchOperations: TList<TBatchOperation>;
    FBatchConfig: TBatchConfiguration;
    FBatchMode: Boolean;
    FBatchLock: TCriticalSection;
    
    // Performance fields
    FPerformanceConfig: TPerformanceConfiguration;
    FPerformanceStats: TPerformanceStats;
    
    // Cache methods
    function _GetFromCache(const APath: String): IJSONElement;
    procedure _AddToCache(const APath: String; const AElement: IJSONElement);
    procedure _ClearCache;
    procedure _CleanupCache;
    procedure _UpdateCacheStats(const AHit: Boolean);
    
    // Batch methods
    procedure _ExecuteBatchOperations;
    procedure _AddBatchOperation(const AOperation: TBatchOperation);
    procedure _CheckAutoExecute;
    
    // Performance methods
    procedure _UpdatePerformanceStats;
    procedure _ApplyPerformanceMode(const AMode: TPerformanceMode);
  public
    constructor Create(const AComposer: IJSONComposer);
    destructor Destroy; override;
    
    // Configuration methods
    procedure ConfigureCache(const AConfig: TCacheConfiguration);
    procedure ConfigureBatch(const AConfig: TBatchConfiguration);
    procedure ConfigurePerformance(const AConfig: TPerformanceConfiguration);
    procedure SetPerformanceMode(const AMode: TPerformanceMode);
    
    // Cache methods
    procedure EnableCache(const AMaxSize: Integer = 1000);
    procedure DisableCache;
    procedure ClearCache;
    function GetCacheStats: TCacheStats;
    function GetCacheStatsAsString: String;
    
    // Batch methods
    procedure BeginBatch;
    procedure EndBatch;
    procedure ExecuteBatch;
    function IsBatchMode: Boolean;
    procedure AddBatchOperation(const AOperation: TBatchOperation);
    
    // Fast methods (using cache and batch)
    function SetValueFast(const APath: String; const AValue: Variant): Boolean;
    function AddToArrayFast(const APath: String; const AValue: Variant): Boolean;
    function RemoveKeyFast(const APath: String): Boolean;
    
    // Advanced array operations
    function InsertIntoArray(const APath: String; const AIndex: Integer; const AValue: Variant): Boolean;
    function ReplaceInArray(const APath: String; const AIndex: Integer; const AValue: Variant): Boolean;
    function RemoveFromArrayByIndex(const APath: String; const AIndex: Integer): Boolean;
    
    // Bulk operations
    function SetMultipleValues(const APathValuePairs: array of Variant): Boolean;
    function AddMultipleToArray(const APath: String; const AValues: array of Variant): Boolean;
    
    // Statistics
    function GetPerformanceStats: TPerformanceStats;
    function GetPerformanceStatsAsString: String;
    procedure ResetStats;
  end;

implementation

uses
  System.DateUtils,
  JsonFlow.Composer;

// Note: TJSONComposer is forward declared in interface section

{ TCacheConfiguration }

class function TCacheConfiguration.Default: TCacheConfiguration;
begin
  Result.Enabled := True;
  Result.MaxSize := 1000;
  Result.TTL := 300; // 5 minutes
  Result.AutoCleanup := True;
  Result.CleanupInterval := 10;
end;

class function TCacheConfiguration.HighPerformance: TCacheConfiguration;
begin
  Result.Enabled := True;
  Result.MaxSize := 5000;
  Result.TTL := 600; // 10 minutes
  Result.AutoCleanup := True;
  Result.CleanupInterval := 5;
end;

class function TCacheConfiguration.LowMemory: TCacheConfiguration;
begin
  Result.Enabled := True;
  Result.MaxSize := 100;
  Result.TTL := 60; // 1 minute
  Result.AutoCleanup := True;
  Result.CleanupInterval := 30;
end;

{ TBatchConfiguration }

class function TBatchConfiguration.Default: TBatchConfiguration;
begin
  Result.Enabled := True;
  Result.MaxOperations := 100;
  Result.AutoExecute := True;
  Result.AutoExecuteThreshold := 50;
end;

class function TBatchConfiguration.HighThroughput: TBatchConfiguration;
begin
  Result.Enabled := True;
  Result.MaxOperations := 1000;
  Result.AutoExecute := True;
  Result.AutoExecuteThreshold := 500;
end;

class function TBatchConfiguration.LowLatency: TBatchConfiguration;
begin
  Result.Enabled := True;
  Result.MaxOperations := 10;
  Result.AutoExecute := True;
  Result.AutoExecuteThreshold := 5;
end;

{ TPerformanceConfiguration }

class function TPerformanceConfiguration.Default: TPerformanceConfiguration;
begin
  Result.Mode := pmDefault;
  Result.CacheConfig := TCacheConfiguration.Default;
  Result.BatchConfig := TBatchConfiguration.Default;
end;

class function TPerformanceConfiguration.HighPerformance: TPerformanceConfiguration;
begin
  Result.Mode := pmHighPerformance;
  Result.CacheConfig := TCacheConfiguration.HighPerformance;
  Result.BatchConfig := TBatchConfiguration.HighThroughput;
end;

class function TPerformanceConfiguration.LowMemory: TPerformanceConfiguration;
begin
  Result.Mode := pmLowMemory;
  Result.CacheConfig := TCacheConfiguration.LowMemory;
  Result.BatchConfig := TBatchConfiguration.LowLatency;
end;

class function TPerformanceConfiguration.Balanced: TPerformanceConfiguration;
begin
  Result.Mode := pmBalanced;
  Result.CacheConfig := TCacheConfiguration.Default;
  Result.BatchConfig := TBatchConfiguration.Default;
end;

{ TJSONComposerEnhanced }

constructor TJSONComposerEnhanced.Create(const AComposer: IJSONComposer);
begin
  inherited Create;
  
  // Store composer reference
  FComposer := AComposer;
  
  // Initialize cache
  FPathCache := TDictionary<String, TPathCacheEntry>.Create;
  FCacheConfig := TCacheConfiguration.Default;
  FillChar(FCacheStats, SizeOf(FCacheStats), 0);
  FCacheStats.MaxSize := FCacheConfig.MaxSize;
  FLastCacheCleanup := Now;
  
  // Initialize batch
  FBatchOperations := TList<TBatchOperation>.Create;
  FBatchConfig := TBatchConfiguration.Default;
  FBatchMode := False;
  FBatchLock := TCriticalSection.Create;
  
  // Initialize performance
  FPerformanceConfig := TPerformanceConfiguration.Default;
  FillChar(FPerformanceStats, SizeOf(FPerformanceStats), 0);
end;

destructor TJSONComposerEnhanced.Destroy;
begin
  FPathCache.Free;
  FBatchOperations.Free;
  FBatchLock.Free;
  inherited;
end;

// Cache Methods

function TJSONComposerEnhanced._GetFromCache(const APath: String): IJSONElement;
var
  Entry: TPathCacheEntry;
begin
  Result := nil;
  
  if not FCacheConfig.Enabled then
  begin
    _UpdateCacheStats(False);
    Exit;
  end;
  
  if FPathCache.TryGetValue(APath, Entry) then
  begin
    // Check TTL
    if SecondsBetween(Now, Entry.Timestamp) <= FCacheConfig.TTL then
    begin
      Inc(Entry.AccessCount);
      FPathCache[APath] := Entry;
      Result := Entry.Element;
      _UpdateCacheStats(True);
    end
    else
    begin
      // Expired entry
      FPathCache.Remove(APath);
      _UpdateCacheStats(False);
    end;
  end
  else
    _UpdateCacheStats(False);
end;

procedure TJSONComposerEnhanced._AddToCache(const APath: String; const AElement: IJSONElement);
var
  Entry: TPathCacheEntry;
begin
  if not FCacheConfig.Enabled then Exit;
  if not Assigned(AElement) then Exit;
  
  // Check cache size limit
  if FPathCache.Count >= FCacheConfig.MaxSize then
    _CleanupCache;
  
  Entry.Element := AElement;
  Entry.Timestamp := Now;
  Entry.AccessCount := 1;
  
  FPathCache.AddOrSetValue(APath, Entry);
  FCacheStats.TotalEntries := FPathCache.Count;
end;

procedure TJSONComposerEnhanced._ClearCache;
begin
  FPathCache.Clear;
  FillChar(FCacheStats, SizeOf(FCacheStats), 0);
  FCacheStats.MaxSize := FCacheConfig.MaxSize;
end;

procedure TJSONComposerEnhanced._CleanupCache;
var
  PathsToRemove: TArray<String>;
  Path: String;
  Entry: TPathCacheEntry;
  I: Integer;
begin
  if not FCacheConfig.AutoCleanup then Exit;
  if MinutesBetween(Now, FLastCacheCleanup) < FCacheConfig.CleanupInterval then Exit;
  
  SetLength(PathsToRemove, 0);
  
  // Find expired entries
  for Path in FPathCache.Keys do
  begin
    if FPathCache.TryGetValue(Path, Entry) then
    begin
      if SecondsBetween(Now, Entry.Timestamp) > FCacheConfig.TTL then
      begin
        SetLength(PathsToRemove, Length(PathsToRemove) + 1);
        PathsToRemove[High(PathsToRemove)] := Path;
      end;
    end;
  end;
  
  // Remove expired entries
  for I := 0 to High(PathsToRemove) do
    FPathCache.Remove(PathsToRemove[I]);
  
  // If still over limit, remove least accessed entries
  while FPathCache.Count > FCacheConfig.MaxSize * 0.8 do
  begin
    // Simple cleanup - remove first entry (could be improved with LRU)
    for Path in FPathCache.Keys do
    begin
      FPathCache.Remove(Path);
      Break;
    end;
  end;
  
  FLastCacheCleanup := Now;
  FCacheStats.TotalEntries := FPathCache.Count;
end;

procedure TJSONComposerEnhanced._UpdateCacheStats(const AHit: Boolean);
begin
  if AHit then
    Inc(FCacheStats.HitCount)
  else
    Inc(FCacheStats.MissCount);
  
  if (FCacheStats.HitCount + FCacheStats.MissCount) > 0 then
    FCacheStats.HitRate := (FCacheStats.HitCount / (FCacheStats.HitCount + FCacheStats.MissCount)) * 100
  else
    FCacheStats.HitRate := 0;
end;

// Batch Methods

procedure TJSONComposerEnhanced._ExecuteBatchOperations;
var
  Operation: TBatchOperation;
begin
  FBatchLock.Enter;
  try
    for Operation in FBatchOperations do
    begin
      case Operation.OperationType of
        botSetValue:
          FComposer.SetValue(Operation.Path, Operation.Value);
        botAddToArray:
          FComposer.AddToArray(Operation.Path, Operation.Value);
        botRemoveKey:
          FComposer.RemoveKey(Operation.Path);
        botInsertIntoArray:
          ; // Implementation needed in base composer
        botReplaceInArray:
          ; // Implementation needed in base composer
      end;
    end;
    
    Inc(FPerformanceStats.BatchOperationsExecuted, FBatchOperations.Count);
    FBatchOperations.Clear;
  finally
    FBatchLock.Leave;
  end;
end;

procedure TJSONComposerEnhanced._AddBatchOperation(const AOperation: TBatchOperation);
begin
  if not FBatchConfig.Enabled then Exit;
  
  FBatchLock.Enter;
  try
    if FBatchOperations.Count >= FBatchConfig.MaxOperations then
      _ExecuteBatchOperations;
    
    FBatchOperations.Add(AOperation);
    _CheckAutoExecute;
  finally
    FBatchLock.Leave;
  end;
end;

procedure TJSONComposerEnhanced._CheckAutoExecute;
begin
  if FBatchConfig.AutoExecute and 
     (FBatchOperations.Count >= FBatchConfig.AutoExecuteThreshold) then
    _ExecuteBatchOperations;
end;

// Performance Methods

procedure TJSONComposerEnhanced._UpdatePerformanceStats;
begin
  Inc(FPerformanceStats.TotalOperations);
  FPerformanceStats.CacheStats := FCacheStats;
end;

procedure TJSONComposerEnhanced._ApplyPerformanceMode(const AMode: TPerformanceMode);
begin
  case AMode of
    pmHighPerformance:
    begin
      FCacheConfig := TCacheConfiguration.HighPerformance;
      FBatchConfig := TBatchConfiguration.HighThroughput;
    end;
    pmLowMemory:
    begin
      FCacheConfig := TCacheConfiguration.LowMemory;
      FBatchConfig := TBatchConfiguration.LowLatency;
    end;
    pmBalanced:
    begin
      FCacheConfig := TCacheConfiguration.Default;
      FBatchConfig := TBatchConfiguration.Default;
    end;
  end;
end;

// Public Methods

procedure TJSONComposerEnhanced.ConfigureCache(const AConfig: TCacheConfiguration);
begin
  FCacheConfig := AConfig;
  FCacheStats.MaxSize := AConfig.MaxSize;
  
  if not AConfig.Enabled then
    _ClearCache;
end;

procedure TJSONComposerEnhanced.ConfigureBatch(const AConfig: TBatchConfiguration);
begin
  FBatchConfig := AConfig;
  
  if not AConfig.Enabled then
  begin
    FBatchLock.Enter;
    try
      FBatchOperations.Clear;
      FBatchMode := False;
    finally
      FBatchLock.Leave;
    end;
  end;
end;

procedure TJSONComposerEnhanced.ConfigurePerformance(const AConfig: TPerformanceConfiguration);
begin
  FPerformanceConfig := AConfig;
  ConfigureCache(AConfig.CacheConfig);
  ConfigureBatch(AConfig.BatchConfig);
  _ApplyPerformanceMode(AConfig.Mode);
end;

procedure TJSONComposerEnhanced.SetPerformanceMode(const AMode: TPerformanceMode);
begin
  FPerformanceConfig.Mode := AMode;
  _ApplyPerformanceMode(AMode);
end;

procedure TJSONComposerEnhanced.EnableCache(const AMaxSize: Integer);
begin
  FCacheConfig.Enabled := True;
  FCacheConfig.MaxSize := AMaxSize;
  FCacheStats.MaxSize := AMaxSize;
end;

procedure TJSONComposerEnhanced.DisableCache;
begin
  FCacheConfig.Enabled := False;
  _ClearCache;
end;

procedure TJSONComposerEnhanced.ClearCache;
begin
  _ClearCache;
end;

function TJSONComposerEnhanced.GetCacheStats: TCacheStats;
begin
  Result := FCacheStats;
end;

function TJSONComposerEnhanced.GetCacheStatsAsString: String;
begin
  Result := Format(
    'Cache Stats:' + sLineBreak +
    '  Total Entries: %d' + sLineBreak +
    '  Hit Count: %d' + sLineBreak +
    '  Miss Count: %d' + sLineBreak +
    '  Hit Rate: %.2f%%' + sLineBreak +
    '  Max Size: %d',
    [FCacheStats.TotalEntries, FCacheStats.HitCount, FCacheStats.MissCount,
     FCacheStats.HitRate, FCacheStats.MaxSize]);
end;

procedure TJSONComposerEnhanced.BeginBatch;
begin
  FBatchMode := True;
end;

procedure TJSONComposerEnhanced.EndBatch;
begin
  if FBatchMode then
  begin
    _ExecuteBatchOperations;
    FBatchMode := False;
  end;
end;

procedure TJSONComposerEnhanced.ExecuteBatch;
begin
  _ExecuteBatchOperations;
end;

function TJSONComposerEnhanced.IsBatchMode: Boolean;
begin
  Result := FBatchMode;
end;

procedure TJSONComposerEnhanced.AddBatchOperation(const AOperation: TBatchOperation);
begin
  _AddBatchOperation(AOperation);
end;

function TJSONComposerEnhanced.SetValueFast(const APath: String; const AValue: Variant): Boolean;
var
  Operation: TBatchOperation;
begin
  Result := True;
  
  if FBatchMode then
  begin
    Operation.OperationType := botSetValue;
    Operation.Path := APath;
    Operation.Value := AValue;
    _AddBatchOperation(Operation);
  end
  else
  begin
    try
      FComposer.SetValue(APath, AValue);
      _UpdatePerformanceStats;
    except
      Result := False;
    end;
  end;
end;

function TJSONComposerEnhanced.AddToArrayFast(const APath: String; const AValue: Variant): Boolean;
var
  Operation: TBatchOperation;
begin
  Result := True;
  
  if FBatchMode then
  begin
    Operation.OperationType := botAddToArray;
    Operation.Path := APath;
    Operation.Value := AValue;
    _AddBatchOperation(Operation);
  end
  else
  begin
    try
      FComposer.AddToArray(APath, AValue);
      _UpdatePerformanceStats;
    except
      Result := False;
    end;
  end;
end;

function TJSONComposerEnhanced.RemoveKeyFast(const APath: String): Boolean;
var
  Operation: TBatchOperation;
begin
  Result := True;
  
  if FBatchMode then
  begin
    Operation.OperationType := botRemoveKey;
    Operation.Path := APath;
    _AddBatchOperation(Operation);
  end
  else
  begin
    try
      FComposer.RemoveKey(APath);
      _UpdatePerformanceStats;
    except
      Result := False;
    end;
  end;
end;

function TJSONComposerEnhanced.InsertIntoArray(const APath: String; const AIndex: Integer; const AValue: Variant): Boolean;
var
  Operation: TBatchOperation;
begin
  Result := True;
  
  if FBatchMode then
  begin
    Operation.OperationType := botInsertIntoArray;
    Operation.Path := APath;
    Operation.Value := AValue;
    Operation.Index := AIndex;
    _AddBatchOperation(Operation);
  end
  else
  begin
    // Direct implementation needed
    Result := False; // Not implemented yet
  end;
end;

function TJSONComposerEnhanced.ReplaceInArray(const APath: String; const AIndex: Integer; const AValue: Variant): Boolean;
var
  Operation: TBatchOperation;
begin
  Result := True;
  
  if FBatchMode then
  begin
    Operation.OperationType := botReplaceInArray;
    Operation.Path := APath;
    Operation.Value := AValue;
    Operation.Index := AIndex;
    _AddBatchOperation(Operation);
  end
  else
  begin
    // Direct implementation needed
    Result := False; // Not implemented yet
  end;
end;

function TJSONComposerEnhanced.RemoveFromArrayByIndex(const APath: String; const AIndex: Integer): Boolean;
begin
  // Implementation needed
  Result := False;
end;

function TJSONComposerEnhanced.SetMultipleValues(const APathValuePairs: array of Variant): Boolean;
var
  I: Integer;
begin
  Result := True;
  
  BeginBatch;
  try
    for I := 0 to High(APathValuePairs) div 2 do
    begin
      if not SetValueFast(VarToStr(APathValuePairs[I * 2]), APathValuePairs[I * 2 + 1]) then
      begin
        Result := False;
        Break;
      end;
    end;
  finally
    EndBatch;
  end;
end;

function TJSONComposerEnhanced.AddMultipleToArray(const APath: String; const AValues: array of Variant): Boolean;
var
  I: Integer;
begin
  Result := True;
  
  BeginBatch;
  try
    for I := 0 to High(AValues) do
    begin
      if not AddToArrayFast(APath, AValues[I]) then
      begin
        Result := False;
        Break;
      end;
    end;
  finally
    EndBatch;
  end;
end;

function TJSONComposerEnhanced.GetPerformanceStats: TPerformanceStats;
begin
  _UpdatePerformanceStats;
  Result := FPerformanceStats;
end;

function TJSONComposerEnhanced.GetPerformanceStatsAsString: String;
var
  Stats: TPerformanceStats;
begin
  Stats := GetPerformanceStats;
  Result := Format(
    'Performance Stats:' + sLineBreak +
    '  Total Operations: %d' + sLineBreak +
    '  Batch Operations Executed: %d' + sLineBreak +
    '  Cache Hit Rate: %.2f%%' + sLineBreak +
    '  Cache Entries: %d',
    [Stats.TotalOperations, Stats.BatchOperationsExecuted,
     Stats.CacheStats.HitRate, Stats.CacheStats.TotalEntries]);
end;

procedure TJSONComposerEnhanced.ResetStats;
begin
  FillChar(FPerformanceStats, SizeOf(FPerformanceStats), 0);
  FillChar(FCacheStats, SizeOf(FCacheStats), 0);
  FCacheStats.MaxSize := FCacheConfig.MaxSize;
end;

end.
