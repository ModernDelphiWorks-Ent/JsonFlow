unit JsonFlow.ValidationRules.MaxLength;

interface

uses
  System.SysUtils, System.Classes,
  JsonFlow4D.Interfaces, JsonFlow4D.ValidationEngine,
  JsonFlow4D.ValidationRules.Base;

type
  // Regra de validação de comprimento máximo
  TMaxLengthRule = class(TBaseValidationRule)
  private
    FMaxLength: Integer;
  public
    constructor Create(AMaxLength: Integer);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TMaxLengthRule }

constructor TMaxLengthRule.Create(AMaxLength: Integer);
begin
  inherited Create('maxLength');
  FMaxLength := AMaxLength;
end;

function TMaxLengthRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
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
      'Value must be a string or array for maxLength validation',
      'invalid type',
      'string or array',
      'maxLength'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  if LLength <= FMaxLength then
    Result := TValidationResult.Success(LValidationContext.GetFullPath)
  else
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      Format('Length %d is greater than maximum length %d', [LLength, FMaxLength]),
      IntToStr(LLength),
      IntToStr(FMaxLength),
      'maxLength'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
  end;
end;

end.