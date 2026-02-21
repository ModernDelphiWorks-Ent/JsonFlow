unit NativePerformanceDemo;

interface

uses
  System.SysUtils,
  System.Diagnostics,
  JsonFlow4D.Composer;

type
  TNativePerformanceDemo = class
  public
    class procedure RunDemo;
    class procedure DemonstrateCacheFeatures;
    class procedure DemonstrateBatchOperations;
    class procedure DemonstratePoolFeatures;
    class procedure DemonstrateFastMethods;
    class procedure DemonstrateOptimizations;
  end;

implementation

{ TNativePerformanceDemo }

class procedure TNativePerformanceDemo.RunDemo;
begin
  WriteLn('=== JsonFlow4D - Native Performance Features Demo ===');
  WriteLn;
  
  DemonstrateCacheFeatures;
  WriteLn;
  
  DemonstrateBatchOperations;
  WriteLn;
  
  DemonstratePoolFeatures;
  WriteLn;
  
  DemonstrateFastMethods;
  WriteLn;
  
  DemonstrateOptimizations;
  WriteLn;
  
  WriteLn('Demo completed!');
end;

class procedure TNativePerformanceDemo.DemonstrateCacheFeatures;
var
  LComposer: TJSONComposer;
  LStopwatch: TStopwatch;
  I: Integer;
begin
  WriteLn('1. Cache Features (Native Integration)');
  WriteLn('=====================================');
  
  LComposer := TJSONComposer.Create;
  try
    // Create a complex JSON structure
    LComposer
      .AddObject('user')
        .SetValue('user.name', 'John Doe')
        .SetValue('user.email', 'john@example.com')
        .AddObject('user.address')
          .SetValue('user.address.street', '123 Main St')
          .SetValue('user.address.city', 'New York')
          .SetValue('user.address.zipcode', '10001');
    
    // Enable cache for better performance
    LComposer.EnableCache(1000);
    
    WriteLn('Testing cache performance...');
    LStopwatch := TStopwatch.StartNew;
    
    // Multiple accesses to the same paths (cache will improve performance)
    for I := 1 to 1000 do
    begin
      LComposer.GetValue('user.name');
      LComposer.GetValue('user.address.city');
      LComposer.GetValue('user.address.zipcode');
    end;
    
    LStopwatch.Stop;
    WriteLn(Format('Time with cache: %d ms', [LStopwatch.ElapsedMilliseconds]));
    WriteLn(LComposer.GetCacheStatsAsString);
    
  finally
    LComposer.Free;
  end;
end;

class procedure TNativePerformanceDemo.DemonstrateBatchOperations;
var
  LComposer: TJSONComposer;
  LStopwatch: TStopwatch;
  I: Integer;
begin
  WriteLn('2. Batch Operations (Native Integration)');
  WriteLn('========================================');
  
  LComposer := TJSONComposer.Create;
  try
    WriteLn('Testing batch operations...');
    LStopwatch := TStopwatch.StartNew;
    
    // Begin batch mode for multiple operations
    LComposer.BeginBatch;
    
    // Add multiple items efficiently
    for I := 1 to 100 do
    begin
      LComposer.SetValueFast(Format('items[%d].id', [I]), I);
      LComposer.SetValueFast(Format('items[%d].name', [I]), Format('Item %d', [I]));
      LComposer.SetValueFast(Format('items[%d].active', [I]), True);
    end;
    
    // Execute all operations at once
    LComposer.EndBatch;
    
    LStopwatch.Stop;
    WriteLn(Format('Batch operations completed in: %d ms', [LStopwatch.ElapsedMilliseconds]));
    WriteLn(Format('JSON size: %d characters', [Length(LComposer.AsJSON)]));
    
  finally
    LComposer.Free;
  end;
end;

class procedure TNativePerformanceDemo.DemonstratePoolFeatures;
var
  LPool: TJSONComposerPool;
  LComposer1, LComposer2: TJSONComposer;
  LPooled: TPooledJSONComposer;
