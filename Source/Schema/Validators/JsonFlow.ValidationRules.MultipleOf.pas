unit JsonFlow.ValidationRules.MultipleOf;

interface

uses
  System.SysUtils, System.Classes, System.Math,
  JsonFlow4D.Interfaces, JsonFlow4D.ValidationEngine,
  JsonFlow4D.ValidationRules.Base;

type
  // Regra de validação de múltiplo de
  TMultipleOfRule = class(TBaseValidationRule)
  private
    FDivisor: Double;
  public
    constructor Create(ADivisor: Double);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TMultipleOfRule }

constructor TMultipleOfRule.Create(ADivisor: Double);
begin
  inherited Create('multipleOf');
  FDivisor := ADivisor;
end;

function TMultipleOfRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LValue: IJSONValue;
  LError: TValidationError;
  LValidationContext: TValidationContext;
  LRemainder: Double;
begin
  LValidationContext := TValidationContext(AContext);
  
  if not Supports(AValue, IJSONValue, LValue) then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be a number for multipleOf validation',
      'non-number',
      'number',
      'multipleOf'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  if not (LValue.IsInteger or LValue.IsFloat) then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be a number for multipleOf validation',
      'non-number',
      'number',
      'multipleOf'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  LRemainder := Frac(LValue.AsFloat / FDivisor);
  if Abs(LRemainder) < 1e-10 then // Tolerância para ponto flutuante
    Result := TValidationResult.Success(LValidationContext.GetFullPath)
  else
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      Format('Value %g is not a multiple of %g', [LValue.AsFloat, FDivisor]),
      FloatToStr(LValue.AsFloat),
      FloatToStr(FDivisor),
      'multipleOf'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
  end;
end;

end.