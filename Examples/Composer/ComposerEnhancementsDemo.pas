unit ComposerEnhancementsDemo;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Diagnostics,
  JsonFlow4D.Composer,
  JsonFlow4D.Composer.Pool,
  JsonFlow4D.Composer.Enhanced;

type
  TComposerEnhancementsDemo = class
  public
    // Demonstrações do Pool de Objetos
    class procedure DemoObjectPool;
    class procedure DemoGlobalPool;
    class procedure DemoPooledWrapper;
    
    // Demonstrações do Composer Enhanced
    class procedure DemoEnhancedComposer;
    class procedure DemoCachePerformance;
    class procedure DemoBatchOperations;
    class procedure DemoArrayOperations;
    
    // Comparações de Performance
    class procedure ComparePoolVsNormal;
    class procedure CompareCacheVsNormal;
    class procedure CompareBatchVsIndividual;
    
    // Exemplo de uso em aplicação real
    class procedure RealWorldExample;
  end;

implementation

{ TComposerEnhancementsDemo }

class procedure TComposerEnhancementsDemo.DemoObjectPool;
var
  Pool: TJSONComposerPool;
  Composer1, Composer2, Composer3: TJSONComposer;
  I: Integer;
begin
  WriteLn('=== Demo: Object Pool ===');
  
  Pool := TJSONComposerPool.Create(5); // Pool com máximo 5 objetos
  try
    WriteLn('Pool criado com tamanho máximo: ', Pool.MaxSize);
    
    // Pegar objetos do pool
    Composer1 := Pool.Borrow;
    Composer2 := Pool.Borrow;
    Composer3 := Pool.Borrow;
    
    WriteLn('Objetos emprestados: 3');
    WriteLn('Taxa de hit atual: ', Pool.GetHitRate:0:2, '%');
    WriteLn('Objetos criados: ', Pool.GetCreatedCount);
    
    // Usar os composers
    Composer1.BeginObject
      .Add('name', 'João')
      .Add('age', 30)
    .EndObject;
    
    Composer2.BeginArray
      .Add('', 'item1')
      .Add('', 'item2')
    .EndArray;
    
    WriteLn('JSON 1: ', Composer1.ToJSON);
    WriteLn('JSON 2: ', Composer2.ToJSON);
    
    // Retornar ao pool
    Pool.Return(Composer1);
    Pool.Return(Composer2);
    Pool.Return(Composer3);
    
    WriteLn('Objetos retornados ao pool');
    WriteLn('Tamanho atual do pool: ', Pool.GetCurrentSize);
    
    // Reutilizar objetos do pool
    for I := 1 to 10 do
    begin
      Composer1 := Pool.Borrow;
      Composer1.BeginObject.Add('iteration', I).EndObject;
      Pool.Return(Composer1);
    end;
    
    WriteLn('Após 10 reutilizações:');
    WriteLn('Taxa de hit: ', Pool.GetHitRate:0:2, '%');
    WriteLn('Total de objetos criados: ', Pool.GetCreatedCount);
    WriteLn('Total de empréstimos: ', Pool.GetBorrowedCount);
    
  finally
    Pool.Free;
  end;
  
  WriteLn;
end;

class procedure TComposerEnhancementsDemo.DemoGlobalPool;
var
  Composer: TJSONComposer;
  I: Integer;
begin
  WriteLn('=== Demo: Global Pool ===');
  
  // Usar pool global singleton
  for I := 1 to 5 do
  begin
    Composer := TGlobalJSONComposerPool.Instance.Borrow;
    try
      Composer.BeginObject
        .Add('id', I)
        .Add('message', 'Hello from global pool')
      .EndObject;
      
      WriteLn('Iteração ', I, ': ', Composer.ToJSON);
    finally
      TGlobalJSONComposerPool.Instance.Return(Composer);
    end;
  end;
  
  WriteLn('Taxa de hit do pool global: ', 
    TGlobalJSONComposerPool.Instance.GetHitRate:0:2, '%');
  WriteLn;
end;

class procedure TComposerEnhancementsDemo.DemoPooledWrapper;
var
  Pool: TJSONComposerPool;
  PooledComposer: TPooledJSONComposer;
