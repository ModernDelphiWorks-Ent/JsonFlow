unit JsonFlow4D.TestsObjects;

interface

uses
  System.SysUtils,
  DUnitX.TestFramework,
  JsonFlow4D.Interfaces,
  JsonFlow4D.Value,
  JsonFlow4D.Pair,
  JsonFlow4D.Objects;

type
  [TestFixture]
  TJSONObjectTests = class
  public
    [Test]
    procedure TestAddAndGetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestRemove;
    [Test]
    procedure TestAsJSON;
    [Test]
    procedure TestFilter;
    [Test]
    procedure TestMap;
    [Test]
    procedure TestClone;
    [Test]
    procedure TestCount;
    [Test]
    procedure TestDataType;
  end;

implementation

procedure TJSONObjectTests.TestAddAndGetValue;
var
  LObj: IJSONObject;
begin
  LObj := TJSONObject.Create;
  LObj.Add('name', TJSONValueString.Create('Jo�o'));
  Assert.AreEqual('Jo�o', (LObj.GetValue('name') as IJSONValue).AsString);
end;

procedure TJSONObjectTests.TestContainsKey;
var
  LObj: IJSONObject;
begin
  LObj := TJSONObject.Create;
  LObj.Add('name', TJSONValueString.Create('Jo�o'));
  Assert.IsTrue(LObj.ContainsKey('name'));
  Assert.IsFalse(LObj.ContainsKey('age'));
end;

procedure TJSONObjectTests.TestRemove;
var
  LObj: IJSONObject;
begin
  LObj := TJSONObject.Create;
  LObj.Add('name', TJSONValueString.Create('Jo�o'));
  LObj.Remove('name');
  Assert.IsFalse(LObj.ContainsKey('name'));
end;

procedure TJSONObjectTests.TestAsJSON;
var
  LObj: IJSONObject;
begin
  LObj := TJSONObject.Create;
  LObj.Add('name', TJSONValueString.Create('Jo�o'));
  LObj.Add('age', TJSONValueInteger.Create(30));
  Assert.AreEqual('{"name":"Jo�o","age":30}', LObj.AsJSON);
end;

procedure TJSONObjectTests.TestFilter;
var
  LObj, LFiltered: IJSONObject;
begin
  LObj := TJSONObject.Create;
  LObj.Add('name', TJSONValueString.Create('Jo�o'));
  LObj.Add('age', TJSONValueInteger.Create(30));
  LFiltered := LObj.Filter(
    function(AKey: String; AValue: IJSONElement): Boolean
    begin
      Result := AKey = 'name';
    end);
  Assert.IsTrue(LFiltered.ContainsKey('name'));
  Assert.IsFalse(LFiltered.ContainsKey('age'));
end;

procedure TJSONObjectTests.TestMap;
var
  LObj, LMapped: IJSONObject;
  LExpected: Int64;
begin
  LExpected := 31;
  LObj := TJSONObject.Create;
  LObj.Add('age', TJSONValueInteger.Create(30));
  LMapped := LObj.Map(
    function(AKey: String; AValue: IJSONElement): IJSONPair
    begin
      Result := TJSONPair.Create(AKey, TJSONValueInteger.Create((AValue as IJSONValue).AsInteger + 1));
    end);
  Assert.AreEqual(LExpected, (LMapped.GetValue('age') as IJSONValue).AsInteger);
end;

procedure TJSONObjectTests.TestCount;
var
  LObj: IJSONObject;
begin
  LObj := TJSONObject.Create;
  Assert.AreEqual(0, LObj.Count);
  LObj.Add('name', TJSONValueString.Create('Jo�o'));
  Assert.AreEqual(1, LObj.Count);
  LObj.Add('age', TJSONValueInteger.Create(30));
  Assert.AreEqual(2, LObj.Count);
end;

procedure TJSONObjectTests.TestDataType;
var
  LObj: IJSONObject;
begin
  LObj := TJSONObject.Create;
  Assert.IsTrue(Supports(LObj, IJSONObject), 'Tipo deve ser object');
end;

procedure TJSONObjectTests.TestClone;
var
  LObj, LClone: IJSONObject;
begin
  LObj := TJSONObject.Create;
  LObj.Add('name', TJSONValueString.Create('Jo�o'));
  LClone := LObj.Clone as IJSONObject;
  Assert.AreEqual('Jo�o', (LClone.GetValue('name') as IJSONValue).AsString);
  LClone.Add('age', TJSONValueInteger.Create(30));
  Assert.IsFalse(LObj.ContainsKey('age'));
end;

initialization
  TDUnitX.RegisterTestFixture(TJSONObjectTests);

end.

