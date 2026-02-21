unit ComposerFluentSyntaxDemo;

interface

uses
  System.SysUtils,
  System.Variants,
  System.Generics.Collections,
  JsonFlow4D.Interfaces,
  JsonFlow4D.Composer,
  JsonFlow4D.Objects,
  JsonFlow4D.Arrays,
  JsonFlow4D.Value;

type
  // Interface para sintaxe fluente moderna
  IJSONFluentBuilder = interface
    ['{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}']
    function Str(const AName, AValue: string): IJSONFluentBuilder;
    function Num(const AName: string; AValue: Double): IJSONFluentBuilder;
    function Int(const AName: string; AValue: Integer): IJSONFluentBuilder;
    function Bool(const AName: string; AValue: Boolean): IJSONFluentBuilder;
    function Null(const AName: string): IJSONFluentBuilder;
    function DateTime(const AName: string; AValue: TDateTime): IJSONFluentBuilder;
    function Obj(const AName: string; ACallback: TProc<IJSONFluentBuilder>): IJSONFluentBuilder;
    function Arr(const AName: string; ACallback: TProc<IJSONFluentBuilder>): IJSONFluentBuilder;
    function AddToArray(const AValue: Variant): IJSONFluentBuilder; overload;
    function AddToArray(ACallback: TProc<IJSONFluentBuilder>): IJSONFluentBuilder; overload;
    function Build: IJSONElement;
    function ToJSON(const AIndent: Boolean = False): string;
  end;

  // Implementação do builder fluente
  TJSONFluentBuilder = class(TInterfacedObject, IJSONFluentBuilder)
  private
    FComposer: TJSONComposer;
    FIsArrayContext: Boolean;
    function GetCurrentAsObject: IJSONObject;
    function GetCurrentAsArray: IJSONArray;
  public
    constructor Create(AIsArray: Boolean = False);
    destructor Destroy; override;
    function Str(const AName, AValue: string): IJSONFluentBuilder;
    function Num(const AName: string; AValue: Double): IJSONFluentBuilder;
    function Int(const AName: string; AValue: Integer): IJSONFluentBuilder;
    function Bool(const AName: string; AValue: Boolean): IJSONFluentBuilder;
    function Null(const AName: string): IJSONFluentBuilder;
    function DateTime(const AName: string; AValue: TDateTime): IJSONFluentBuilder;
    function Obj(const AName: string; ACallback: TProc<IJSONFluentBuilder>): IJSONFluentBuilder;
    function Arr(const AName: string; ACallback: TProc<IJSONFluentBuilder>): IJSONFluentBuilder;
    function AddToArray(const AValue: Variant): IJSONFluentBuilder; overload;
    function AddToArray(ACallback: TProc<IJSONFluentBuilder>): IJSONFluentBuilder; overload;
    function Build: IJSONElement;
    function ToJSON(const AIndent: Boolean = False): string;
  end;

  // Factory para criação simplificada
  TJSONFluentFactory = class
  public
    class function NewObject: IJSONFluentBuilder;
    class function NewArray: IJSONFluentBuilder;
  end;

  // Classe de demonstração
  TComposerFluentDemo = class
  public
    class procedure RunBasicSyntaxDemo;
    class procedure RunAdvancedSyntaxDemo;
    class procedure RunPerformanceComparison;
    class procedure RunComplexStructureDemo;
  end;

implementation

{ TJSONFluentBuilder }

constructor TJSONFluentBuilder.Create(AIsArray: Boolean);
begin
  inherited Create;
  FComposer := TJSONComposer.Create;
  FIsArrayContext := AIsArray;
  
  if AIsArray then
    FComposer.BeginArray
  else
    FComposer.BeginObject;
end;

destructor TJSONFluentBuilder.Destroy;
begin
  FComposer.Free;
  inherited;
end;

function TJSONFluentBuilder.GetCurrentAsObject: IJSONObject;
begin
  Result := FComposer.ToElement as IJSONObject;
end;

function TJSONFluentBuilder.GetCurrentAsArray: IJSONArray;
begin
  Result := FComposer.ToElement as IJSONArray;
end;

function TJSONFluentBuilder.Str(const AName, AValue: string): IJSONFluentBuilder;
begin
  if FIsArrayContext then
    FComposer.AddToArray('', AValue)
  else
    FComposer.Add(AName, AValue);
  Result := Self;
