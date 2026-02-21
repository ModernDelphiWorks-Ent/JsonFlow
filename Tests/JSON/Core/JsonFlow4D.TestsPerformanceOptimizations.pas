unit JsonFlow4D.TestsPerformanceOptimizations;

interface

uses
  System.SysUtils,
  System.Diagnostics,
  System.Generics.Collections,
  JsonFlow4D.Objects,
  JsonFlow4D.SchemaValidator,
  JsonFlow4D.ErrorListPool;

type
  TPerformanceTest = class
  private
    FValidator: TJSONSchemaValidator;
    FStopwatch: TStopwatch;
    procedure LogResult(const ATestName: String; AElapsedMs: Int64; AMemoryUsed: Int64);
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure RunAllTests;
    procedure TestSimpleValidation;
    procedure TestComplexSchemaValidation;
    procedure TestCircularReferenceHandling;
    procedure TestBatchValidation;
    procedure TestMemoryUsage;
    procedure TestErrorListPool;
  end;

implementation

{ TPerformanceTest }

constructor TPerformanceTest.Create;
begin
  FValidator := TJSONSchemaValidator.Create(jsvDraft7, nil);
  FValidator.LogLevel := llError; // Reduzir logging para testes de performance
  FStopwatch := TStopwatch.Create;
end;

destructor TPerformanceTest.Destroy;
begin
  FValidator.Free;
  inherited;
end;

procedure TPerformanceTest.LogResult(const ATestName: String; AElapsedMs: Int64; AMemoryUsed: Int64);
begin
  Writeln(Format('%s: %dms, Memory: %d bytes', [ATestName, AElapsedMs, AMemoryUsed]));
end;

procedure TPerformanceTest.TestErrorListPool;
var
  LStopwatch: TStopwatch;
  LPool: TErrorListPool;
  LList1, LList2: TList<TValidationError>;
  LPoolSize, LCreatedCount, LReuseCount: Integer;
  I: Integer;
begin
  Writeln('5. Teste do Pool de Listas de Erro');
  
  LStopwatch := TStopwatch.StartNew;
  LPool := TErrorListPool.Instance;
  
  // Teste de obtenção e retorno de listas
  for I := 1 to 1000 do
  begin
    LList1 := LPool.GetList;
    LList2 := LPool.GetList;
    
    // Simular uso das listas
    LList1.Add(TValidationError.Create('test', 'Test error 1'));
    LList2.Add(TValidationError.Create('test', 'Test error 2'));
    
    // Retornar ao pool
    LPool.ReturnList(LList1);
    LPool.ReturnList(LList2);
  end;
  
  LStopwatch.Stop;
  
  // Obter estatísticas
  LPool.GetStats(LPoolSize, LCreatedCount, LReuseCount);
  
  Writeln(Format('   Tempo: %d ms', [LStopwatch.ElapsedMilliseconds]));
  Writeln(Format('   Listas criadas: %d', [LCreatedCount]));
  Writeln(Format('   Reutilizações: %d', [LReuseCount]));
  Writeln(Format('   Tamanho atual do pool: %d', [LPoolSize]));
  Writeln(Format('   Taxa de reutilização: %.1f%%', [(LReuseCount / (LCreatedCount + LReuseCount)) * 100]));
  Writeln('');
end;

procedure TPerformanceTest.RunAllTests;
begin
  Writeln('=== JsonFlow4D Performance Tests - Fase 3 Optimizations ===');
  Writeln('');
  
  TestSimpleValidation;
  TestComplexSchemaValidation;
  TestCircularReferenceHandling;
  TestBatchValidation;
  TestMemoryUsage;
  TestErrorListPool;
  
  Writeln('');
  Writeln('=== Performance Tests Completed ===');
end;

procedure TPerformanceTest.TestSimpleValidation;
var
  LSchema, LData: String;
  LMemBefore, LMemAfter: Int64;
  I: Integer;
const
  ITERATIONS = 1000;
begin
  LSchema := '{
' +
    '  "type": "object",
' +
    '  "properties": {
' +
    '    "name": { "type": "string" },
' +
    '    "age": { "type": "integer", "minimum": 0 },
' +
    '    "email": { "type": "string", "format": "email" }
' +
    '  },
' +
    '  "required": ["name", "age"]
' +
    '}';
    
  LData := '{
' +
    '  "name": "John Doe",
' +
    '  "age": 30,
' +
    '  "email": "john@example.com"
' +
    '}';

  LMemBefore := GetHeapStatus.TotalAllocated;
  FStopwatch.Start;
  
  for I := 1 to ITERATIONS do
  begin
    FValidator.Validate(LData, LSchema);
    FValidator.ClearParsingCache; // Limpar cache entre validações
  end;
  
  FStopwatch.Stop;
  LMemAfter := GetHeapStatus.TotalAllocated;
  
  LogResult(Format('Simple Validation (%d iterations)', [ITERATIONS]), 
           FStopwatch.ElapsedMilliseconds, LMemAfter - LMemBefore);
  FStopwatch.Reset;
end;

procedure TPerformanceTest.TestComplexSchemaValidation;
var
  LSchema, LData: String;
  LMemBefore, LMemAfter: Int64;
begin
  LSchema := '{
' +
    '  "$defs": {
' +
    '    "person": {
' +
    '      "type": "object",
' +
    '      "properties": {
' +
    '        "name": { "type": "string" },
' +
    '        "age": { "type": "integer" },
' +
    '        "address": { "$ref": "#/$defs/address" }
