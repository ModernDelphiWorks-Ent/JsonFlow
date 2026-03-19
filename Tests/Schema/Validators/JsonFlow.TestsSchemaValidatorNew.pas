unit JsonFlow.TestsSchemaValidatorNew;

interface

uses
  DUnitX.TestFramework,
  JsonFlow.Interfaces,
  JsonFlow.SchemaReader;

type
  [TestFixture]
  TJSONSchemaValidatorNewTests = class
  private
    FReader: TJSONSchemaReader;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestValidate_SimpleString;
    [Test]
    procedure TestValidate_SimpleNumber;
    [Test]
    procedure TestValidate_SimpleBoolean;
    [Test]
    procedure TestValidate_SimpleObject;
    [Test]
    procedure TestValidate_SimpleArray;
    [Test]
    procedure TestValidate_RequiredField;
    [Test]
    procedure TestValidate_RequiredField_Invalid;
    [Test]
    procedure TestValidate_MinLength;
    [Test]
    procedure TestValidate_MinLength_Invalid;
    [Test]
    procedure TestValidate_MaxLength;
    [Test]
    procedure TestValidate_MinimumNumber;
    [Test]
    procedure TestValidate_MaximumNumber;
  end;

implementation

uses
  System.SysUtils;

procedure TJSONSchemaValidatorNewTests.Setup;
begin
  FReader := TJSONSchemaReader.Create;
end;

procedure TJSONSchemaValidatorNewTests.TearDown;
begin
  FReader.Free;
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_SimpleString;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "string"}';
  FReader.LoadFromString(LSchema);
  LJson := '"test"';
  Assert.IsTrue(FReader.Validate(LJson), 'Should validate string correctly');
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_SimpleNumber;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "number"}';
  FReader.LoadFromString(LSchema);
  LJson := '42';
  Assert.IsTrue(FReader.Validate(LJson), 'Should validate number correctly');
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_SimpleBoolean;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "boolean"}';
  FReader.LoadFromString(LSchema);
  LJson := 'true';
  Assert.IsTrue(FReader.Validate(LJson), 'Should validate boolean correctly');
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_SimpleObject;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "object"}';
  FReader.LoadFromString(LSchema);
  LJson := '{"name": "test"}';
  Assert.IsTrue(FReader.Validate(LJson), 'Should validate object correctly');
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_SimpleArray;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "array"}';
  FReader.LoadFromString(LSchema);
  LJson := '[1, 2, 3]';
  Assert.IsTrue(FReader.Validate(LJson), 'Should validate array correctly');
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_RequiredField;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "object", "properties": {"name": {"type": "string"}}, "required": ["name"]}';
  FReader.LoadFromString(LSchema);
  LJson := '{"name": "test"}';
  Assert.IsTrue(FReader.Validate(LJson), 'Should validate required field correctly');
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_RequiredField_Invalid;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "object", "properties": {"name": {"type": "string"}}, "required": ["name"]}';
  FReader.LoadFromString(LSchema);
  LJson := '{}';
  Assert.IsFalse(FReader.Validate(LJson), 'Should fail when required field is missing');
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_MinLength;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "string", "minLength": 3}';
  FReader.LoadFromString(LSchema);
  LJson := '"test"';
  Assert.IsTrue(FReader.Validate(LJson), 'Should validate minLength correctly');
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_MinLength_Invalid;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "string", "minLength": 3}';
  FReader.LoadFromString(LSchema);
  LJson := '"hi"';
  Assert.IsFalse(FReader.Validate(LJson), 'Should fail for string shorter than minLength');
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_MaxLength;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "string", "maxLength": 10}';
  FReader.LoadFromString(LSchema);
  LJson := '"test"';
  Assert.IsTrue(FReader.Validate(LJson), 'Should validate maxLength correctly');
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_MinimumNumber;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "number", "minimum": 10}';
  FReader.LoadFromString(LSchema);
  LJson := '15';
  Assert.IsTrue(FReader.Validate(LJson), 'Should validate minimum correctly');
end;

procedure TJSONSchemaValidatorNewTests.TestValidate_MaximumNumber;
var
  LSchema: String;
  LJson: String;
begin
  LSchema := '{"type": "number", "maximum": 100}';
  FReader.LoadFromString(LSchema);
  LJson := '50';
  Assert.IsTrue(FReader.Validate(LJson), 'Should validate maximum correctly');
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONSchemaValidatorNewTests);

end.
