program TestSmartModeEnhanced;

{$APPTYPE CONSOLE}

{
  JsonFlow4D - Demonstração do Smart Mode Melhorado
  
  Este programa demonstra as funcionalidades propostas:
  - SuggestNext baseado em meta-schema
  - Quick-validate durante composição
  - Sugestões contextuais inteligentes
  
  Autor: JsonFlow4D Framework
  Data: 2024
}

uses
  System.SysUtils,
  System.Classes,
  SmartModeEnhancedExample in 'SmartModeEnhancedExample.pas';

procedure ShowHeader(const ATitle: string);
begin
  WriteLn('');
  WriteLn('=' + StringOfChar('=', Length(ATitle) + 2) + '=');
  WriteLn(' ' + ATitle + ' ');
  WriteLn('=' + StringOfChar('=', Length(ATitle) + 2) + '=');
  WriteLn('');
end;

procedure ShowSeparator;
begin
  WriteLn('');
  WriteLn(StringOfChar('-', 60));
  WriteLn('');
end;

procedure DemonstrateBasicSmartMode;
var
  LComposer: TEnhancedSchemaComposer;
  LConfig: TSmartModeConfig;
  LValidation: TQuickValidationResult;
begin
  ShowHeader('SMART MODE BÁSICO');
  
  LComposer := TEnhancedSchemaComposer.Create;
  try
    WriteLn('1. Configurando Smart Mode...');
    LConfig := CreateDefaultSmartConfig;
    LConfig.ValidationLevel := qvlBasic;
    LConfig.AutoValidate := False; // Validação manual para demonstração
    LComposer.ConfigureSmartMode(LConfig);
    WriteLn('   ✓ Smart Mode configurado');
    
    WriteLn('');
    WriteLn('2. Construindo schema de pessoa...');
    LComposer
      .Obj
        .Typ('object')
        .Title('Pessoa')
        .Desc('Schema para representar uma pessoa');
    
    WriteLn('   ✓ Estrutura básica criada');
    
    WriteLn('');
    WriteLn('3. Validação rápida do estado atual...');
    LValidation := LComposer.QuickValidate(qvlBasic);
    WriteLn(FormatValidationResult(LValidation));
    
    WriteLn('');
    WriteLn('4. Adicionando propriedades...');
    LComposer
      .Prop('name', procedure(C: TJSONSchemaComposer)
        begin
          C.Typ('string')
           .MinLen(1)
           .MaxLen(100)
           .Desc('Nome completo da pessoa');
        end)
      .Prop('age', procedure(C: TJSONSchemaComposer)
        begin
          C.Typ('integer')
           .Min(0)
           .Max(150)
           .Desc('Idade em anos');
        end)
      .Prop('email', procedure(C: TJSONSchemaComposer)
        begin
          C.Typ('string')
           .Format('email')
           .Desc('Endereço de email');
        end)
      .RequiredFields(['name', 'email'])
      .EndObj;
    
    WriteLn('   ✓ Propriedades adicionadas');
    
    WriteLn('');
    WriteLn('5. Validação final...');
    LValidation := LComposer.QuickValidate(qvlStandard);
    WriteLn(FormatValidationResult(LValidation));
    
    WriteLn('');
    WriteLn('6. Schema final gerado:');
    WriteLn(LComposer.ToJSON(True));
    
  finally
    LComposer.Free;
  end;
end;

procedure DemonstrateSmartSuggestions;
var
  LComposer: TEnhancedSchemaComposer;
  LConfig: TSmartModeConfig;
  LSuggestions: TArray<TSmartSuggestion>;
  LSuggestion: TSmartSuggestion;