begin
  WriteLn('3. Pool Features (Native Integration)');
  WriteLn('====================================');
  
  // Manual pool usage
  LPool := TJSONComposerPool.Create(5);
  try
    WriteLn('Manual pool usage:');
    
    LComposer1 := LPool.BorrowComposer;
    LComposer1.SetValue('test', 'value1');
    WriteLn(Format('Borrowed composer 1: %s', [LComposer1.AsJSON]));
    
    LComposer2 := LPool.BorrowComposer;
    LComposer2.SetValue('test', 'value2');
    WriteLn(Format('Borrowed composer 2: %s', [LComposer2.AsJSON]));
    
    LPool.ReturnComposer(LComposer1);
    LPool.ReturnComposer(LComposer2);
    
    WriteLn(LPool.GetStatsAsString);
    
  finally
    LPool.Free;
  end;
  
  WriteLn;
  WriteLn('Automatic pooled composer:');
  
  // Automatic pooled composer (uses global pool)
  LPooled := TPooledJSONComposer.Create;
  try
    LPooled.SetValue('message', 'Using pooled composer automatically!');
    WriteLn(Format('Pooled composer: %s', [LPooled.AsJSON]));
  finally
    LPooled.Free; // Automatically returns to pool
  end;
end;

class procedure TNativePerformanceDemo.DemonstrateFastMethods;
var
  LComposer: TJSONComposer;
  LStopwatch: TStopwatch;
  I: Integer;
begin
  WriteLn('4. Fast Methods (Native Integration)');
  WriteLn('===================================');
  
  LComposer := TJSONComposer.Create;
  try
    LComposer.EnableCache(500).BeginBatch;
    
    WriteLn('Using fast methods with cache and batch...');
    LStopwatch := TStopwatch.StartNew;
    
    // Use fast methods for better performance
    for I := 1 to 50 do
    begin
      LComposer.SetValueFast(Format('products[%d].id', [I]), I);
      LComposer.SetValueFast(Format('products[%d].name', [I]), Format('Product %d', [I]));
      LComposer.AddToArrayFast('categories', Format('Category %d', [I mod 5 + 1]));
    end;
    
    LComposer.EndBatch;
    LStopwatch.Stop;
    
    WriteLn(Format('Fast methods completed in: %d ms', [LStopwatch.ElapsedMilliseconds]));
    WriteLn(LComposer.GetCacheStatsAsString);
    
    // Demonstrate advanced array operations
    LComposer.InsertIntoArray('categories', 0, 'First Category');
    LComposer.ReplaceInArray('categories', 1, 'Updated Category');
    LComposer.RemoveFromArrayByIndex('categories', 2);
    
    WriteLn('Advanced array operations completed.');
    
  finally
    LComposer.Free;
  end;
end;

class procedure TNativePerformanceDemo.DemonstrateOptimizations;
var
  LComposer: TJSONComposer;
begin
  WriteLn('5. Optimization Presets (Native Integration)');
  WriteLn('============================================');
  
  LComposer := TJSONComposer.Create;
  try
    WriteLn('Optimizing for reading...');
    LComposer.OptimizeForReading;
    
    // Add some data
    LComposer
      .SetValue('config.database.host', 'localhost')
      .SetValue('config.database.port', 5432)
      .SetValue('config.cache.enabled', True)
      .SetValue('config.cache.ttl', 3600);
    
    // Multiple reads (optimized with large cache)
    WriteLn(Format('Database host: %s', [VarToStr(LComposer.GetValue('config.database.host'))]));
    WriteLn(Format('Cache enabled: %s', [VarToStr(LComposer.GetValue('config.cache.enabled'))]));
    
    WriteLn;
    WriteLn('Optimizing for writing...');
    LComposer.Clear.OptimizeForWriting;
    
    // Multiple writes (optimized with batch mode)
    LComposer.SetMultipleValues([
      'settings.theme', 'dark',
      'settings.language', 'en',
      'settings.notifications', True,
      'settings.autoSave', False
    ]);
    
    LComposer.AddMultipleToArray('features', ['feature1', 'feature2', 'feature3']);
    
    WriteLn('Optimized writing completed.');
    WriteLn(Format('Final JSON: %s', [LComposer.AsJSON]));
    
  finally
    LComposer.Free;
  end;
end;

end.