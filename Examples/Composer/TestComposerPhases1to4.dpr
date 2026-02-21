program TestComposerPhases1to4;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Variants,
  System.DateUtils,
  System.TimeSpan,
  JsonFlow4D.Composer,
  JsonFlow4D.Interfaces;

procedure TestPhase1_FluentSyntax;
var
  LComposer: TJSONComposer;
  LJson: String;
begin
  WriteLn('=== FASE 1: SINTAXE FLUENTE MODERNA ===');
  
  LComposer := TJSONComposer.Create;
  try
    // Teste dos métodos de conveniência
    LComposer
      .BeginObject
        .StringValue('name', 'João Silva')
        .IntegerValue('age', 30)
        .BooleanValue('active', True)
        .NumberValue('salary', 5500.50)
        .DateTimeValue('birthDate', EncodeDate(1993, 5, 15))
        .NullValue('middleName')
      .EndObject;
    
    LJson := LComposer.ToJSON(True);
    WriteLn('JSON com métodos de conveniência:');
    WriteLn(LJson);
    WriteLn;
    
    // Teste com callbacks para estruturas aninhadas
    LComposer.Clear;
    LComposer
      .BeginObject
        .StringValue('company', 'TechCorp')
        .ObjectValue('address', procedure(const ABuilder: TJSONComposer)
        begin
          ABuilder
            .StringValue('street', 'Rua das Flores, 123')
            .StringValue('city', 'São Paulo')
            .StringValue('zipCode', '01234-567');
        end)
        .ArrayValue('employees', procedure(const ABuilder: TJSONComposer)
        begin
          ABuilder
            .BeginObject
              .StringValue('name', 'Ana')
              .IntegerValue('id', 1)
            .EndObject
            .BeginObject
              .StringValue('name', 'Carlos')
              .IntegerValue('id', 2)
            .EndObject;
        end)
      .EndObject;
    
    LJson := LComposer.ToJSON(True);
    WriteLn('JSON com callbacks para estruturas aninhadas:');
    WriteLn(LJson);
    WriteLn;
    
  finally
    LComposer.Free;
  end;
end;

procedure TestPhase2_ContextAware;
var
  LComposer: TJSONComposer;
  LContextInfo: TContextInfo;
  LTrace: TArray<String>;
  I: Integer;
begin
  WriteLn('=== FASE 2: CONTEXT-AWARE FEATURES ===');
  
  LComposer := TJSONComposer.Create;
  try
    LComposer.EnableDebugMode(True);
    
    LComposer
      .BeginObject
        .StringValue('rootProperty', 'value')
        .BeginObject('nestedObject')
          .StringValue('nestedProperty', 'nestedValue')
        .EndObject
      .EndObject;
    
    // Teste de informações de contexto
    LContextInfo := LComposer.GetContextInfo;
    WriteLn('Informações de Contexto:');
    WriteLn('  Current Path: ', LContextInfo.CurrentPath);
    WriteLn('  Context Type: ', LContextInfo.ContextType);
    WriteLn('  Depth: ', LContextInfo.Depth);
    WriteLn('  Parent Key: ', LContextInfo.ParentKey);
    WriteLn;
    
    // Teste de trace de composição
    LTrace := LComposer.GetCompositionTrace;
    WriteLn('Trace de Composição:');
    for I := 0 to Length(LTrace) - 1 do
      WriteLn('  ', LTrace[I]);
    WriteLn;
    
  finally
    LComposer.Free;
  end;
end;

procedure TestPhase3_SmartSuggestions;
var
  LComposer: TJSONComposer;
  LSuggestions: TArray<TJSONSuggestion>;
  LKeys: TArray<String>;
  LValues: TArray<Variant>;
  LErrors: TArray<String>;
  I: Integer;
begin
  WriteLn('=== FASE 3: SMART SUGGESTIONS ===');
  
  LComposer := TJSONComposer.Create;
  try
    LComposer.EnableRealTimeValidation(True);
    
    LComposer.BeginObject;
    
    // Teste de sugestões
    LSuggestions := LComposer.GetSuggestions;
    WriteLn('Sugestões disponíveis:');
    for I := 0 to Length(LSuggestions) - 1 do
    begin
      WriteLn('  Tipo: ', LSuggestions[I].SuggestionType);
      WriteLn('  Valor: ', LSuggestions[I].Value);
      WriteLn('  Descrição: ', LSuggestions[I].Description);
      WriteLn('  Contexto: ', LSuggestions[I].Context);
      WriteLn;
    end;
    
    // Teste de sugestões de valores
    LValues := LComposer.SuggestValues('userName');
    WriteLn('Sugestões para "userName":');
    for I := 0 to Length(LValues) - 1 do
      WriteLn('  ', VarToStr(LValues[I]));
    WriteLn;
    
    LValues := LComposer.SuggestValues('userAge');
    WriteLn('Sugestões para "userAge":');
    for I := 0 to Length(LValues) - 1 do
      WriteLn('  ', VarToStr(LValues[I]));
    WriteLn;
    
    // Teste de validação
    WriteLn('Validação rápida: ', BoolToStr(LComposer.QuickValidate, True));
    
    LErrors := LComposer.ValidateStructure;
    if Length(LErrors) > 0 then
    begin
      WriteLn('Erros de estrutura encontrados:');
      for I := 0 to Length(LErrors) - 1 do
        WriteLn('  ', LErrors[I]);
    end
    else
      WriteLn('Nenhum erro de estrutura encontrado.');
    WriteLn;
    
  finally
    LComposer.Free;
  end;