begin
  WriteLn('=== Demo: Pooled Wrapper ===');
  
  Pool := TJSONComposerPool.Create(3);
  try
    // Wrapper gerencia automaticamente o empréstimo/retorno
    PooledComposer := TPooledJSONComposer.Create(Pool);
    try
      PooledComposer.Composer
        .BeginObject
          .Add('wrapper', 'automatic')
          .Add('management', True)
        .EndObject;
      
      WriteLn('JSON com wrapper: ', PooledComposer.Composer.ToJSON);
    finally
      PooledComposer.Free; // Automaticamente retorna ao pool
    end;
    
    WriteLn('Objeto retornado automaticamente ao pool');
    WriteLn('Pool size: ', Pool.GetCurrentSize);
    
  finally
    Pool.Free;
  end;
  
  WriteLn;
end;

class procedure TComposerEnhancementsDemo.DemoEnhancedComposer;
var
  Enhanced: TJSONComposerEnhanced;
  JSON: String;
begin
  WriteLn('=== Demo: Enhanced Composer ===');
  
  Enhanced := TJSONComposerEnhanced.Create;
  try
    // Criar JSON inicial
    JSON := '{
' +
      '  "user": {
' +
      '    "name": "João",
' +
      '    "age": 30,
' +
      '    "hobbies": ["leitura", "música"]
' +
      '  },
' +
      '  "settings": {
' +
      '    "theme": "dark"
' +
      '  }
' +
      '}';
    
    Enhanced.LoadJSON(JSON);
    WriteLn('JSON inicial carregado');
    
    // Usar métodos enhanced com cache
    Enhanced.SetValueFast('user.age', 31);
    Enhanced.SetValueFast('user.city', 'São Paulo');
    Enhanced.AddToArrayFast('user.hobbies', 'programação');
    
    WriteLn('Modificações aplicadas com cache');
    WriteLn('Stats do cache: ', Enhanced.GetCacheStats);
    
    WriteLn('JSON modificado:');
    WriteLn(Enhanced.ToJSON(True));
    
  finally
    Enhanced.Free;
  end;
  
  WriteLn;
end;

class procedure TComposerEnhancementsDemo.DemoCachePerformance;
var
  Enhanced: TJSONComposerEnhanced;
  Stopwatch: TStopwatch;
  I: Integer;
  JSON: String;
begin
  WriteLn('=== Demo: Cache Performance ===');
  
  Enhanced := TJSONComposerEnhanced.Create;
  try
    // JSON com estrutura complexa
    JSON := '{
' +
      '  "data": {
' +
      '    "users": [
' +
      '      {"id": 1, "name": "User1"},
' +
      '      {"id": 2, "name": "User2"},
' +
      '      {"id": 3, "name": "User3"}
' +
      '    ],
' +
      '    "config": {
' +
      '      "version": "1.0",
' +
      '      "features": ["cache", "pool"]
' +
      '    }
' +
      '  }
' +
      '}';
    
    Enhanced.LoadJSON(JSON);
    Enhanced.OptimizeForReading; // Otimizar para leitura
    
    // Teste com cache habilitado
    Stopwatch := TStopwatch.StartNew;
    for I := 1 to 1000 do
    begin
      Enhanced.SetValueFast('data.users[0].name', 'User' + I.ToString);
      Enhanced.SetValueFast('data.config.version', '1.' + I.ToString);
    end;
    Stopwatch.Stop;
    
    WriteLn('1000 operações COM cache: ', Stopwatch.ElapsedMilliseconds, 'ms');
    WriteLn('Stats do cache: ', Enhanced.GetCacheStats);
    
    // Teste com cache desabilitado
    Enhanced.EnableCache(False);
    Stopwatch := TStopwatch.StartNew;
    for I := 1 to 1000 do
    begin
      Enhanced.SetValueFast('data.users[0].name', 'User' + I.ToString);
      Enhanced.SetValueFast('data.config.version', '1.' + I.ToString);
    end;
    Stopwatch.Stop;
    
    WriteLn('1000 operações SEM cache: ', Stopwatch.ElapsedMilliseconds, 'ms');
    
  finally
    Enhanced.Free;
  end;
  
  WriteLn;
end;

class procedure TComposerEnhancementsDemo.DemoBatchOperations;
var
  Enhanced: TJSONComposerEnhanced;
  Operations: TBatchOperations;
  JSON: String;
begin
  WriteLn('=== Demo: Batch Operations ===');
  
  Enhanced := TJSONComposerEnhanced.Create;
  try
    JSON := '{
' +
      '  "users": [],
' +
      '  "config": {}
