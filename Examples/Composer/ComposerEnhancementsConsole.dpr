program ComposerEnhancementsConsole;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  ComposerEnhancementsDemo in 'ComposerEnhancementsDemo.pas',
  JsonFlow4D.Composer in '..\Source\Core\JsonFlow4D.Composer.pas',
  JsonFlow4D.Composer.Pool in '..\Source\Core\JsonFlow4D.Composer.Pool.pas',
  JsonFlow4D.Composer.Enhanced in '..\Source\Core\JsonFlow4D.Composer.Enhanced.pas',
  JsonFlow4D.Interfaces in '..\Source\Core\JsonFlow4D.Interfaces.pas',
  JsonFlow4D.Navigator in '..\Source\Core\JsonFlow4D.Navigator.pas',
  JsonFlow4D.Objects in '..\Source\Core\JsonFlow4D.Objects.pas',
  JsonFlow4D.Arrays in '..\Source\Core\JsonFlow4D.Arrays.pas',
  JsonFlow4D.Value in '..\Source\Core\JsonFlow4D.Value.pas',
  JsonFlow4D.Utils in '..\Source\Core\JsonFlow4D.Utils.pas';

begin
  try
    WriteLn('========================================');
    WriteLn('JsonFlow4D - Demonstração de Melhorias');
    WriteLn('========================================');
    WriteLn;
    
    // Demonstrações do Pool de Objetos
    TComposerEnhancementsDemo.DemoObjectPool;
    TComposerEnhancementsDemo.DemoGlobalPool;
    TComposerEnhancementsDemo.DemoPooledWrapper;
    
    // Demonstrações do Composer Enhanced
    TComposerEnhancementsDemo.DemoEnhancedComposer;
    TComposerEnhancementsDemo.DemoCachePerformance;
    TComposerEnhancementsDemo.DemoBatchOperations;
    TComposerEnhancementsDemo.DemoArrayOperations;
    
    // Comparações de Performance
    WriteLn('========================================');
    WriteLn('COMPARAÇÕES DE PERFORMANCE');
    WriteLn('========================================');
    WriteLn;
    
    TComposerEnhancementsDemo.ComparePoolVsNormal;
    TComposerEnhancementsDemo.CompareCacheVsNormal;
    TComposerEnhancementsDemo.CompareBatchVsIndividual;
    
    // Exemplo do mundo real
    WriteLn('========================================');
    WriteLn('EXEMPLO PRÁTICO');
    WriteLn('========================================');
    WriteLn;
    
    TComposerEnhancementsDemo.RealWorldExample;
    
    WriteLn('========================================');
    WriteLn('DEMONSTRAÇÃO CONCLUÍDA!');
    WriteLn('========================================');
    WriteLn;
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
