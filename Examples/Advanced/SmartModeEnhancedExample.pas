unit SmartModeEnhancedExample;

{
  JsonFlow4D - Exemplo de Composer Smart Mode Melhorado
  
  Este exemplo demonstra as funcionalidades propostas para o Smart Mode:
  - SuggestNext baseado em meta-schema
  - Quick-validate durante composição
  - Sugestões contextuais inteligentes
  
  Autor: JsonFlow4D Framework
  Data: 2024
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  JsonFlow4D.Interfaces,
  JsonFlow4D.SchemaComposer;

type
  // Tipos para o Smart Mode melhorado
  TQuickValidationLevel = (qvlOff, qvlBasic, qvlStandard, qvlStrict);
  
  TSmartSuggestion = record
    Keyword: string;
    Description: string;
    Priority: Integer; // 1-10
    Category: string; // 'validation', 'metadata', 'composition'
    RequiredType: string;
    ConflictsWith: TArray<string>;
    SuggestedValues: TArray<string>;
    Example: string;
  end;
  
  TQuickValidationResult = record
    IsValid: Boolean;
    Warnings: TArray<string>;
    Errors: TArray<string>;
    Suggestions: TArray<string>;
    Performance: record
      ValidationTime: Int64; // microseconds
      RulesChecked: Integer;
    end;
  end;
  
  TSchemaAnalysisContext = record
    CurrentType: string;
    ExistingProperties: TArray<string>;
    RequiredProperties: TArray<string>;
    ConditionalRules: TArray<string>;
    ParentContext: string;
    AllowedCombinations: TArray<string>;
  end;
  
  TSmartModeConfig = record
    Enabled: Boolean;
    AutoValidate: Boolean;
    ValidationLevel: TQuickValidationLevel;
    SuggestionLevel: Integer; // 1-10
    LogValidationIssues: Boolean;
    ThrowOnErrors: Boolean;
    MaxSuggestions: Integer;
  end;

  // Interface para Quick Validator
  IQuickValidator = interface
    ['{F1E2D3C4-B5A6-7890-1234-567890ABCDEF}']
    function ValidateIncremental(const ASchema: IJSONElement; ALevel: TQuickValidationLevel): TQuickValidationResult;
    function ValidateProperty(const APropertyName: string; const AValue: IJSONElement): TQuickValidationResult;
    function ValidateStructure(const ASchema: IJSONElement): TQuickValidationResult;
    procedure Configure(const AConfig: TSmartModeConfig);
  end;

  // Implementação do Quick Validator
  TQuickValidator = class(TInterfacedObject, IQuickValidator)
  private
    FMetaSchema: IJSONElement;
    FConfig: TSmartModeConfig;
    function _HasRequiredMetaProperties(const ASchema: IJSONElement): Boolean;
    function _HasConflictingProperties(const ASchema: IJSONElement): Boolean;
    function _HasValidTypes(const ASchema: IJSONElement): Boolean;
    procedure _ValidatePropertyDependencies(const ASchema: IJSONElement; var AResult: TQuickValidationResult);
    procedure _ValidateFormatConsistency(const ASchema: IJSONElement; var AResult: TQuickValidationResult);
    procedure _ValidateRangeConsistency(const ASchema: IJSONElement; var AResult: TQuickValidationResult);
  public
    constructor Create(const AMetaSchema: IJSONElement);
    function ValidateIncremental(const ASchema: IJSONElement; ALevel: TQuickValidationLevel): TQuickValidationResult;
    function ValidateProperty(const APropertyName: string; const AValue: IJSONElement): TQuickValidationResult;
    function ValidateStructure(const ASchema: IJSONElement): TQuickValidationResult;
    procedure Configure(const AConfig: TSmartModeConfig);
  end;

  // Composer melhorado com Smart Mode
  TEnhancedSchemaComposer = class(TJSONSchemaComposer)
  private
    FQuickValidator: IQuickValidator;
    FAutoValidate: Boolean;
    FValidationLevel: TQuickValidationLevel;
    FSmartConfig: TSmartModeConfig;
    
    function _AnalyzeCurrentContext: TSchemaAnalysisContext;
    procedure _AddTypeSuggestions(const AContext: TSchemaAnalysisContext; ASuggestions: TList<TSmartSuggestion>);
    procedure _AddContextualSuggestions(const AContext: TSchemaAnalysisContext; ASuggestions: TList<TSmartSuggestion>);
    procedure _AddMetaSchemaSuggestions(const AContext: TSchemaAnalysisContext; ASuggestions: TList<TSmartSuggestion>);
    function _FilterAndPrioritize(const ASuggestions: TArray<TSmartSuggestion>): TArray<TSmartSuggestion>;
    function CreateSuggestion(const AKeyword, ADescription: string; APriority: Integer; const ACategory: string; const AConflicts: TArray<string> = nil; const AValues: TArray<string> = nil): TSmartSuggestion;
    procedure _HandleValidationErrors(const AResult: TQuickValidationResult);
    procedure _WarnPropertyIssues(const APropertyName: string; const AResult: TQuickValidationResult);
    function HasProperty(const APropertyName: string): Boolean;
  public
    constructor Create; override;
    destructor Destroy; override;
    
    // Métodos melhorados com validação automática
    function Typ(const AType: String): TJSONSchemaComposer; override;
    function Prop(const AName: String; const ACallback: TProc<TJSONSchemaComposer> = nil): TJSONSchemaComposer; override;
    
    // Novas funcionalidades Smart Mode
    function GetSmartSuggestions: TArray<TSmartSuggestion>;
    function QuickValidate(ALevel: TQuickValidationLevel = qvlStandard): TQuickValidationResult;
    procedure ConfigureSmartMode(const AConfig: TSmartModeConfig);
    function SuggestNextEnhanced: string; // Versão melhorada do SuggestNext
  end;

// Funções auxiliares para demonstração
function CreateDefaultSmartConfig: TSmartModeConfig;
function FormatSuggestions(const ASuggestions: TArray<TSmartSuggestion>): string;
function FormatValidationResult(const AResult: TQuickValidationResult): string;

// Exemplos de uso
procedure DemonstrateEnhancedSmartMode;
procedure DemonstrateQuickValidation;
procedure DemonstrateSmartSuggestions;

implementation

uses
  System.Diagnostics,
  System.StrUtils;

{ TQuickValidator }

constructor TQuickValidator.Create(const AMetaSchema: IJSONElement);
begin
  inherited Create;
  FMetaSchema := AMetaSchema;
  FConfig := CreateDefaultSmartConfig;
end;

function TQuickValidator.ValidateStructure(const ASchema: IJSONElement): TQuickValidationResult;
begin
  Result.IsValid := True;
  SetLength(Result.Errors, 0);
  SetLength(Result.Warnings, 0);
  SetLength(Result.Suggestions, 0);
  
  // 1. Verificar propriedades obrigatórias
  if not _HasRequiredMetaProperties(ASchema) then
  begin
    Result.Errors := Result.Errors + ['Schema deve ter pelo menos "type" ou "properties"'];
    Result.IsValid := False;
  end;
  
  // 2. Verificar conflitos básicos
  if _HasConflictingProperties(ASchema) then
  begin
    Result.Errors := Result.Errors + ['Propriedades conflitantes detectadas'];
    Result.IsValid := False;
  end;
  
  // 3. Verificar tipos válidos
  if not _HasValidTypes(ASchema) then
  begin
    Result.Warnings := Result.Warnings + ['Tipos podem estar inconsistentes'];
  end;
  
  Result.Performance.RulesChecked := 3;
end;

function TQuickValidator.ValidateIncremental(const ASchema: IJSONElement; ALevel: TQuickValidationLevel): TQuickValidationResult;
var
  LStopwatch: TStopwatch;
begin
  LStopwatch := TStopwatch.StartNew;
  
  // Validação estrutural básica
  Result := ValidateStructure(ASchema);
  
  if ALevel >= qvlStandard then
  begin
    // Validações adicionais
    _ValidatePropertyDependencies(ASchema, Result);
    _ValidateFormatConsistency(ASchema, Result);
    _ValidateRangeConsistency(ASchema, Result);
    Inc(Result.Performance.RulesChecked, 3);
  end;
  
  if ALevel >= qvlStrict then
  begin
    // Validações avançadas (simuladas)
    if Length(Result.Errors) = 0 then
      Result.Suggestions := Result.Suggestions + ['Considere adicionar "description" para melhor documentação'];
    Inc(Result.Performance.RulesChecked, 5);
  end;
  
  LStopwatch.Stop;
  Result.Performance.ValidationTime := LStopwatch.ElapsedMicroseconds;
end;

function TQuickValidator.ValidateProperty(const APropertyName: string; const AValue: IJSONElement): TQuickValidationResult;
begin
  Result.IsValid := True;
  SetLength(Result.Errors, 0);
  SetLength(Result.Warnings, 0);
  SetLength(Result.Suggestions, 0);
  
  // Validações básicas de propriedade
  if APropertyName = '' then
  begin
    Result.Errors := Result.Errors + ['Nome da propriedade não pode estar vazio'];
    Result.IsValid := False;
  end;
  
  if ContainsStr(APropertyName, ' ') then
  begin
    Result.Warnings := Result.Warnings + ['Nome da propriedade contém espaços - considere usar camelCase'];
  end;
  
  Result.Performance.RulesChecked := 2;
end;

procedure TQuickValidator.Configure(const AConfig: TSmartModeConfig);
begin
  FConfig := AConfig;
end;

// Implementações auxiliares do TQuickValidator
function TQuickValidator._HasRequiredMetaProperties(const ASchema: IJSONElement): Boolean;
var
  LObject: IJSONObject;
begin
  Result := False;
  if Supports(ASchema, IJSONObject, LObject) then
  begin
    Result := LObject.ContainsKey('type') or 
              LObject.ContainsKey('properties') or 
              LObject.ContainsKey('items') or
              LObject.ContainsKey('$ref');
  end;
end;

function TQuickValidator._HasConflictingProperties(const ASchema: IJSONElement): Boolean;
var
  LObject: IJSONObject;
begin
  Result := False;
  if Supports(ASchema, IJSONObject, LObject) then
  begin
    // Exemplo: type=string com properties (conflito)
    if LObject.ContainsKey('type') and LObject.ContainsKey('properties') then
    begin
      if (LObject.GetValue('type') as IJSONValue).AsString = 'string' then
        Result := True;
    end;
  end;
end;

function TQuickValidator._HasValidTypes(const ASchema: IJSONElement): Boolean;
var
  LObject: IJSONObject;
  LType: string;
begin
  Result := True;
  if Supports(ASchema, IJSONObject, LObject) and LObject.ContainsKey('type') then
  begin
    LType := (LObject.GetValue('type') as IJSONValue).AsString;
    Result := LType.IsEmpty or 
              (LType = 'string') or (LType = 'number') or (LType = 'integer') or 
              (LType = 'boolean') or (LType = 'array') or (LType = 'object') or (LType = 'null');
  end;
end;

procedure TQuickValidator._ValidatePropertyDependencies(const ASchema: IJSONElement; var AResult: TQuickValidationResult);
var
  LObject: IJSONObject;
begin
  if Supports(ASchema, IJSONObject, LObject) then
  begin
    // Exemplo: se tem 'minimum', deveria ter 'type': 'number'
    if LObject.ContainsKey('minimum') and not LObject.ContainsKey('type') then
    begin
      AResult.Warnings := AResult.Warnings + ['"minimum" geralmente requer "type": "number"'];
    end;
  end;
end;

procedure TQuickValidator._ValidateFormatConsistency(const ASchema: IJSONElement; var AResult: TQuickValidationResult);
var
  LObject: IJSONObject;
begin
  if Supports(ASchema, IJSONObject, LObject) then
  begin
    // Exemplo: format sem type=string
    if LObject.ContainsKey('format') and LObject.ContainsKey('type') then
    begin
      if (LObject.GetValue('type') as IJSONValue).AsString <> 'string' then
      begin
        AResult.Warnings := AResult.Warnings + ['"format" é aplicável apenas para "type": "string"'];
      end;
    end;
  end;
end;

procedure TQuickValidator._ValidateRangeConsistency(const ASchema: IJSONElement; var AResult: TQuickValidationResult);
var
  LObject: IJSONObject;
  LMin, LMax: Double;
begin
  if Supports(ASchema, IJSONObject, LObject) then
  begin
    // Verificar se minimum <= maximum
    if LObject.ContainsKey('minimum') and LObject.ContainsKey('maximum') then
    begin
      LMin := (LObject.GetValue('minimum') as IJSONValue).AsNumber;
      LMax := (LObject.GetValue('maximum') as IJSONValue).AsNumber;
      if LMin > LMax then
      begin
        AResult.Errors := AResult.Errors + ['"minimum" não pode ser maior que "maximum"'];
        AResult.IsValid := False;
      end;
    end;
  end;
end;

{ TEnhancedSchemaComposer }

constructor TEnhancedSchemaComposer.Create;
begin
  inherited Create;
  FSmartConfig := CreateDefaultSmartConfig;
  FAutoValidate := FSmartConfig.AutoValidate;
  FValidationLevel := FSmartConfig.ValidationLevel;
end;

destructor TEnhancedSchemaComposer.Destroy;
begin
  FQuickValidator := nil;
  inherited Destroy;
end;

function TEnhancedSchemaComposer.Typ(const AType: String): TJSONSchemaComposer;
var
  LValidation: TQuickValidationResult;
begin
  // Chamar implementação original
  Result := inherited Typ(AType);
  
  // Quick-validate após mudança
  if FSmartMode and FAutoValidate then
  begin
    LValidation := QuickValidate(qvlBasic);
    if not LValidation.IsValid then
      _HandleValidationErrors(LValidation);
  end;
end;

function TEnhancedSchemaComposer.Prop(const AName: String; const ACallback: TProc<TJSONSchemaComposer>): TJSONSchemaComposer;
var
  LValidation: TQuickValidationResult;
begin
  // Validar antes de adicionar
  if FSmartMode and Assigned(FQuickValidator) then
  begin
    LValidation := FQuickValidator.ValidateProperty(AName, nil);
    if not LValidation.IsValid then
      _WarnPropertyIssues(AName, LValidation);
  end;
  
  // Chamar implementação original
  Result := inherited Prop(AName, ACallback);
end;

function TEnhancedSchemaComposer.GetSmartSuggestions: TArray<TSmartSuggestion>;
var
  LContext: TSchemaAnalysisContext;
  LSuggestions: TList<TSmartSuggestion>;
begin
  if not FSmartMode then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  
  LContext := _AnalyzeCurrentContext;
  LSuggestions := TList<TSmartSuggestion>.Create;
  try
    // 1. Sugestões baseadas no tipo atual
    _AddTypeSuggestions(LContext, LSuggestions);
    
    // 2. Sugestões baseadas em propriedades existentes
    _AddContextualSuggestions(LContext, LSuggestions);
    
    // 3. Sugestões baseadas no meta-schema
    _AddMetaSchemaSuggestions(LContext, LSuggestions);
    
    // 4. Filtrar e ordenar por prioridade
    Result := _FilterAndPrioritize(LSuggestions.ToArray);
  finally
    LSuggestions.Free;
  end;
end;

function TEnhancedSchemaComposer.QuickValidate(ALevel: TQuickValidationLevel): TQuickValidationResult;
begin
  if not FSmartMode or not Assigned(FQuickValidator) then
  begin
    Result.IsValid := True;
    Exit;
  end;
  
  Result := FQuickValidator.ValidateIncremental(FCurrent, ALevel);
end;

procedure TEnhancedSchemaComposer.ConfigureSmartMode(const AConfig: TSmartModeConfig);
begin
  FSmartConfig := AConfig;
  FSmartMode := AConfig.Enabled;
  FAutoValidate := AConfig.AutoValidate;
  FValidationLevel := AConfig.ValidationLevel;
  
  if FSmartMode then
  begin
    if not Assigned(FMetaSchema) then
      LoadMetaSchema;
    FQuickValidator := TQuickValidator.Create(FMetaSchema);
    FQuickValidator.Configure(AConfig);
  end;
end;

function TEnhancedSchemaComposer.SuggestNextEnhanced: string;
var
  LSuggestions: TArray<TSmartSuggestion>;
begin
  LSuggestions := GetSmartSuggestions;
  Result := FormatSuggestions(LSuggestions);
end;

// Implementações auxiliares
function TEnhancedSchemaComposer._AnalyzeCurrentContext: TSchemaAnalysisContext;
var
  LObject: IJSONObject;
  LPair: IJSONPair;
  LProps: TList<string>;
begin
  Result.CurrentType := FCurrentContext;
  Result.ParentContext := '';
  
  LProps := TList<string>.Create;
  try
    if Supports(FCurrent, IJSONObject, LObject) then
    begin
      for LPair in LObject.Pairs do
        LProps.Add(LPair.Key);
    end;
    Result.ExistingProperties := LProps.ToArray;
  finally
    LProps.Free;
  end;
end;

procedure TEnhancedSchemaComposer._AddTypeSuggestions(const AContext: TSchemaAnalysisContext; ASuggestions: TList<TSmartSuggestion>);
begin
  if AContext.CurrentType = 'string' then
  begin
    if not HasProperty('minLength') then
      ASuggestions.Add(CreateSuggestion('minLength', 'Comprimento mínimo da string', 8, 'validation'));
    
    if not HasProperty('maxLength') then
      ASuggestions.Add(CreateSuggestion('maxLength', 'Comprimento máximo da string', 7, 'validation'));
    
    if not HasProperty('pattern') then
      ASuggestions.Add(CreateSuggestion('pattern', 'Padrão regex para validação', 6, 'validation'));
    
    if not HasProperty('format') then
    begin
      ASuggestions.Add(CreateSuggestion('format', 'Formato específico', 7, 'validation', [], ['email', 'uri', 'date-time', 'date', 'time']));
    end;
  end
  else if AContext.CurrentType = 'number' then
  begin
    if not HasProperty('minimum') then
      ASuggestions.Add(CreateSuggestion('minimum', 'Valor mínimo', 8, 'validation'));
    
    if not HasProperty('maximum') then
      ASuggestions.Add(CreateSuggestion('maximum', 'Valor máximo', 7, 'validation'));
    
    if not HasProperty('multipleOf') then
      ASuggestions.Add(CreateSuggestion('multipleOf', 'Múltiplo de', 6, 'validation'));
  end
  else if AContext.CurrentType = 'array' then
  begin
    if not HasProperty('items') then
      ASuggestions.Add(CreateSuggestion('items', 'Definir tipo dos itens', 10, 'structure'));
    
    if not HasProperty('minItems') then
      ASuggestions.Add(CreateSuggestion('minItems', 'Número mínimo de itens', 7, 'validation'));
    
    if not HasProperty('maxItems') then
      ASuggestions.Add(CreateSuggestion('maxItems', 'Número máximo de itens', 6, 'validation'));
    
    if not HasProperty('uniqueItems') then
      ASuggestions.Add(CreateSuggestion('uniqueItems', 'Itens únicos', 5, 'validation', [], ['true', 'false']));
  end
  else if AContext.CurrentType = 'object' then
  begin
    if not HasProperty('properties') then
      ASuggestions.Add(CreateSuggestion('properties', 'Definir propriedades do objeto', 10, 'structure'));
    
    if HasProperty('properties') and not HasProperty('required') then
      ASuggestions.Add(CreateSuggestion('required', 'Propriedades obrigatórias', 9, 'validation'));
    
    if not HasProperty('additionalProperties') then
      ASuggestions.Add(CreateSuggestion('additionalProperties', 'Permitir propriedades adicionais', 6, 'validation', [], ['true', 'false']));
  end;
end;

procedure TEnhancedSchemaComposer._AddContextualSuggestions(const AContext: TSchemaAnalysisContext; ASuggestions: TList<TSmartSuggestion>);
begin
  // Sugestões baseadas no contexto atual
  if not HasProperty('title') then
    ASuggestions.Add(CreateSuggestion('title', 'Título descritivo do schema', 5, 'metadata'));
  
  if not HasProperty('description') then
    ASuggestions.Add(CreateSuggestion('description', 'Descrição detalhada', 6, 'metadata'));
  
  if not HasProperty('$id') then
    ASuggestions.Add(CreateSuggestion('$id', 'Identificador único do schema', 4, 'metadata'));
  
  if not HasProperty('examples') then
    ASuggestions.Add(CreateSuggestion('examples', 'Exemplos de valores válidos', 5, 'metadata'));
  
  if not HasProperty('default') then
    ASuggestions.Add(CreateSuggestion('default', 'Valor padrão', 6, 'metadata'));
end;

procedure TEnhancedSchemaComposer._AddMetaSchemaSuggestions(const AContext: TSchemaAnalysisContext; ASuggestions: TList<TSmartSuggestion>);
begin
  // Sugestões baseadas no meta-schema (simuladas)
  if Assigned(FMetaSchema) then
  begin
    // Aqui seria feita análise real do meta-schema
    if not HasProperty('$schema') then
      ASuggestions.Add(CreateSuggestion('$schema', 'Versão do JSON Schema', 3, 'metadata', [], ['http://json-schema.org/draft-07/schema#', 'http://json-schema.org/draft/2020-12/schema']));
    
    if not HasProperty('$comment') then
      ASuggestions.Add(CreateSuggestion('$comment', 'Comentário interno do schema', 2, 'metadata'));
    
    if not HasProperty('$defs') then
      ASuggestions.Add(CreateSuggestion('$defs', 'Definições reutilizáveis', 4, 'structure'));
  end;
end;

function TEnhancedSchemaComposer._FilterAndPrioritize(const ASuggestions: TArray<TSmartSuggestion>): TArray<TSmartSuggestion>;
var
  LList: TList<TSmartSuggestion>;
  I, J: Integer;
  LTemp: TSmartSuggestion;
begin
  LList := TList<TSmartSuggestion>.Create;
  try
    LList.AddRange(ASuggestions);
    
    // Ordenar por prioridade (bubble sort simples para exemplo)
    for I := 0 to LList.Count - 2 do
      for J := 0 to LList.Count - 2 - I do
        if LList[J].Priority < LList[J + 1].Priority then
        begin
          LTemp := LList[J];
          LList[J] := LList[J + 1];
          LList[J + 1] := LTemp;
        end;
    
    // Limitar número de sugestões
    if LList.Count > FSmartConfig.MaxSuggestions then
      LList.Count := FSmartConfig.MaxSuggestions;
    
    Result := LList.ToArray;
  finally
    LList.Free;
  end;
end;

function TEnhancedSchemaComposer.CreateSuggestion(const AKeyword, ADescription: string; APriority: Integer; const ACategory: string; const AConflicts, AValues: TArray<string>): TSmartSuggestion;
begin
  Result.Keyword := AKeyword;
  Result.Description := ADescription;
  Result.Priority := APriority;
  Result.Category := ACategory;
  Result.ConflictsWith := AConflicts;
  Result.SuggestedValues := AValues;
  Result.Example := Format('"%s": ...', [AKeyword]);
end;

procedure TEnhancedSchemaComposer._HandleValidationErrors(const AResult: TQuickValidationResult);
var
  LError: string;
begin
  if FSmartConfig.LogValidationIssues then
  begin
    for LError in AResult.Errors do
      _Log('ERRO: ' + LError);
  end;
  
  if FSmartConfig.ThrowOnErrors and not AResult.IsValid then
    raise EInvalidOperation.Create('Validação falhou: ' + string.Join('; ', AResult.Errors));
end;

procedure TEnhancedSchemaComposer._WarnPropertyIssues(const APropertyName: string; const AResult: TQuickValidationResult);
var
  LWarning: string;
begin
  if FSmartConfig.LogValidationIssues then
  begin
    for LWarning in AResult.Warnings do
      _Log('AVISO [' + APropertyName + ']: ' + LWarning);
  end;
end;

function TEnhancedSchemaComposer.HasProperty(const APropertyName: string): Boolean;
var
  LObject: IJSONObject;
begin
  Result := False;
  if Supports(FCurrent, IJSONObject, LObject) then
    Result := LObject.ContainsKey(APropertyName);
end;

// Funções auxiliares globais
function CreateDefaultSmartConfig: TSmartModeConfig;
begin
  Result.Enabled := True;
  Result.AutoValidate := True;
  Result.ValidationLevel := qvlStandard;
  Result.SuggestionLevel := 7;
  Result.LogValidationIssues := True;
  Result.ThrowOnErrors := False;
  Result.MaxSuggestions := 10;
end;

function FormatSuggestions(const ASuggestions: TArray<TSmartSuggestion>): string;
var
  LSuggestion: TSmartSuggestion;
  LResult: TStringList;
begin
  LResult := TStringList.Create;
  try
    LResult.Add('=== SUGESTÕES INTELIGENTES ===');
    
    for LSuggestion in ASuggestions do
    begin
      LResult.Add(Format('[%d] %s - %s (%s)', [
        LSuggestion.Priority,
        LSuggestion.Keyword,
        LSuggestion.Description,
        LSuggestion.Category
      ]));
      
      if Length(LSuggestion.SuggestedValues) > 0 then
        LResult.Add('    Valores: ' + string.Join(', ', LSuggestion.SuggestedValues));
    end;
    
    if Length(ASuggestions) = 0 then
      LResult.Add('Nenhuma sugestão disponível para o contexto atual.');
    
    Result := LResult.Text;
  finally
    LResult.Free;
  end;
end;

function FormatValidationResult(const AResult: TQuickValidationResult): string;
var
  LResult: TStringList;
  LItem: string;
begin
  LResult := TStringList.Create;
  try
    LResult.Add('=== RESULTADO DA VALIDAÇÃO RÁPIDA ===');
    LResult.Add(Format('Status: %s', [IfThen(AResult.IsValid, 'VÁLIDO', 'INVÁLIDO')]));
    LResult.Add(Format('Tempo: %d μs', [AResult.Performance.ValidationTime]));
    LResult.Add(Format('Regras verificadas: %d', [AResult.Performance.RulesChecked]));
    
    if Length(AResult.Errors) > 0 then
    begin
      LResult.Add('');
      LResult.Add('ERROS:');
      for LItem in AResult.Errors do
        LResult.Add('  ❌ ' + LItem);
    end;
    
    if Length(AResult.Warnings) > 0 then
    begin
      LResult.Add('');
      LResult.Add('AVISOS:');
      for LItem in AResult.Warnings do
        LResult.Add('  ⚠️  ' + LItem);
    end;
    
    if Length(AResult.Suggestions) > 0 then
    begin
      LResult.Add('');
      LResult.Add('SUGESTÕES:');
      for LItem in AResult.Suggestions do
        LResult.Add('  💡 ' + LItem);
    end;
    
    Result := LResult.Text;
  finally
    LResult.Free;
  end;
end;

// Exemplos de uso
procedure DemonstrateEnhancedSmartMode;
var
  LComposer: TEnhancedSchemaComposer;
  LConfig: TSmartModeConfig;
begin
  WriteLn('=== DEMONSTRAÇÃO: SMART MODE MELHORADO ===');
  
  LComposer := TEnhancedSchemaComposer.Create;
  try
    // Configurar Smart Mode
    LConfig := CreateDefaultSmartConfig;
    LConfig.ValidationLevel := qvlStandard;
    LComposer.ConfigureSmartMode(LConfig);
    
    // Construir schema com validação automática
    LComposer
      .Obj
        .Typ('object')
        .Prop('name', procedure(C: TJSONSchemaComposer)
          begin
            C.Typ('string').MinLen(1).MaxLen(100);
          end)
        .Prop('age', procedure(C: TJSONSchemaComposer)
          begin
            C.Typ('integer').Min(0).Max(150);
          end)
      .EndObj;
    
    WriteLn('Schema construído com validação automática!');
    WriteLn('JSON gerado:');
    WriteLn(LComposer.ToJSON(True));
    
  finally
    LComposer.Free;
  end;
end;

procedure DemonstrateQuickValidation;
var
  LComposer: TEnhancedSchemaComposer;
  LResult: TQuickValidationResult;
begin
  WriteLn('');
  WriteLn('=== DEMONSTRAÇÃO: QUICK VALIDATION ===');
  
  LComposer := TEnhancedSchemaComposer.Create;
  try
    LComposer.ConfigureSmartMode(CreateDefaultSmartConfig);
    
    // Construir schema com erro intencional
    LComposer.Obj.Typ('string'); // Conflito: type=string em objeto
    
    // Validar
    LResult := LComposer.QuickValidate(qvlStandard);
    WriteLn(FormatValidationResult(LResult));
    
  finally
    LComposer.Free;
  end;
end;

procedure DemonstrateSmartSuggestions;
var
  LComposer: TEnhancedSchemaComposer;
  LSuggestions: string;
begin
  WriteLn('');
  WriteLn('=== DEMONSTRAÇÃO: SUGESTÕES INTELIGENTES ===');
  
  LComposer := TEnhancedSchemaComposer.Create;
  try
    LComposer.ConfigureSmartMode(CreateDefaultSmartConfig);
    
    // Iniciar schema de objeto
    LComposer.Obj.Typ('object');
    
    // Obter sugestões
    LSuggestions := LComposer.SuggestNextEnhanced;
    WriteLn(LSuggestions);
    
  finally
    LComposer.Free;
  end;
end;

end.