begin
  ShowHeader('SUGESTÕES INTELIGENTES COM SINTAXE FLUENTE');
  
  LComposer := TEnhancedSchemaComposer.Create;
  try
    WriteLn('1. Configurando Smart Mode avançado...');
    LConfig := CreateDefaultSmartConfig;
    LConfig.SuggestionLevel := 8;
    LConfig.MaxSuggestions := 8;
    LComposer.ConfigureSmartMode(LConfig);
    WriteLn('   ✓ Configuração aplicada');
    
    WriteLn('');
    WriteLn('2. Demonstrando sintaxe fluente para sugestões:');
    WriteLn('   Exemplo de uso:');
    WriteLn('     Suggestions');
    WriteLn('       .AddValidation(''minLength'', 5)');
    WriteLn('       .AddValidation(''maxLength'', 100)');
    WriteLn('       .AddFormat(''email'', 7)');
    WriteLn('       .AddFormat(''date'', 7);');
    
    WriteLn('');
    WriteLn('3. Iniciando schema de string...');
    LComposer.Obj.Typ('string');
    
    WriteLn('');
    WriteLn('4. Obtendo sugestões para tipo string:');
    LSuggestions := LComposer.GetSmartSuggestions;
    
    if Length(LSuggestions) > 0 then
    begin
      for LSuggestion in LSuggestions do
      begin
        WriteLn(Format('   [%d] %s - %s', [
          LSuggestion.Priority,
          LSuggestion.Keyword,
          LSuggestion.Description
        ]));
        
        if Length(LSuggestion.SuggestedValues) > 0 then
          WriteLn(Format('       Valores sugeridos: %s', [string.Join(', ', LSuggestion.SuggestedValues)]));
      end;
    end
    else
      WriteLn('   Nenhuma sugestão disponível');
    
    ShowSeparator;
    
    WriteLn('5. Mudando para tipo object...');
    LComposer.Clear.Obj.Typ('object');
    
    WriteLn('');
    WriteLn('6. Obtendo sugestões para tipo object:');
    LSuggestions := LComposer.GetSmartSuggestions;
    
    if Length(LSuggestions) > 0 then
    begin
      for LSuggestion in LSuggestions do
      begin
        WriteLn(Format('   [%d] %s - %s (%s)', [
          LSuggestion.Priority,
          LSuggestion.Keyword,
          LSuggestion.Description,
          LSuggestion.Category
        ]));
      end;
    end;
    
    WriteLn('');
    WriteLn('7. Demonstrando aplicação fluente de sugestões:');
    WriteLn('   (Simulando aplicação automática das principais sugestões)');
    WriteLn('   ✓ properties - Adicionado automaticamente');
    WriteLn('   ✓ required - Sugerido para validação');
    WriteLn('   ✓ additionalProperties - Configurado como false');
    
  finally
    LComposer.Free;
  end;
end;

procedure DemonstrateQuickValidation;
var
  LComposer: TEnhancedSchemaComposer;
  LConfig: TSmartModeConfig;
  LValidation: TQuickValidationResult;
begin
  ShowHeader('VALIDAÇÃO RÁPIDA (QUICK-VALIDATE)');
  
  LComposer := TEnhancedSchemaComposer.Create;
  try
    WriteLn('1. Configurando validação automática...');
    LConfig := CreateDefaultSmartConfig;
    LConfig.AutoValidate := True;
    LConfig.ValidationLevel := qvlStrict;
    LConfig.ThrowOnErrors := False; // Para demonstração
    LComposer.ConfigureSmartMode(LConfig);
    WriteLn('   ✓ Validação automática ativada');
    
    WriteLn('');
    WriteLn('2. Testando schema válido...');
    LComposer
      .Obj
        .Typ('object')
        .Prop('name', procedure(C: TJSONSchemaComposer)
          begin
            C.Typ('string').MinLen(1);
          end)
      .EndObj;
    
    LValidation := LComposer.QuickValidate(qvlStandard);
    WriteLn('   Resultado:');
    WriteLn(FormatValidationResult(LValidation));
    
    ShowSeparator;
    
    WriteLn('3. Testando schema com problemas...');
    LComposer.Clear;
    
    // Criar schema com conflitos intencionais
    LComposer.Obj.Typ('string'); // Conflito: objeto com tipo string
    
    LValidation := LComposer.QuickValidate(qvlStandard);
    WriteLn('   Resultado:');
    WriteLn(FormatValidationResult(LValidation));
    
    ShowSeparator;
    
    WriteLn('4. Testando validação de propriedades...');
    LComposer.Clear.Obj.Typ('object');
    
    // Testar propriedade com nome problemático
    WriteLn('   Adicionando propriedade com espaços no nome...');
    LValidation := LComposer.FQuickValidator.ValidateProperty('nome completo', nil);
    WriteLn('   Resultado da validação de propriedade:');
    WriteLn(FormatValidationResult(LValidation));
    
  finally
    LComposer.Free;
  end;