end;

function TJSONFluentBuilder.Num(const AName: string; AValue: Double): IJSONFluentBuilder;
begin
  if FIsArrayContext then
    FComposer.AddToArray('', AValue)
  else
    FComposer.Add(AName, AValue);
  Result := Self;
end;

function TJSONFluentBuilder.Int(const AName: string; AValue: Integer): IJSONFluentBuilder;
begin
  if FIsArrayContext then
    FComposer.AddToArray('', AValue)
  else
    FComposer.Add(AName, AValue);
  Result := Self;
end;

function TJSONFluentBuilder.Bool(const AName: string; AValue: Boolean): IJSONFluentBuilder;
begin
  if FIsArrayContext then
    FComposer.AddToArray('', AValue)
  else
    FComposer.Add(AName, AValue);
  Result := Self;
end;

function TJSONFluentBuilder.Null(const AName: string): IJSONFluentBuilder;
begin
  if FIsArrayContext then
    FComposer.AddToArray('', System.Variants.Null)
  else
    FComposer.AddNull(AName);
  Result := Self;
end;

function TJSONFluentBuilder.DateTime(const AName: string; AValue: TDateTime): IJSONFluentBuilder;
begin
  if FIsArrayContext then
    FComposer.AddToArray('', AValue)
  else
    FComposer.Add(AName, AValue);
  Result := Self;
end;

function TJSONFluentBuilder.Obj(const AName: string; ACallback: TProc<IJSONFluentBuilder>): IJSONFluentBuilder;
var
  NestedBuilder: IJSONFluentBuilder;
begin
  NestedBuilder := TJSONFluentBuilder.Create(False);
  ACallback(NestedBuilder);
  
  if FIsArrayContext then
    FComposer.AddToArray('', NestedBuilder.Build)
  else
    FComposer.Add(AName, NestedBuilder.Build);
    
  Result := Self;
end;

function TJSONFluentBuilder.Arr(const AName: string; ACallback: TProc<IJSONFluentBuilder>): IJSONFluentBuilder;
var
  NestedBuilder: IJSONFluentBuilder;
begin
  NestedBuilder := TJSONFluentBuilder.Create(True);
  ACallback(NestedBuilder);
  
  if FIsArrayContext then
    FComposer.AddToArray('', NestedBuilder.Build)
  else
    FComposer.Add(AName, NestedBuilder.Build);
    
  Result := Self;
end;

function TJSONFluentBuilder.AddToArray(const AValue: Variant): IJSONFluentBuilder;
begin
  FComposer.AddToArray('', AValue);
  Result := Self;
end;

function TJSONFluentBuilder.AddToArray(ACallback: TProc<IJSONFluentBuilder>): IJSONFluentBuilder;
var
  NestedBuilder: IJSONFluentBuilder;
begin
  NestedBuilder := TJSONFluentBuilder.Create(False);
  ACallback(NestedBuilder);
  FComposer.AddToArray('', NestedBuilder.Build);
  Result := Self;
end;

function TJSONFluentBuilder.Build: IJSONElement;
begin
  Result := FComposer.ToElement;
end;

function TJSONFluentBuilder.ToJSON(const AIndent: Boolean): string;
begin
  Result := FComposer.ToJSON;
end;

{ TJSONFluentFactory }

class function TJSONFluentFactory.NewObject: IJSONFluentBuilder;
begin
  Result := TJSONFluentBuilder.Create(False);
end;

class function TJSONFluentFactory.NewArray: IJSONFluentBuilder;
begin
  Result := TJSONFluentBuilder.Create(True);
end;

{ TComposerFluentDemo }

class procedure TComposerFluentDemo.RunBasicSyntaxDemo;
var
  JSON: string;
begin
  WriteLn('=== DEMONSTRAÇÃO DE SINTAXE BÁSICA ===');
  WriteLn;
  
  // Sintaxe fluente moderna
  JSON := TJSONFluentFactory.NewObject
    .Str('name', 'João Silva')
    .Int('age', 30)
    .Bool('active', True)
    .Str('email', 'joao@email.com')
    .ToJSON;
    
  WriteLn('JSON gerado com sintaxe fluente:');
  WriteLn(JSON);
  WriteLn;
end;