' +
    '      }
' +
    '    },
' +
    '    "address": {
' +
    '      "type": "object",
' +
    '      "properties": {
' +
    '        "street": { "type": "string" },
' +
    '        "city": { "type": "string" },
' +
    '        "country": { "type": "string" }
' +
    '      }
' +
    '    }
' +
    '  },
' +
    '  "type": "array",
' +
    '  "items": { "$ref": "#/$defs/person" }
' +
    '}';
    
  LData := '[
' +
    '  {
' +
    '    "name": "Alice",
' +
    '    "age": 25,
' +
    '    "address": {
' +
    '      "street": "123 Main St",
' +
    '      "city": "New York",
' +
    '      "country": "USA"
' +
    '    }
' +
    '  },
' +
    '  {
' +
    '    "name": "Bob",
' +
    '    "age": 30,
' +
    '    "address": {
' +
    '      "street": "456 Oak Ave",
' +
    '      "city": "Los Angeles",
' +
    '      "country": "USA"
' +
    '    }
' +
    '  }
' +
    ']';

  LMemBefore := GetHeapStatus.TotalAllocated;
  FStopwatch.Start;
  
  FValidator.Validate(LData, LSchema);
  
  FStopwatch.Stop;
  LMemAfter := GetHeapStatus.TotalAllocated;
  
  LogResult('Complex Schema with References', 
           FStopwatch.ElapsedMilliseconds, LMemAfter - LMemBefore);
  FStopwatch.Reset;
end;

procedure TPerformanceTest.TestCircularReferenceHandling;
var
  LSchema, LData: String;
  LMemBefore, LMemAfter: Int64;
begin
  // Schema com referência circular potencial
  LSchema := '{
' +
    '  "$defs": {
' +
    '    "node": {
' +
    '      "type": "object",
' +
    '      "properties": {
' +
    '        "value": { "type": "string" },
' +
    '        "children": {
' +
    '          "type": "array",
' +
    '          "items": { "$ref": "#/$defs/node" }
' +
    '        }
' +
    '      }
' +
    '    }
' +
    '  },
' +
    '  "$ref": "#/$defs/node"
' +
    '}';
    
  LData := '{
' +
    '  "value": "root",
' +
    '  "children": [
' +
    '    {
' +
    '      "value": "child1",
' +
    '      "children": []
' +
    '    },
' +
    '    {
' +
    '      "value": "child2",
' +
    '      "children": [
' +
    '        {
' +
    '          "value": "grandchild",
' +
    '          "children": []
' +
    '        }
' +
    '      ]
' +
    '    }
' +
    '  ]
' +
    '}';

  LMemBefore := GetHeapStatus.TotalAllocated;
  FStopwatch.Start;
  
  FValidator.Validate(LData, LSchema);
  
  FStopwatch.Stop;
  LMemAfter := GetHeapStatus.TotalAllocated;
  
  LogResult('Circular Reference Handling', 
           FStopwatch.ElapsedMilliseconds, LMemAfter - LMemBefore);
  FStopwatch.Reset;
end;

procedure TPerformanceTest.TestBatchValidation;
var
  LSchema, LData: String;
  LMemBefore, LMemAfter: Int64;
  I: Integer;
const
  BATCH_SIZE = 100;
begin
  LSchema := '{
' +
    '  "type": "object",
' +
    '  "properties": {
' +
    '    "id": { "type": "integer" },
' +
    '    "data": { "type": "string" }
' +
    '  }
' +
    '}';

  LMemBefore := GetHeapStatus.TotalAllocated;
  FStopwatch.Start;
  
  for I := 1 to BATCH_SIZE do
  begin
    LData := Format('{ "id": %d, "data": "item_%d" }', [I, I]);
    FValidator.Validate(LData, LSchema);
  end;
  
  FStopwatch.Stop;
  LMemAfter := GetHeapStatus.TotalAllocated;
  
  LogResult(Format('Batch Validation (%d items)', [BATCH_SIZE]), 
           FStopwatch.ElapsedMilliseconds, LMemAfter - LMemBefore);
  FStopwatch.Reset;
end;

procedure TPerformanceTest.TestMemoryUsage;
var
  LSchema, LData: String;
  LMemBefore, LMemAfter, LMemPeak: Int64;
  I: Integer;
begin
  LSchema := '{
' +
    '  "type": "array",
' +
    '  "items": {
' +
    '    "type": "object",
' +
    '    "properties": {
' +
    '      "name": { "type": "string" },
' +
    '      "value": { "type": "number" }
' +
    '    }
' +
    '  }
' +
    '}';
    
  // Criar um array grande para testar uso de memória
  LData := '[';
  for I := 1 to 1000 do
  begin
    if I > 1 then
      LData := LData + ',';
    LData := LData + Format('{ "name": "item_%d", "value": %d }', [I, I]);
  end;
  LData := LData + ']';

  LMemBefore := GetHeapStatus.TotalAllocated;
  FStopwatch.Start;
  
  FValidator.Validate(LData, LSchema);
  
  FStopwatch.Stop;
  LMemAfter := GetHeapStatus.TotalAllocated;
  LMemPeak := GetHeapStatus.TotalAllocated;
  
  LogResult('Large Array Validation (1000 items)', 
           FStopwatch.ElapsedMilliseconds, LMemAfter - LMemBefore);
  Writeln(Format('Peak Memory Usage: %d bytes', [LMemPeak]));
  FStopwatch.Reset;
end;

end.
