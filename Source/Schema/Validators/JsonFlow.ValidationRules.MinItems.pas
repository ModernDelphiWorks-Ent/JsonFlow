unit JsonFlow.ValidationRules.MinItems;

interface

uses
  System.SysUtils, System.Classes,
  JsonFlow4D.Interfaces, JsonFlow4D.ValidationEngine,
  JsonFlow4D.ValidationRules.Base;

type
  // Regra de validação de número mínimo de itens em array
  TMinItemsRule = class(TBaseValidationRule)
  private
    FMinItems: Integer;
  public
    constructor Create(AMinItems: Integer);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TMinItemsRule }

constructor TMinItemsRule.Create(AMinItems: Integer);
begin
  inherited Create('minItems');
  FMinItems := AMinItems;
end;

function TMinItemsRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LArray: IJSONArray;
  LError: TValidationError;
  LValidationContext: TValidationContext;
  LItemCount: Integer;
begin
  LValidationContext := TValidationContext(AContext);
  
  if not Supports(AValue, IJSONArray, LArray) then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be an array for minItems validation',
      'non-array',
      'array',
      'minItems'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  LItemCount := LArray.Count;
  
  if LItemCount >= FMinItems then
    Result := TValidationResult.Success(LValidationContext.GetFullPath)
  else
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      Format('Array has %d items, minimum required is %d', [LItemCount, FMinItems]),
      IntToStr(LItemCount),
      IntToStr(FMinItems),
      'minItems'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
  end;
end;

end.