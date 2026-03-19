unit JsonFlow.TestsSchemaCombinatorsAndConditionals;

interface

uses
  DUnitX.TestFramework,
  JsonFlow.SchemaReader,
  JsonFlow.Interfaces;

type
  [TestFixture]
  TSchemaCombinatorsAndConditionalsTests = class
  private
    FReader: TJSONSchemaReader;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestAnyOf_NoMatches_ShouldFail;
    [Test]
    procedure TestOneOf_MultipleMatches_ShouldFail;
    [Test]
    procedure TestAllOf_OneFails_ShouldFail;
    [Test]
    procedure TestNot_WhenMatches_ShouldFail;

    [Test]
    procedure TestIfThenElse_ThenBranch_ShouldFail;
    [Test]
    procedure TestIfThenElse_ElseBranch_ShouldFail;
    [Test]
    procedure TestIfThenElse_BothBranches_ShouldPass;
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

procedure TSchemaCombinatorsAndConditionalsTests.Setup;
begin
  FReader := TJSONSchemaReader.Create;
end;

procedure TSchemaCombinatorsAndConditionalsTests.TearDown;
begin
  FReader.Free;
end;

procedure TSchemaCombinatorsAndConditionalsTests.TestAnyOf_NoMatches_ShouldFail;
var
  LSchema: string;
begin
  LSchema := '{"anyOf":[{"type":"integer"},{"type":"string","minLength":3}]}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('false'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaCombinatorsAndConditionalsTests.TestOneOf_MultipleMatches_ShouldFail;
var
  LSchema: string;
begin
  LSchema := '{"oneOf":[{"type":"string"},{"const":"a"}]}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('"a"'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaCombinatorsAndConditionalsTests.TestAllOf_OneFails_ShouldFail;
var
  LSchema: string;
begin
  LSchema := '{"allOf":[{"type":"string"},{"minLength":3}]}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('"hi"'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaCombinatorsAndConditionalsTests.TestNot_WhenMatches_ShouldFail;
var
  LSchema: string;
begin
  LSchema := '{"not":{"type":"string"}}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('"a"'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaCombinatorsAndConditionalsTests.TestIfThenElse_ThenBranch_ShouldFail;
var
  LSchema: string;
begin
  LSchema :=
    '{' +
    '  "type":"object",' +
    '  "if": {"properties":{"flag":{"const":true}},"required":["flag"]},' +
    '  "then": {"required":["a"]},' +
    '  "else": {"required":["b"]}' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('{"flag":true}'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaCombinatorsAndConditionalsTests.TestIfThenElse_ElseBranch_ShouldFail;
var
  LSchema: string;
begin
  LSchema :=
    '{' +
    '  "type":"object",' +
    '  "if": {"properties":{"flag":{"const":true}},"required":["flag"]},' +
    '  "then": {"required":["a"]},' +
    '  "else": {"required":["b"]}' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('{"flag":false}'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaCombinatorsAndConditionalsTests.TestIfThenElse_BothBranches_ShouldPass;
var
  LSchema: string;
begin
  LSchema :=
    '{' +
    '  "type":"object",' +
    '  "if": {"properties":{"flag":{"const":true}},"required":["flag"]},' +
    '  "then": {"required":["a"]},' +
    '  "else": {"required":["b"]}' +
    '}';

  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  Assert.IsTrue(FReader.Validate('{"flag":true,"a":1}'));
  Assert.IsTrue(FReader.Validate('{"flag":false,"b":1}'));
end;

initialization
  TDUnitX.RegisterTestFixture(TSchemaCombinatorsAndConditionalsTests);

end.

