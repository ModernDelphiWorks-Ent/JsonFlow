unit JsonFlow.ValidationRules.NotRule;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  JsonFlow4D.Interfaces, JsonFlow4D.ValidationEngine,
  JsonFlow4D.ValidationRules.Base;

type
  // Regra de validação not - o valor não deve ser válido contra o esquema
  TNotRule = class(TBaseValidationRule)
  private
    FSchema: IJSONElement;
    function ValidateAgainstSchema(const AValue: IJSONElement; const ASchema: IJSONElement; const AContext: TValidationContext): TValidationResult;
  public
    constructor Create(const ASchema: IJSONElement);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

uses
  JsonFlow4D.ValidationRules.Types;

{ TNotRule }

constructor TNotRule.Create(const ASchema: IJSONElement);
begin
  inherited Create('not');
  FSchema := ASchema;
end;

function TNotRule.ValidateAgainstSchema(const AValue: IJSONElement; const ASchema: IJSONElement; const AContext: TValidationContext): TValidationResult;
var
  LSchemaObj: IJSONObject;
  LTypeValue: string;
  LTypeRule: IValidationRule;
begin
  if not Supports(ASchema, IJSONObject, LSchemaObj) then
  begin
    Result := TValidationResult.Success(AContext.GetFullPath);
    Exit;
  end;
  
  // Validação básica de tipo se especificado
  if LSchemaObj.ContainsKey('type') then
  begin
    LTypeValue := (LSchemaObj.GetValue('type') as IJSONValue).AsString;
    LTypeRule := TTypeRule.Create(LTypeValue);
    try
      Result := LTypeRule.Validate(AValue, AContext);
    finally
      LTypeRule := nil;
    end;
  end
  else
  begin
    Result := TValidationResult.Success(AContext.GetFullPath);
  end;
end;

function TNotRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LValidationContext: TValidationContext;
  LSchemaResult: TValidationResult;
  LError: TValidationError;
begin
  LValidationContext := TValidationContext(AContext);
  
  // Validar contra o esquema
  LSchemaResult := ValidateAgainstSchema(AValue, FSchema, LValidationContext);
  
  // Se o esquema é válido, então a regra 'not' falha
  if LSchemaResult.IsValid then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value should not be valid against the schema in not',
      'valid',
      'invalid',
      'not'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
  end
  else
  begin
    // Se o esquema é inválido, então a regra 'not' é bem-sucedida
    Result := TValidationResult.Success(LValidationContext.GetFullPath);
  end;
end;

end.