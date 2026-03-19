unit JsonFlow.TestsSchemaSchemaPathCombinators;

interface

uses
  DUnitX.TestFramework,
  JsonFlow.SchemaReader,
  JsonFlow.Interfaces;

type
  [TestFixture]
  TSchemaPathCombinatorsTests = class
  private
    FReader: TJSONSchemaReader;
    function HasSchemaPath(const AErrors: TArray<TValidationError>; const AExpected: string): Boolean;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestSchemaPath_AnyOf_Index;
    [Test]
    procedure TestSchemaPath_Required_Deep;
  end;

implementation

uses
  System.SysUtils;

function JoinErrors(const AErrors: TArray<TValidationError>): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(AErrors) - 1 do
  begin
    if Result <> '' then
      Result := Result + ' | ';
    Result := Result + AErrors[I].Message;
  end;
end;

procedure TSchemaPathCombinatorsTests.Setup;
begin
  FReader := TJSONSchemaReader.Create;
end;

procedure TSchemaPathCombinatorsTests.TearDown;
begin
  FReader.Free;
end;

function TSchemaPathCombinatorsTests.HasSchemaPath(const AErrors: TArray<TValidationError>; const AExpected: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(AErrors) - 1 do
  begin
    if AErrors[I].SchemaPath = AExpected then
      Exit(True);
  end;
end;

procedure TSchemaPathCombinatorsTests.TestSchemaPath_AnyOf_Index;
var
  LSchema: string;
  LErrors: TArray<TValidationError>;
begin
  LSchema := '{"anyOf":[{"type":"string","minLength":3},{"type":"integer"}]}' ;
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  Assert.IsFalse(FReader.Validate('"hi"'));
  LErrors := FReader.GetErrors;
  Assert.IsTrue(Length(LErrors) > 0);

  Assert.IsTrue(HasSchemaPath(LErrors, '/anyOf/0/minLength'));
  Assert.IsTrue(HasSchemaPath(LErrors, '/anyOf/1/type'));
end;

procedure TSchemaPathCombinatorsTests.TestSchemaPath_Required_Deep;
var
  LSchema: string;
  LErrors: TArray<TValidationError>;
begin
  LSchema :=
    '{' +
    '  "type":"object",' +
    '  "properties": {' +
    '    "a": {' +
    '      "type":"object",' +
    '      "properties": {"b": {"type":"string"}},' +
    '      "required": ["b"]' +
    '    }' +
    '  },' +
    '  "required": ["a"]' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('{"a":{}}'));
  LErrors := FReader.GetErrors;
  Assert.IsTrue(Length(LErrors) > 0);
  Assert.IsTrue(HasSchemaPath(LErrors, '/properties/a/required'));
end;

initialization
  TDUnitX.RegisterTestFixture(TSchemaPathCombinatorsTests);

end.

