program TestComposerFluentDemo;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  JsonFlow4D.Interfaces in '..\Source\Core\JsonFlow4D.Interfaces.pas',
  JsonFlow4D.Utils in '..\Source\Core\JsonFlow4D.Utils.pas',
  JsonFlow4D.Value in '..\Source\Core\JsonFlow4D.Value.pas',
  JsonFlow4D.Objects in '..\Source\Core\JsonFlow4D.Objects.pas',
  JsonFlow4D.Arrays in '..\Source\Core\JsonFlow4D.Arrays.pas',
  JsonFlow4D.Pair in '..\Source\Core\JsonFlow4D.Pair.pas',
  JsonFlow4D.Navigator in '..\Source\Core\JsonFlow4D.Navigator.pas',
  JsonFlow4D.Composer in '..\Source\Core\JsonFlow4D.Composer.pas',
  JsonFlow4D.Writer in '..\Source\Core\JsonFlow4D.Writer.pas',
  JsonFlow4D.Reader in '..\Source\Core\JsonFlow4D.Reader.pas',
  ComposerFluentSyntaxDemo in 'ComposerFluentSyntaxDemo.pas';

begin
  try
    WriteLn('=== DEMONSTRAÇÃO DE SINTAXE FLUENTE PARA JsonFlow4D.COMPOSER ===');
    WriteLn;
    WriteLn('Esta demonstração mostra como o JsonFlow4D.Composer pode ser');
    WriteLn('aprimorado com sintaxe fluente moderna baseada nos padrões');
    WriteLn('implementados no JsonFlow4D.SchemaComposer.');
    WriteLn;
    WriteLn('Pressione ENTER para continuar...');
    ReadLn;
    WriteLn;
    
    // Executar demonstrações
    TComposerFluentDemo.RunBasicSyntaxDemo;
    WriteLn('Pressione ENTER para continuar...');
    ReadLn;
    WriteLn;
    
    TComposerFluentDemo.RunAdvancedSyntaxDemo;
    WriteLn('Pressione ENTER para continuar...');
    ReadLn;
    WriteLn;
    
    TComposerFluentDemo.RunPerformanceComparison;
    WriteLn('Pressione ENTER para continuar...');
    ReadLn;
    WriteLn;
    
    TComposerFluentDemo.RunComplexStructureDemo;
    WriteLn;
    WriteLn('=== DEMONSTRAÇÃO CONCLUÍDA ===');
    WriteLn;
    WriteLn('Benefícios da Sintaxe Fluente:');
    WriteLn('✅ Código mais legível e expressivo');
    WriteLn('✅ Menos propenso a erros de sintaxe');
    WriteLn('✅ IntelliSense melhorado');
    WriteLn('✅ Callbacks para estruturas aninhadas');
    WriteLn('✅ Métodos de conveniência (Str, Int, Bool, etc.)');
    WriteLn('✅ Factory pattern para criação simplificada');
    WriteLn;
    WriteLn('Próximos Passos:');
    WriteLn('1. Implementar no JsonFlow4D.Composer.pas');
    WriteLn('2. Adicionar context-aware features');
    WriteLn('3. Implementar smart suggestions');
    WriteLn('4. Otimizações de performance');
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
