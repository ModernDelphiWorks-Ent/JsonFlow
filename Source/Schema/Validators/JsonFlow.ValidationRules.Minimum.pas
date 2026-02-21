unit JsonFlow.ValidationRules.Minimum;

interface

uses
  System.SysUtils, System.Classes,
  JsonFlow4D.Interfaces, JsonFlow4D.ValidationEngine,
  JsonFlow4D.ValidationRules.Base;

type
  // Regra de validação de valor mínimo
  TMinimumRule = class(TBaseValidationRule)
  private
    FMinValue: Double;
  public
    constructor Create(AMinValue: Double);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TMinimumRule }

constructor TMinimumRule.Create(AMinValue: Double);
begin
  inherited Create('minimum');
  FMinValue := AMinValue;
end;

function TMinimumRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LValue: IJSONValue;
  LError: TValidationError;
  LValidationContext: TValidationContext;
begin
  LValidationContext := TValidationContext(AContext);
  
  if not Supports(AValue, IJSONValue, LValue) then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be a number for minimum validation',
      'non-number',
      'number',
      'minimum'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  if not (LValue.IsInteger or LValue.IsFloat) then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be a number for minimum validation',
      'non-number',
      'number',
      'minimum'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  if LValue.AsFloat >= FMinValue then
    Result := TValidationResult.Success(LValidationContext.GetFullPath)
  else
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      Format('Value %g is less than minimum %g', [LValue.AsFloat, FMinValue]),
      FloatToStr(LValue.AsFloat),
      FloatToStr(FMinValue),
      'minimum'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
  end;
end;

end.