' +
      '}';
    
    Enhanced.LoadJSON(JSON);
    
    // Operações em lote usando BeginBatch/EndBatch
    Enhanced.BeginBatch;
    Enhanced.SetValueFast('config.version', '2.0');
    Enhanced.SetValueFast('config.environment', 'production');
    Enhanced.AddToArrayFast('users', 'user1');
    Enhanced.AddToArrayFast('users', 'user2');
    Enhanced.AddToArrayFast('users', 'user3');
    Enhanced.EndBatch; // Executa todas as operações
    
    WriteLn('Operações em lote executadas');
    WriteLn(Enhanced.ToJSON(True));
    
    // Operações em lote usando array
    SetLength(Operations, 3);
    Operations[0] := CreateSetOperation('config.lastUpdate', DateTimeToStr(Now));
    Operations[1] := CreateAddToArrayOperation('users', 'user4');
    Operations[2] := CreateSetOperation('config.totalUsers', 4);
    
    Enhanced.ExecuteBatch(Operations);
    
    WriteLn('Batch com array executado');
    WriteLn(Enhanced.ToJSON(True));
    
  finally
    Enhanced.Free;
  end;
  
  WriteLn;
end;

class procedure TComposerEnhancementsDemo.DemoArrayOperations;
var
  Enhanced: TJSONComposerEnhanced;
  JSON: String;
begin
  WriteLn('=== Demo: Array Operations ===');
  
  Enhanced := TJSONComposerEnhanced.Create;
  try
    JSON := '{
' +
      '  "items": ["item1", "item2", "item3"]
' +
      '}';
    
    Enhanced.LoadJSON(JSON);
    WriteLn('Array inicial: ', Enhanced.ToJSON);
    
    // Inserir no meio do array
    Enhanced.InsertIntoArray('items', 1, 'inserted_item');
    WriteLn('Após inserir no índice 1: ', Enhanced.ToJSON);
    
    // Substituir elemento
    Enhanced.ReplaceInArray('items', 2, 'replaced_item');
    WriteLn('Após substituir índice 2: ', Enhanced.ToJSON);
    
    // Remover por índice
    Enhanced.RemoveFromArrayByIndex('items', 0);
    WriteLn('Após remover índice 0: ', Enhanced.ToJSON);
    
    // Adicionar múltiplos valores
    Enhanced.AddMultipleToArray('items', ['new1', 'new2', 'new3']);
    WriteLn('Após adicionar múltiplos: ', Enhanced.ToJSON);
    
  finally
    Enhanced.Free;
  end;
  
  WriteLn;
end;

class procedure TComposerEnhancementsDemo.ComparePoolVsNormal;
var
  Pool: TJSONComposerPool;
  Composer: TJSONComposer;
  Stopwatch: TStopwatch;
  I: Integer;
begin
  WriteLn('=== Comparação: Pool vs Normal ===');
  
  // Teste sem pool
  Stopwatch := TStopwatch.StartNew;
  for I := 1 to 1000 do
  begin
    Composer := TJSONComposer.Create;
    try
      Composer.BeginObject.Add('id', I).EndObject;
    finally
      Composer.Free;
    end;
  end;
  Stopwatch.Stop;
  WriteLn('1000 criações SEM pool: ', Stopwatch.ElapsedMilliseconds, 'ms');
  
  // Teste com pool
  Pool := TJSONComposerPool.Create(10);
  try
    Stopwatch := TStopwatch.StartNew;
    for I := 1 to 1000 do
    begin
      Composer := Pool.Borrow;
      try
        Composer.BeginObject.Add('id', I).EndObject;
      finally
        Pool.Return(Composer);
      end;
    end;
    Stopwatch.Stop;
    WriteLn('1000 criações COM pool: ', Stopwatch.ElapsedMilliseconds, 'ms');
    WriteLn('Taxa de hit do pool: ', Pool.GetHitRate:0:2, '%');
  finally
    Pool.Free;
  end;
  
  WriteLn;
end;

class procedure TComposerEnhancementsDemo.CompareCacheVsNormal;
var
  Normal: TJSONComposer;
  Enhanced: TJSONComposerEnhanced;
  Stopwatch: TStopwatch;
  I: Integer;
  JSON: String;
begin
  WriteLn('=== Comparação: Cache vs Normal ===');
  
  JSON := '{
' +
    '  "deep": {
' +
    '    "nested": {
' +
    '      "structure": {
' +
    '        "value": 0
' +
    '      }
' +
    '    }
' +
    '  }
