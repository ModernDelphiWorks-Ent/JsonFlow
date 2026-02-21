unit JsonFlow.ValidationRules.Base;

interface

uses
  System.SysUtils,
  System.Classes,
  JsonFlow4D.Interfaces,
  JsonFlow4D.ValidationEngine;

type
  // Regra base para todas as regras de validação
  TBaseValidationRule = class(TInterfacedObject, IValidationRule)
  protected
    FKeyword: string;
  public
    constructor Create(const AKeyword: string);
    function GetRuleType: TRuleType; virtual;
    function GetKeyword: string;
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; virtual; abstract;
  end;

implementation

{ TBaseValidationRule }

constructor TBaseValidationRule.Create(const AKeyword: string);
begin
  inherited Create;
  FKeyword := AKeyword;
end;

function TBaseValidationRule.GetRuleType: TRuleType;
begin
  Result := rtPrimitive;
end;

function TBaseValidationRule.GetKeyword: string;
begin
  Result := FKeyword;
end;

end.