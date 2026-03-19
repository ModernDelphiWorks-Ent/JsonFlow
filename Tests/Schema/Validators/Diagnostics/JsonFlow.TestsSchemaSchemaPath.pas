unit JsonFlow.TestsSchemaSchemaPath;

interface

uses
  DUnitX.TestFramework,
  JsonFlow.SchemaReader,
  JsonFlow.Interfaces;

type
  [TestFixture]
  TSchemaPathTests = class
  private
    FReader: TJSONSchemaReader;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestSchemaPath_NestedMinLength;
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

procedure TSchemaPathTests.Setup;
begin
  FReader := TJSONSchemaReader.Create;
end;

procedure TSchemaPathTests.TearDown;
begin
  FReader.Free;
end;

procedure TSchemaPathTests.TestSchemaPath_NestedMinLength;
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
    '      "properties": {' +
    '        "b": {"type":"string","minLength": 3}' +
    '      },' +
    '      "required": ["b"]' +
    '    }' +
    '  },' +
    '  "required": ["a"]' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('{"a":{"b":"hi"}}'));

  LErrors := FReader.GetErrors;
  Assert.IsTrue(Length(LErrors) > 0);
  Assert.AreEqual('/properties/a/properties/b/minLength', LErrors[0].SchemaPath);
end;

initialization
  TDUnitX.RegisterTestFixture(TSchemaPathTests);

end.

