unit JsonFlow.TestsSchemaRefs;

interface

uses
  DUnitX.TestFramework,
  JsonFlow.SchemaReader,
  JsonFlow.Interfaces;

type
  [TestFixture]
  TSchemaRefResolutionTests = class
  private
    FReader: TJSONSchemaReader;
    function FixturePath(const AFileName: string): string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestLocalDefs_Ref_Deep;
    [Test]
    procedure TestFileRef_WithRelativePath;
    [Test]
    procedure TestCircularRef_Detected;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils;

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

procedure TSchemaRefResolutionTests.Setup;
begin
  FReader := TJSONSchemaReader.Create;
end;

procedure TSchemaRefResolutionTests.TearDown;
begin
  FReader.Free;
end;

function TSchemaRefResolutionTests.FixturePath(const AFileName: string): string;
begin
  Result := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), '.\Fixtures\Refs\' + AFileName));
end;

procedure TSchemaRefResolutionTests.TestLocalDefs_Ref_Deep;
var
  LSchema: string;
begin
  LSchema := TFile.ReadAllText(FixturePath('root-local-defs.json'));
  Assert.IsTrue(FReader.LoadFromString(LSchema), JoinErrors(FReader.GetErrors));

  Assert.IsTrue(FReader.Validate('{"a":{"b":"abc"}}'));
  Assert.IsFalse(FReader.Validate('{"a":{"b":"hi"}}'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaRefResolutionTests.TestFileRef_WithRelativePath;
begin
  Assert.IsTrue(FReader.LoadFromFile(FixturePath('root-file-ref.json')), JoinErrors(FReader.GetErrors));

  Assert.IsTrue(FReader.Validate('{"zip":"12345678"}'));
  Assert.IsFalse(FReader.Validate('{"zip":"123"}'));
  Assert.IsTrue(Length(FReader.GetErrors) > 0);
end;

procedure TSchemaRefResolutionTests.TestCircularRef_Detected;
var
  LErrors: TArray<TValidationError>;
begin
  Assert.IsTrue(FReader.LoadFromFile(FixturePath('a.json')), JoinErrors(FReader.GetErrors));
  Assert.IsFalse(FReader.Validate('"x"'));
  LErrors := FReader.GetErrors;
  Assert.IsTrue(Length(LErrors) > 0);
  Assert.IsTrue((Pos('Unresolved $ref', LErrors[0].Message) > 0) or (Pos('Circular', LErrors[0].Message) > 0));
end;

initialization
  TDUnitX.RegisterTestFixture(TSchemaRefResolutionTests);

end.

