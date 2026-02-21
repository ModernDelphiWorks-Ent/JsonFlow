unit JsonFlow.ValidationRules.MinLength;

interface

uses
  System.SysUtils, System.Classes,
  JsonFlow4D.Interfaces, JsonFlow4D.ValidationEngine,
  JsonFlow4D.ValidationRules.Base;

type
  // Regra de validação de comprimento mínimo
  TMinLengthRule = class(TBaseValidationRule)
  private
    FMinLength: Integer;
  public
    constructor Create(AMinLength: Integer);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TMinLengthRule }

constructor TMinLengthRule.Create(AMinLength: Integer);
begin
  inherited Create('minLength');
  FMinLength := AMinLength;
end;

function TMinLengthRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LValue: IJSONValue;
  LArray: IJSONArray;
  LLength: Integer;
  LError: TValidationError;
  LValidationContext: TValidationContext;
begin
  LValidationContext := TValidationContext(AContext);
  
  if Supports(AValue, IJSONValue, LValue) and LValue.IsString then
    LLength := Length(LValue.AsString)
  else if Supports(AValue, IJSONArray, LArray) then
    LLength := LArray.Count
  else
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be a string or array for minLength validation',
      'invalid type',
      'string or array',
      'minLength'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  if LLength >= FMinLength then
    Result := TValidationResult.Success(LValidationContext.GetFullPath)
  else
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      Format('Length %d is less than minimum length %d', [LLength, FMinLength]),
      IntToStr(LLength),
      IntToStr(FMinLength),
      'minLength'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
  end;
end;

end.