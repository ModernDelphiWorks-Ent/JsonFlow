unit JsonFlow.TestsSchemaArrayTupleItems;

interface

uses
  DUnitX.TestFramework,
  JsonFlow.SchemaReader,
  JsonFlow.Interfaces;

type
  [TestFixture]
  TSchemaArrayTupleItemsTests = class
  private
    FReader: TJSONSchemaReader;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestItems_Tuple_ByIndex_ShouldPass;
    [Test]
    procedure TestItems_Tuple_ByIndex_ShouldFail;
    [Test]
    procedure TestAdditionalItems_False_ShouldFail;
    [Test]
    procedure TestAdditionalItems_Schema_ShouldValidate;
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

procedure TSchemaArrayTupleItemsTests.Setup;
begin
  FReader := TJSONSchemaReader.Create;
end;

procedure TSchemaArrayTupleItemsTests.TearDown;
begin
  FReader.Free;
end;

procedure TSchemaArrayTupleItemsTests.TestItems_Tuple_ByIndex_ShouldPass;
var
  LSchema: string;
  LJson: string;
begin
  LSchema := '{"type":"array","items":[{"type":"string"},{"type":"integer"}]}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  LJson := '["a", 1]';
  Assert.IsTrue(FReader.Validate(LJson));
  Assert.AreEqual(0, Length(FReader.GetErrors));
end;

procedure TSchemaArrayTupleItemsTests.TestItems_Tuple_ByIndex_ShouldFail;
var
  LSchema: string;
  LJson: string;
begin
  LSchema := '{"type":"array","items":[{"type":"string"},{"type":"integer"}]}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  LJson := '["a", "b"]';
  Assert.IsFalse(FReader.Validate(LJson));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaArrayTupleItemsTests.TestAdditionalItems_False_ShouldFail;
var
  LSchema: string;
  LJson: string;
begin
  LSchema := '{"type":"array","items":[{"type":"string"}],"additionalItems":false}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  LJson := '["a", "b"]';
  Assert.IsFalse(FReader.Validate(LJson));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaArrayTupleItemsTests.TestAdditionalItems_Schema_ShouldValidate;
var
  LSchema: string;
begin
  LSchema := '{"type":"array","items":[{"type":"string"}],"additionalItems":{"type":"integer"}}';
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  Assert.IsTrue(FReader.Validate('["a", 1]'));
  Assert.IsFalse(FReader.Validate('["a", "b"]'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

initialization
  TDUnitX.RegisterTestFixture(TSchemaArrayTupleItemsTests);

end.

