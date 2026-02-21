unit JsonFlow.ValidationRules.ExclusiveMaximum;

interface

uses
  System.SysUtils, System.Classes,
  JsonFlow4D.Interfaces, JsonFlow4D.ValidationEngine,
  JsonFlow4D.ValidationRules.Base;

type
  // Regra de validação de máximo exclusivo
  TExclusiveMaximumRule = class(TBaseValidationRule)
  private
    FMaxValue: Double;
  public
    constructor Create(AMaxValue: Double);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TExclusiveMaximumRule }

constructor TExclusiveMaximumRule.Create(AMaxValue: Double);
begin
  inherited Create('exclusiveMaximum');
  FMaxValue := AMaxValue;
end;

function TExclusiveMaximumRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
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
      'Value must be a number for exclusiveMaximum validation',
      'non-number',
      'number',
      'exclusiveMaximum'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  if not (LValue.IsInteger or LValue.IsFloat) then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be a number for exclusiveMaximum validation',
      'non-number',
      'number',
      'exclusiveMaximum'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  if LValue.AsFloat < FMaxValue then
    Result := TValidationResult.Success(LValidationContext.GetFullPath)
  else
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      Format('Value %g is not less than exclusiveMaximum %g', [LValue.AsFloat, FMaxValue]),
      FloatToStr(LValue.AsFloat),
      FloatToStr(FMaxValue),
      'exclusiveMaximum'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
  end;
end;

end.