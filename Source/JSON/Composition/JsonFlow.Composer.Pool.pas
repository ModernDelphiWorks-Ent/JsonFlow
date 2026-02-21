unit JsonFlow.Composer.Pool;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  JsonFlow4D.Interfaces;

type
  // Pool Statistics
  TPoolStats = record
    TotalCreated: Integer;
    TotalDestroyed: Integer;
    CurrentInPool: Integer;
    CurrentInUse: Integer;
    MaxPoolSize: Integer;
    HitRate: Double;
    TotalBorrows: Integer;
    TotalReturns: Integer;
  end;

  // Pool Configuration
  TPoolConfiguration = record
    MaxSize: Integer;
    PreAllocate: Integer;
    AutoCleanup: Boolean;
    CleanupInterval: Integer; // minutes
    EnableStats: Boolean;
    
    class function Default: TPoolConfiguration; static;
  end;

  // JSON Composer Pool
  TJSONComposerPool = class
  private
    FPool: TList<IJSONComposer>;
    FInUse: TList<IJSONComposer>;
    FLock: TCriticalSection;
    FStats: TPoolStats;
    FConfig: TPoolConfiguration;
    FCreateComposerFunc: TFunc<IJSONComposer>;
    
    function _CreateComposer: IJSONComposer;
    procedure _UpdateStats;
  public
    constructor Create(const ACreateFunc: TFunc<IJSONComposer> = nil);
    destructor Destroy; override;
    
    function BorrowComposer: IJSONComposer;
    procedure ReturnComposer(const AComposer: IJSONComposer);
    function GetStats: TPoolStats;
    function GetStatsAsString: String;
    procedure Clear;
    procedure Configure(const AConfig: TPoolConfiguration);
  end;

  // Pooled Composer with automatic return
  TPooledJSONComposer = class
  private
    FPool: TJSONComposerPool;
    FComposer: IJSONComposer;
  public
    constructor Create(const APool: TJSONComposerPool);
    destructor Destroy; override;
    
    property Composer: IJSONComposer read FComposer;
  end;

  // Global Pool Singleton
  TGlobalJSONComposerPool = class
  private
    class var FInstance: TJSONComposerPool;
    class var FLock: TCriticalSection;
  public
    class function Instance: TJSONComposerPool;
    class procedure FreeInstance;
    class procedure Configure(const AConfig: TPoolConfiguration);
    class constructor Create;
    class destructor Destroy;
  end;

implementation

uses
  JsonFlow4D.Composer; // Agora podemos usar sem dependência circular

// TPoolConfiguration
class function TPoolConfiguration.Default: TPoolConfiguration;
begin
  Result.MaxSize := 10;
  Result.PreAllocate := 2;
  Result.AutoCleanup := True;
  Result.CleanupInterval := 30;
  Result.EnableStats := True;
end;

// TJSONComposerPool
constructor TJSONComposerPool.Create(const ACreateFunc: TFunc<IJSONComposer>);
var
  I: Integer;
begin
  inherited Create;
  FPool := TList<IJSONComposer>.Create;
  FInUse := TList<IJSONComposer>.Create;
  FLock := TCriticalSection.Create;
  FConfig := TPoolConfiguration.Default;
  FCreateComposerFunc := ACreateFunc;
  
  // Pre-allocate composers
  for I := 0 to FConfig.PreAllocate - 1 do
    FPool.Add(_CreateComposer);
    
  FStats.MaxPoolSize := FConfig.MaxSize;
end;

destructor TJSONComposerPool.Destroy;
begin
  Clear;
  FPool.Free;
  FInUse.Free;
  FLock.Free;
  inherited;
end;

function TJSONComposerPool._CreateComposer: IJSONComposer;
begin
  if Assigned(FCreateComposerFunc) then
    Result := FCreateComposerFunc()
  else
    Result := TJSONComposer.Create;
    
  Inc(FStats.TotalCreated);
end;

