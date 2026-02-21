unit JsonFlow.ValidationRules.Types;

interface

uses
  System.SysUtils, System.Classes,
  JsonFlow4D.Interfaces, JsonFlow4D.ValidationEngine,
  JsonFlow4D.ValidationRules.Base;

type
  // Regra de validação de tipo
  TTypeRule = class(TBaseValidationRule)
  private
    FExpectedType: string;
  public
    constructor Create(const AExpectedType: string);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TTypeRule }

constructor TTypeRule.Create(const AExpectedType: string);
begin
  inherited Create('type');
  FExpectedType := AExpectedType;
end;

function TTypeRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LActualType: string;
  LValue: IJSONValue;
  LError: TValidationError;
  LValidationContext: TValidationContext;
begin
  LValidationContext := TValidationContext(AContext);
  
  // Determinar o tipo atual do valor
  if Supports(AValue, IJSONValue) then
  begin
    LValue := AValue as IJSONValue;
    if LValue.IsString then
      LActualType := 'string'
    else if LValue.IsInteger or LValue.IsFloat then
      LActualType := 'number'
    else if LValue.IsBoolean then
      LActualType := 'boolean'
    else if LValue.IsNull then
      LActualType := 'null'
    else
      LActualType := 'unknown';
  end
  else if Supports(AValue, IJSONArray) then
    LActualType := 'array'
  else if Supports(AValue, IJSONObject) then
    LActualType := 'object'
  else
    LActualType := 'unknown';

  if LActualType = FExpectedType then
    Result := TValidationResult.Success(LValidationContext.GetFullPath)
  else
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      Format('Expected type %s, found %s', [FExpectedType, LActualType]),
      LActualType,
      FExpectedType,
      'type'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
  end;
end;

end.