end;

procedure TestPhase4_Performance;
var
  LComposer: TJSONComposer;
  LPerformance: TPerformanceInfo;
  LBenchmark: TTimeSpan;
begin
  WriteLn('=== FASE 4: PERFORMANCE E RECURSOS AVANÇADOS ===');
  
  LComposer := TJSONComposer.Create;
  try
    // Teste de benchmark
    LBenchmark := LComposer.Benchmark(procedure
    begin
      LComposer
        .BeginObject
          .StringValue('test', 'performance')
          .IntegerValue('iterations', 1000)
          .BeginArray('data')
            .BeginObject
              .StringValue('item1', 'value1')
            .EndObject
            .BeginObject
              .StringValue('item2', 'value2')
            .EndObject
          .EndArray
        .EndObject;
    end);
    
    WriteLn('Tempo de benchmark: ', LBenchmark.TotalMilliseconds:0:2, ' ms');
    WriteLn;
    
    // Teste de métricas de performance
    LPerformance := LComposer.GetPerformanceMetrics;
    WriteLn('Métricas de Performance:');
    WriteLn('  Criado em: ', DateTimeToStr(LPerformance.CreationTime));
    WriteLn('  Última modificação: ', DateTimeToStr(LPerformance.LastModified));
    WriteLn('  Operações realizadas: ', LPerformance.OperationCount);
    WriteLn('  Uso de memória estimado: ', LPerformance.MemoryUsage, ' bytes');
    WriteLn('  Tempo de build: ', LPerformance.BuildTime.TotalMilliseconds:0:2, ' ms');
    WriteLn;
    
    // Teste de otimização de memória
    LComposer.OptimizeMemory;
    WriteLn('Otimização de memória executada.');
    WriteLn;
    
    // Teste de lazy loading
    LComposer.EnableLazyLoading(True);
    WriteLn('Lazy loading habilitado.');
    WriteLn;
    
  finally
    LComposer.Free;
  end;
end;

procedure TestFactoryMethods;
var
  LComposer1, LComposer2, LComposer3: TJSONComposer;
  LJson: String;
begin
  WriteLn('=== FACTORY METHODS ===');
  
  // Teste CreateForObject
  LComposer1 := TJSONComposer.CreateForObject;
  try
    LComposer1
      .StringValue('type', 'object')
      .StringValue('created', 'via factory');
    LComposer1.EndObject;
    
    LJson := LComposer1.ToJSON(True);
    WriteLn('CreateForObject:');
    WriteLn(LJson);
    WriteLn;
  finally
    LComposer1.Free;
  end;
  
  // Teste CreateForArray
  LComposer2 := TJSONComposer.CreateForArray;
  try
    LComposer2
      .BeginObject
        .StringValue('item', 'first')
      .EndObject
      .BeginObject
        .StringValue('item', 'second')
      .EndObject;
    LComposer2.EndArray;
    
    LJson := LComposer2.ToJSON(True);
    WriteLn('CreateForArray:');
    WriteLn(LJson);
    WriteLn;
  finally
    LComposer2.Free;
  end;
  
  // Teste CreateFromJSON
  LComposer3 := TJSONComposer.CreateFromJSON('{"loaded": true, "from": "json"}');
  try
    LJson := LComposer3.ToJSON(True);
    WriteLn('CreateFromJSON:');
    WriteLn(LJson);
    WriteLn;
  finally
    LComposer3.Free;
  end;
end;

begin
  try
    WriteLn('JsonFlow4D - Teste Completo das Fases 1-4 do Composer Aprimorado');
    WriteLn('================================================================');
    WriteLn;
    
    TestPhase1_FluentSyntax;
    TestPhase2_ContextAware;
    TestPhase3_SmartSuggestions;
    TestPhase4_Performance;
    TestFactoryMethods;
    
    WriteLn('================================================================');
    WriteLn('Todos os testes das fases 1-4 foram executados com sucesso!');
    WriteLn('Pressione ENTER para sair...');
    ReadLn;
    
  except
    on E: Exception do
    begin
      WriteLn('Erro: ', E.ClassName, ': ', E.Message);
      WriteLn('Pressione ENTER para sair...');
      ReadLn;
    end;
  end;
end.