' +
    '}';
  
  // Teste sem cache
  Normal := TJSONComposer.Create;
  try
    Normal.LoadJSON(JSON);
    Stopwatch := TStopwatch.StartNew;
    for I := 1 to 1000 do
      Normal.SetValue('deep.nested.structure.value', I);
    Stopwatch.Stop;
    WriteLn('1000 navegações SEM cache: ', Stopwatch.ElapsedMilliseconds, 'ms');
  finally
    Normal.Free;
  end;
  
  // Teste com cache
  Enhanced := TJSONComposerEnhanced.Create;
  try
    Enhanced.LoadJSON(JSON);
    Enhanced.OptimizeForReading;
    Stopwatch := TStopwatch.StartNew;
    for I := 1 to 1000 do
      Enhanced.SetValueFast('deep.nested.structure.value', I);
    Stopwatch.Stop;
    WriteLn('1000 navegações COM cache: ', Stopwatch.ElapsedMilliseconds, 'ms');
    WriteLn('Stats do cache: ', Enhanced.GetCacheStats);
  finally
    Enhanced.Free;
  end;
  
  WriteLn;
end;

class procedure TComposerEnhancementsDemo.CompareBatchVsIndividual;
var
  Enhanced: TJSONComposerEnhanced;
  Stopwatch: TStopwatch;
  I: Integer;
  JSON: String;
begin
  WriteLn('=== Comparação: Batch vs Individual ===');
  
  JSON := '{"data": {}, "items": []}';
  
  Enhanced := TJSONComposerEnhanced.Create;
  try
    // Teste individual
    Enhanced.LoadJSON(JSON);
    Stopwatch := TStopwatch.StartNew;
    for I := 1 to 100 do
    begin
      Enhanced.SetValueFast('data.field' + I.ToString, 'value' + I.ToString);
      Enhanced.AddToArrayFast('items', I);
    end;
    Stopwatch.Stop;
    WriteLn('200 operações INDIVIDUAIS: ', Stopwatch.ElapsedMilliseconds, 'ms');
    
    // Teste em lote
    Enhanced.Clear;
    Enhanced.LoadJSON(JSON);
    Stopwatch := TStopwatch.StartNew;
    Enhanced.BeginBatch;
    for I := 1 to 100 do
    begin
      Enhanced.SetValueFast('data.field' + I.ToString, 'value' + I.ToString);
      Enhanced.AddToArrayFast('items', I);
    end;
    Enhanced.EndBatch;
    Stopwatch.Stop;
    WriteLn('200 operações EM LOTE: ', Stopwatch.ElapsedMilliseconds, 'ms');
    
  finally
    Enhanced.Free;
  end;
  
  WriteLn;
end;

class procedure TComposerEnhancementsDemo.RealWorldExample;
var
  Pool: TJSONComposerPool;
  Enhanced: TJSONComposerEnhanced;
  UserData: String;
  I: Integer;
begin
  WriteLn('=== Exemplo do Mundo Real ===');
  WriteLn('Processamento de dados de usuários com alta performance');
  
  Pool := TJSONComposerPool.Create(5);
  try
    // Simular processamento de múltiplos usuários
    for I := 1 to 10 do
    begin
      Enhanced := TJSONComposerEnhanced(Pool.Borrow);
      try
        // Dados base do usuário
        UserData := Format('{
' +
          '  "user": {
' +
          '    "id": %d,
' +
          '    "name": "User%d",
' +
          '    "profile": {},
' +
          '    "activities": []
' +
          '  }
' +
          '}', [I, I]);
        
        Enhanced.LoadJSON(UserData);
        Enhanced.OptimizeForWriting;
        
        // Operações em lote para enriquecer dados
        Enhanced.BeginBatch;
        Enhanced.SetValueFast('user.profile.lastLogin', DateTimeToStr(Now));
        Enhanced.SetValueFast('user.profile.isActive', True);
        Enhanced.SetValueFast('user.profile.score', Random(1000));
        Enhanced.AddToArrayFast('user.activities', 'login');
        Enhanced.AddToArrayFast('user.activities', 'view_dashboard');
        Enhanced.AddToArrayFast('user.activities', 'update_profile');
        Enhanced.EndBatch;
        
        WriteLn('Usuário ', I, ' processado');
        
        // Em uma aplicação real, aqui você salvaria no banco ou enviaria via API
        // SaveToDatabase(Enhanced.ToJSON);
        
      finally
        Pool.Return(Enhanced);
      end;
    end;
    
    WriteLn('Processamento concluído!');
    WriteLn('Estatísticas do pool:');
    WriteLn('- Objetos criados: ', Pool.GetCreatedCount);
    WriteLn('- Total de empréstimos: ', Pool.GetBorrowedCount);
    WriteLn('- Taxa de reutilização: ', Pool.GetHitRate:0:2, '%');
    
  finally
    Pool.Free;
  end;
  
  WriteLn;
end;

end.