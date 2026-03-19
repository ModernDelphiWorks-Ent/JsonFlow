unit JsonFlow.ValidationRules.Ref;

interface

uses
  System.SysUtils,
  JsonFlow.Interfaces,
  JsonFlow.ValidationEngine,
  JsonFlow.ValidationRules.Base;

type
  TRefRule = class(TBaseValidationRule)
  private
    FRef: string;
  public
    constructor Create(const ARef: string);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TRefRule }

constructor TRefRule.Create(const ARef: string);
begin
  inherited Create('$ref');
  FRef := ARef;
end;

function TRefRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LValidationContext: TValidationContext;
  LError: TValidationError;
begin
  LValidationContext := TValidationContext(AContext);
  LError := CreateValidationError(
    LValidationContext.GetFullPath,
    Format('Unresolved $ref "%s"', [FRef]),
    FRef,
    'resolvable reference',
    '$ref',
    LValidationContext.GetFullSchemaPath + '/$ref'
  );
  Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
end;

end.