procedure TJSONComposerPool._UpdateStats;
begin
  FStats.CurrentInPool := FPool.Count;
  FStats.CurrentInUse := FInUse.Count;
  
  if FStats.TotalBorrows > 0 then
    FStats.HitRate := (FStats.TotalBorrows - FStats.TotalCreated) / FStats.TotalBorrows * 100
  else
    FStats.HitRate := 0;
end;

function TJSONComposerPool.BorrowComposer: IJSONComposer;
begin
  FLock.Enter;
  try
    if FPool.Count > 0 then
    begin
      Result := FPool.Last;
      FPool.Delete(FPool.Count - 1);
    end
    else
      Result := _CreateComposer;
      
    FInUse.Add(Result);
    Inc(FStats.TotalBorrows);
    _UpdateStats;
  finally
    FLock.Leave;
  end;
end;

procedure TJSONComposerPool.ReturnComposer(const AComposer: IJSONComposer);
var
  LIndex: Integer;
begin
  if not Assigned(AComposer) then
    Exit;
    
  FLock.Enter;
  try
    LIndex := FInUse.IndexOf(AComposer);
    if LIndex >= 0 then
    begin
      FInUse.Delete(LIndex);
      
      // Clear the composer and return to pool if there's space
      AComposer.Clear;
      if FPool.Count < FConfig.MaxSize then
        FPool.Add(AComposer);
        
      Inc(FStats.TotalReturns);
      _UpdateStats;
    end;
  finally
    FLock.Leave;
  end;
end;

function TJSONComposerPool.GetStats: TPoolStats;
begin
  FLock.Enter;
  try
    _UpdateStats;
    Result := FStats;
  finally
    FLock.Leave;
  end;
end;

function TJSONComposerPool.GetStatsAsString: String;
var
  LStats: TPoolStats;
begin
  LStats := GetStats;
  Result := Format('Pool Stats: Created=%d, InPool=%d, InUse=%d, HitRate=%.1f%%',
    [LStats.TotalCreated, LStats.CurrentInPool, LStats.CurrentInUse, LStats.HitRate]);
end;

procedure TJSONComposerPool.Clear;
begin
  FLock.Enter;
  try
    FPool.Clear;
    FInUse.Clear;
    FStats.TotalDestroyed := FStats.TotalCreated;
    FStats.TotalCreated := 0;
    FStats.TotalBorrows := 0;
    FStats.TotalReturns := 0;
  finally
    FLock.Leave;
  end;
end;

procedure TJSONComposerPool.Configure(const AConfig: TPoolConfiguration);
begin
  FLock.Enter;
  try
    FConfig := AConfig;
    FStats.MaxPoolSize := AConfig.MaxSize;
  finally
    FLock.Leave;
  end;
end;

// TPooledJSONComposer
constructor TPooledJSONComposer.Create(const APool: TJSONComposerPool);
begin
  inherited Create;
  FPool := APool;
  FComposer := FPool.BorrowComposer;
end;

destructor TPooledJSONComposer.Destroy;
begin
  if Assigned(FPool) and Assigned(FComposer) then
    FPool.ReturnComposer(FComposer);
  inherited;
end;

// TGlobalJSONComposerPool
class constructor TGlobalJSONComposerPool.Create;
begin
  FLock := TCriticalSection.Create;
end;

class destructor TGlobalJSONComposerPool.Destroy;
begin
  FreeInstance;
  FLock.Free;
end;

class function TGlobalJSONComposerPool.Instance: TJSONComposerPool;
begin
  if not Assigned(FInstance) then
  begin
    FLock.Enter;
    try
      if not Assigned(FInstance) then
        FInstance := TJSONComposerPool.Create;
    finally
      FLock.Leave;
    end;
  end;
  Result := FInstance;
end;

class procedure TGlobalJSONComposerPool.FreeInstance;
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

class procedure TGlobalJSONComposerPool.Configure(const AConfig: TPoolConfiguration);
begin
  Instance.Configure(AConfig);
end;

end.