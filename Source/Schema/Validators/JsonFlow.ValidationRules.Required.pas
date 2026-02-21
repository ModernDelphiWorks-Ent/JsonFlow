unit JsonFlow.ValidationRules.Required;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  JsonFlow4D.Interfaces, JsonFlow4D.ValidationEngine,
  JsonFlow4D.ValidationRules.Base;

type
  // Regra de validação de propriedades obrigatórias
  TRequiredRule = class(TBaseValidationRule)
  private
    FRequiredProperties: TArray<string>;
  public
    constructor Create(const ARequiredProperties: TArray<string>);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TRequiredRule }

constructor TRequiredRule.Create(const ARequiredProperties: TArray<string>);
begin
  inherited Create('required');
  FRequiredProperties := ARequiredProperties;
end;

function TRequiredRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LObject: IJSONObject;
  LError: TValidationError;
  LValidationContext: TValidationContext;
  LRequiredProp: string;
  LMissingProps: TList<string>;
  LErrors: TArray<TValidationError>;
  LFor: Integer;
begin
  LValidationContext := TValidationContext(AContext);

  if not Supports(AValue, IJSONObject, LObject) then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be an object for required validation',
      'non-object',
      'object',
      'required',
      LValidationContext.GetFullPath + '/required'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  LMissingProps := TList<string>.Create;
  try
    // Verificar se todas as propriedades obrigatórias estão presentes
    for LRequiredProp in FRequiredProperties do
    begin
      if not LObject.ContainsKey(LRequiredProp) then
        LMissingProps.Add(LRequiredProp);
    end;

    if LMissingProps.Count = 0 then
      Result := TValidationResult.Success(LValidationContext.GetFullPath)
    else
    begin
      // Criar erros para cada propriedade ausente
      SetLength(LErrors, LMissingProps.Count);
      for LFor := 0 to LMissingProps.Count - 1 do
      begin
        LErrors[LFor] := CreateValidationError(
          LValidationContext.GetFullPath + '/' + LMissingProps[LFor],
          Format('Required property "%s" is missing', [LMissingProps[LFor]]),
          'missing',
          'present',
          'required',
          LValidationContext.GetFullPath + '/required'
        );
      end;
      Result := TValidationResult.Failure(LValidationContext.GetFullPath, LErrors);
    end;
  finally
    LMissingProps.Free;
  end;
end;

end.