end;

procedure DemonstratePerformanceComparison;
var
  LComposer: TEnhancedSchemaComposer;
  LConfig: TSmartModeConfig;
  LValidation: TQuickValidationResult;
  I: Integer;
  LStartTime: TDateTime;
  LElapsed: Double;
begin
  ShowHeader('COMPARAÇÃO DE PERFORMANCE');
  
  LComposer := TEnhancedSchemaComposer.Create;
  try
    WriteLn('1. Configurando para teste de performance...');
    LConfig := CreateDefaultSmartConfig;
    LComposer.ConfigureSmartMode(LConfig);
    
    WriteLn('');
    WriteLn('2. Testando validação básica (1000 iterações)...');
    LComposer.Obj.Typ('object').Prop('test', procedure(C: TJSONSchemaComposer)
      begin
        C.Typ('string');
      end).EndObj;
    
    LStartTime := Now;
    for I := 1 to 1000 do
    begin
      LValidation := LComposer.QuickValidate(qvlBasic);
    end;
    LElapsed := (Now - LStartTime) * 24 * 60 * 60 * 1000; // ms
    
    WriteLn(Format('   Tempo total: %.2f ms', [LElapsed]));
    WriteLn(Format('   Tempo médio por validação: %.3f ms', [LElapsed / 1000]));
    WriteLn(Format('   Última validação: %d μs', [LValidation.Performance.ValidationTime]));
    
    WriteLn('');
    WriteLn('3. Testando validação padrão (100 iterações)...');
    LStartTime := Now;
    for I := 1 to 100 do
    begin
      LValidation := LComposer.QuickValidate(qvlStandard);
    end;
    LElapsed := (Now - LStartTime) * 24 * 60 * 60 * 1000; // ms
    
    WriteLn(Format('   Tempo total: %.2f ms', [LElapsed]));
    WriteLn(Format('   Tempo médio por validação: %.3f ms', [LElapsed / 100]));
    WriteLn(Format('   Última validação: %d μs', [LValidation.Performance.ValidationTime]));
    WriteLn(Format('   Regras verificadas: %d', [LValidation.Performance.RulesChecked]));
    
  finally
    LComposer.Free;
  end;
end;

procedure DemonstrateRealWorldExample;
var
  LComposer: TEnhancedSchemaComposer;
  LConfig: TSmartModeConfig;
  LValidation: TQuickValidationResult;
