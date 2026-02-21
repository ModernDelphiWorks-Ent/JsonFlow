unit JsonFlow.ValidationRules.ExclusiveMinimum;

interface

uses
  System.SysUtils, System.Classes,
  JsonFlow4D.Interfaces, JsonFlow4D.ValidationEngine,
  JsonFlow4D.ValidationRules.Base;

type
  // Regra de validação de mínimo exclusivo
  TExclusiveMinimumRule = class(TBaseValidationRule)
  private
    FMinValue: Double;
  public
    constructor Create(AMinValue: Double);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TExclusiveMinimumRule }

constructor TExclusiveMinimumRule.Create(AMinValue: Double);
begin
  inherited Create('exclusiveMinimum');
  FMinValue := AMinValue;
end;

function TExclusiveMinimumRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
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
      'Value must be a number for exclusiveMinimum validation',
      'non-number',
      'number',
      'exclusiveMinimum'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  if not (LValue.IsInteger or LValue.IsFloat) then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be a number for exclusiveMinimum validation',
      'non-number',
      'number',
      'exclusiveMinimum'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  if LValue.AsFloat > FMinValue then
    Result := TValidationResult.Success(LValidationContext.GetFullPath)
  else
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      Format('Value %g is not greater than exclusiveMinimum %g', [LValue.AsFloat, FMinValue]),
      FloatToStr(LValue.AsFloat),
      FloatToStr(FMinValue),
      'exclusiveMinimum'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
  end;
end;

end.