class procedure TComposerFluentDemo.RunAdvancedSyntaxDemo;
var
  JSON: string;
begin
  WriteLn('=== DEMONSTRAÇÃO DE SINTAXE AVANÇADA ===');
  WriteLn;
  
  // Estrutura aninhada com callbacks
  JSON := TJSONFluentFactory.NewObject
    .Str('company', 'TechCorp')
    .Obj('address', procedure(addr: IJSONFluentBuilder)
    begin
      addr.Str('street', 'Rua das Flores, 123')
          .Str('city', 'São Paulo')
          .Str('zipCode', '01234-567');
    end)
    .Arr('employees', procedure(employees: IJSONFluentBuilder)
    begin
      employees.AddToArray(procedure(emp: IJSONFluentBuilder)
      begin
        emp.Str('name', 'Ana')
           .Str('role', 'Developer');
      end)
      .AddToArray(procedure(emp: IJSONFluentBuilder)
      begin
        emp.Str('name', 'Carlos')
           .Str('role', 'Manager');
      end);
    end)
    .ToJSON;
    
  WriteLn('JSON com estruturas aninhadas:');
  WriteLn(JSON);
  WriteLn;
end;

class procedure TComposerFluentDemo.RunPerformanceComparison;
var
  StartTime: TDateTime;
  FluentTime, TraditionalTime: Double;
  JSON: string;
  Composer: TJSONComposer;
  i: Integer;
begin
  WriteLn('=== COMPARAÇÃO DE PERFORMANCE ===');
  WriteLn;
  
  // Teste com sintaxe fluente
  StartTime := Now;
  for i := 1 to 1000 do
  begin
    JSON := TJSONFluentFactory.NewObject
      .Str('id', IntToStr(i))
      .Str('name', 'User ' + IntToStr(i))
      .Int('value', i * 10)
      .Bool('active', i mod 2 = 0)
      .ToJSON;
  end;
  FluentTime := (Now - StartTime) * 24 * 60 * 60 * 1000; // em ms
  
  // Teste com sintaxe tradicional
  StartTime := Now;
  for i := 1 to 1000 do
  begin
    Composer := TJSONComposer.Create;
    try
      Composer.BeginObject;
      Composer.Add('id', IntToStr(i));
      Composer.Add('name', 'User ' + IntToStr(i));
      Composer.Add('value', i * 10);
      Composer.Add('active', i mod 2 = 0);
      Composer.EndObject;
      JSON := Composer.ToJSON;
    finally
      Composer.Free;
    end;
  end;
  TraditionalTime := (Now - StartTime) * 24 * 60 * 60 * 1000; // em ms
  
  WriteLn(Format('Sintaxe Fluente: %.2f ms', [FluentTime]));
  WriteLn(Format('Sintaxe Tradicional: %.2f ms', [TraditionalTime]));
  WriteLn(Format('Diferença: %.2f%%', [(FluentTime - TraditionalTime) / TraditionalTime * 100]));
  WriteLn;
end;

class procedure TComposerFluentDemo.RunComplexStructureDemo;
var
  JSON: string;
begin
  WriteLn('=== DEMONSTRAÇÃO DE ESTRUTURA COMPLEXA ===');
  WriteLn;
  
  // API Response complexa
  JSON := TJSONFluentFactory.NewObject
    .Int('statusCode', 200)
    .Str('message', 'Data retrieved successfully')
    .DateTime('timestamp', Now)
    .Obj('data', procedure(data: IJSONFluentBuilder)
    begin
      data.Int('totalRecords', 150)
          .Int('currentPage', 1)
          .Int('pageSize', 10)
          .Arr('users', procedure(users: IJSONFluentBuilder)
          begin
            // Usuário 1
            users.AddToArray(procedure(user: IJSONFluentBuilder)
            begin
              user.Str('name', 'Ana Silva')
                  .Str('email', 'ana@email.com')
                  .Bool('active', True);
            end)
            // Usuário 2
            .AddToArray(procedure(user: IJSONFluentBuilder)
            begin
              user.Str('name', 'Bruno Costa')
                  .Str('email', 'bruno@email.com')
                  .Bool('active', False);
            end);
          end);
    end)
    .ToJSON;
    
  WriteLn('API Response complexa:');
  WriteLn(JSON);
  WriteLn;
end;

end.