begin
  ShowHeader('EXEMPLO REAL: API DE USUÁRIO');
  
  LComposer := TEnhancedSchemaComposer.Create;
  try
    WriteLn('1. Configurando Smart Mode para produção...');
    LConfig := CreateDefaultSmartConfig;
    LConfig.ValidationLevel := qvlStandard;
    LConfig.AutoValidate := True;
    LConfig.LogValidationIssues := True;
    LComposer.ConfigureSmartMode(LConfig);
    
    WriteLn('');
    WriteLn('2. Construindo schema de API de usuário...');
    
    LComposer
      .Obj
        .Typ('object')
        .Title('User API Schema')
        .Desc('Schema para validação de dados de usuário na API')
        .Prop('id', procedure(C: TJSONSchemaComposer)
          begin
            C.Typ('integer')
             .Min(1)
             .Desc('ID único do usuário');
          end)
        .Prop('username', procedure(C: TJSONSchemaComposer)
          begin
            C.Typ('string')
             .MinLen(3)
             .MaxLen(30)
             .Pattern('^[a-zA-Z0-9_]+$')
             .Desc('Nome de usuário (alfanumérico e underscore)');
          end)
        .Prop('email', procedure(C: TJSONSchemaComposer)
          begin
            C.Typ('string')
             .Format('email')
             .Desc('Endereço de email válido');
          end)
        .Prop('profile', procedure(C: TJSONSchemaComposer)
          begin
            C.Typ('object')
             .Prop('firstName', procedure(CC: TJSONSchemaComposer)
               begin
                 CC.Typ('string').MinLen(1).MaxLen(50);
               end)
             .Prop('lastName', procedure(CC: TJSONSchemaComposer)
               begin
                 CC.Typ('string').MinLen(1).MaxLen(50);
               end)
             .Prop('age', procedure(CC: TJSONSchemaComposer)
               begin
                 CC.Typ('integer').Min(13).Max(120);
               end)
             .RequiredFields(['firstName', 'lastName']);
          end)
        .Prop('roles', procedure(C: TJSONSchemaComposer)
          begin
            C.Typ('array')
             .Items(procedure(CC: TJSONSchemaComposer)
               begin
                 CC.Typ('string').Enum(['admin', 'user', 'moderator']);
               end)
             .MinItems(1)
             .Unique(True);
          end)
        .Prop('createdAt', procedure(C: TJSONSchemaComposer)
          begin
            C.Typ('string')
             .Format('date-time')
             .Desc('Data de criação do usuário');
          end)
        .RequiredFields(['id', 'username', 'email', 'profile'])
        .AddProps(False) // Não permitir propriedades adicionais
      .EndObj;
    
    WriteLn('   ✓ Schema construído com validação automática');
    
    WriteLn('');
    WriteLn('3. Validação final do schema...');
    LValidation := LComposer.QuickValidate(qvlStrict);
    WriteLn(FormatValidationResult(LValidation));
    
    WriteLn('');
    WriteLn('4. Schema final para API:');
    WriteLn(LComposer.ToJSON(True));
    
    WriteLn('');
    WriteLn('5. Obtendo sugestões para melhorias...');
    WriteLn(LComposer.SuggestNextEnhanced);
    
  finally
    LComposer.Free;
  end;
end;

begin
  try
    WriteLn('JsonFlow4D - Demonstração do Smart Mode Melhorado');
    WriteLn('==================================================');
    WriteLn('');
    WriteLn('Esta demonstração mostra as funcionalidades propostas para');
    WriteLn('melhorar o Composer Smart Mode do JsonFlow4D:');
    WriteLn('');
    WriteLn('• SuggestNext baseado em meta-schema');
    WriteLn('• Quick-validate durante composição');
    WriteLn('• Sugestões contextuais inteligentes');
    WriteLn('• Validação em tempo real');
    WriteLn('• Análise de performance');
    
    // Executar demonstrações
    DemonstrateBasicSmartMode;
    ShowSeparator;
    
    DemonstrateSmartSuggestions;
    ShowSeparator;
    
    DemonstrateQuickValidation;
    ShowSeparator;
    
    DemonstratePerformanceComparison;
    ShowSeparator;
    
    DemonstrateRealWorldExample;
    
    WriteLn('');
    WriteLn('');
    ShowHeader('RESUMO DOS BENEFÍCIOS');
    WriteLn('✓ Sugestões contextuais baseadas no estado atual do schema');
    WriteLn('✓ Validação rápida e não intrusiva durante a composição');
    WriteLn('✓ Detecção precoce de erros e inconsistências');
    WriteLn('✓ Feedback imediato para melhorar a produtividade');
    WriteLn('✓ Configuração flexível para diferentes cenários');
    WriteLn('✓ Performance otimizada para uso em produção');
    WriteLn('');
    WriteLn('Essas melhorias tornarão o JsonFlow4D a solução mais');
    WriteLn('avançada para composição de JSON Schemas em Delphi!');
    
  except
    on E: Exception do
    begin
      WriteLn('');
      WriteLn('ERRO: ' + E.Message);
      WriteLn('');
      WriteLn('Nota: Esta é uma demonstração conceitual das funcionalidades');
      WriteLn('propostas. A implementação real requerirá integração com');
      WriteLn('o código existente do JsonFlow4D.');
    end;
  end;
  
  WriteLn('');
  WriteLn('Pressione ENTER para sair...');
  ReadLn;
end.