unit JsonFlow.TestsNavigator;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  JsonFlow,
  JsonFlow.Reader,
  JsonFlow.Navigator;

type
  [TestFixture]
  TJSONNavigatorTests = class
  public
    [Test]
    procedure TestNavigateSimpleValue;
    [Test]
    procedure TestNavigateObject;
    [Test]
    procedure TestNavigateArray;
    [Test]
    procedure TestNavigateNested;
    [Test]
    procedure TestNavigateInvalidPath;
    [Test]
    procedure TestNavigateNull;
  end;

implementation

uses
  System.StrUtils,
  JsonFlow.Value,
  JsonFlow.Interfaces;

procedure TJSONNavigatorTests.TestNavigateSimpleValue;
var
  LJsonFlow: TJsonFlow;
  LNav: TJSONNavigator;
begin
  LJsonFlow := TJsonFlow.Create;
  try
    LNav := TJSONNavigator.Create(LJsonFlow.Parse('{"nome":"Jo�o"}'));
    try
      Assert.AreEqual('Jo�o', LNav.GetString('nome'));
    finally
      LNav.Free;
    end;
  finally
    LJsonFlow.Free;
  end;
end;

procedure TJSONNavigatorTests.TestNavigateObject;
var
  LJsonFlow: TJsonFlow;
  LNav: TJSONNavigator;
  LObj: IJSONObject;
begin
  LJsonFlow := TJsonFlow.Create;
  try
    LNav := TJSONNavigator.Create(LJsonFlow.Parse('{"pessoa":{"nome":"Jo�o"}}'));
    try
      LObj := LNav.GetObject('pessoa');
      Assert.IsNotNull(LObj, 'Objeto "pessoa" deveria ser encontrado');
      Assert.AreEqual('Jo�o', LNav.GetString('pessoa.nome'));
    finally
      LNav.Free;
    end;
  finally
    LJsonFlow.Free;
  end;
end;

procedure TJSONNavigatorTests.TestNavigateArray;
var
  LJsonFlow: TJsonFlow;
  LNav: TJSONNavigator;
  LArr: IJSONArray;
  LElement: IJSONElement;
  LValue: IJSONValue;
begin
  LJsonFlow := TJsonFlow.Create;
  try
    LNav := TJSONNavigator.Create(LJsonFlow.Parse('{"itens":[10,20,30]}'));
    try
      LArr := LNav.GetArray('itens');
      Assert.IsNotNull(LArr, 'Array "itens" deveria ser encontrado');
      Assert.AreEqual(3, LArr.Count);

      LElement := LNav.GetValue('itens[0]');
      Assert.IsNotNull(LElement, 'Elemento "itens[0]" n�o encontrado');
      Assert.IsTrue(Supports(LElement, IJSONValue, LValue), 'Deveria suportar IJSONValue');
      Assert.IsTrue(LValue is TJSONValueInteger, 'Deveria ser TJSONValueInteger');
      Assert.AreEqual(Int64(10), LValue.AsInteger, 'Valor direto');
      Assert.AreEqual(Int64(10), LNav.GetInteger('itens[0]'), 'Via GetInteger');
    finally
      LNav.Free;
    end;
  finally
    LJsonFlow.Free;
  end;
end;


procedure TJSONNavigatorTests.TestNavigateNested;
var
  LJsonFlow: TJsonFlow;
  LNav: TJSONNavigator;
begin
  LJsonFlow := TJsonFlow.Create;
  try
    LNav := TJSONNavigator.Create(LJsonFlow.Parse('{"pessoa":{"enderecos":[{"rua":"Avenida X"}]}}'));
    try
      Assert.AreEqual('Avenida X', LNav.GetString('pessoa.enderecos[0].rua'));
    finally
      LNav.Free;
    end;
  finally
    LJsonFlow.Free;
  end;
end;

procedure TJSONNavigatorTests.TestNavigateInvalidPath;
var
  LJsonFlow: TJsonFlow;
  LNav: TJSONNavigator;
begin
  LJsonFlow := TJsonFlow.Create;
  try
    LNav := TJSONNavigator.Create(LJsonFlow.Parse('{"nome":"Jo�o"}'));
    try
      Assert.AreEqual('', LNav.GetString('invalido'), 'Caminho inv�lido deveria retornar vazio');
      Assert.AreEqual(Int64(0), LNav.GetInteger('nome.invalido'), 'Caminho inv�lido em objeto deveria retornar 0');
      Assert.IsFalse(LNav.IsNull('invalido'), 'Caminho inv�lido n�o � null');
    finally
      LNav.Free;
    end;
  finally
    LJsonFlow.Free;
  end;
end;

procedure TJSONNavigatorTests.TestNavigateNull;
var
  LJsonFlow: TJsonFlow;
  LNav: TJSONNavigator;
begin
  LJsonFlow := TJsonFlow.Create;
  try
    LNav := TJSONNavigator.Create(LJsonFlow.Parse('{"valor":null,"nome":"Jo�o"}'));
    try
      Assert.IsTrue(LNav.IsNull('valor'), 'Valor deveria ser null');
      Assert.AreEqual('null', LNav.GetString('valor'));
      Assert.AreEqual('Jo�o', LNav.GetString('nome'));
    finally
      LNav.Free;
    end;
  finally
    LJsonFlow.Free;
  end;
end;

end.

