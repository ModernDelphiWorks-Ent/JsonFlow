unit FluentSyntaxDemo;

{
  Demonstração de Sintaxe Fluente para JsonFlow4D Smart Mode
  
  Este exemplo mostra como implementar uma interface fluente mais limpa
  e produtiva para o sistema de sugestões do JsonFlow4D.
  
  Autor: JsonFlow4D Team
  Data: 2024
}

interface

uses
  System.SysUtils,
  System.Generics.Collections;

type
  // Interface fluente para construção de sugestões
  ISmartSuggestionBuilder = interface
    ['{B8E5F2A1-9C3D-4E6F-8A7B-1234567890AB}']
    
    // Métodos fluentes para diferentes categorias
    function AddValidation(const AKeyword: string; APriority: Integer = 5; const ADefaultValue: string = ''): ISmartSuggestionBuilder;
    function AddStructure(const AKeyword: string; APriority: Integer = 5; const ADefaultValue: string = ''): ISmartSuggestionBuilder;
    function AddDocumentation(const AKeyword: string; APriority: Integer = 5; const ADefaultValue: string = ''): ISmartSuggestionBuilder;
    function AddMeta(const AKeyword: string; APriority: Integer = 5; const ADefaultValue: string = ''): ISmartSuggestionBuilder;
    function AddFormat(const AFormat: string; APriority: Integer = 7): ISmartSuggestionBuilder;
    
    // Métodos específicos para tipos comuns
    function ForString: ISmartSuggestionBuilder;
    function ForNumber: ISmartSuggestionBuilder;
    function ForArray: ISmartSuggestionBuilder;
    function ForObject: ISmartSuggestionBuilder;
    function ForRoot: ISmartSuggestionBuilder;
    
    // Métodos de configuração
    function WithPriority(APriority: Integer): ISmartSuggestionBuilder;
    function WithDefault(const AValue: string): ISmartSuggestionBuilder;
    function WithOptions(const AOptions: array of string): ISmartSuggestionBuilder;
    
    // Finalização
    function Build: TArray<string>; // Retorna as sugestões construídas
    function Count: Integer;
  end;

  // Implementação da interface fluente
  TSmartSuggestionBuilder = class(TInterfacedObject, ISmartSuggestionBuilder)
  private
    FSuggestions: TList<string>;
    FCurrentPriority: Integer;
    FCurrentDefault: string;
    FCurrentOptions: TArray<string>;
    
    procedure AddSuggestion(const AKeyword, ACategory: string; APriority: Integer; const ADefaultValue: string = '');
    procedure ResetCurrent;
  public
    constructor Create;
    destructor Destroy; override;
    
    // ISmartSuggestionBuilder
    function AddValidation(const AKeyword: string; APriority: Integer = 5; const ADefaultValue: string = ''): ISmartSuggestionBuilder;
    function AddStructure(const AKeyword: string; APriority: Integer = 5; const ADefaultValue: string = ''): ISmartSuggestionBuilder;
    function AddDocumentation(const AKeyword: string; APriority: Integer = 5; const ADefaultValue: string = ''): ISmartSuggestionBuilder;
    function AddMeta(const AKeyword: string; APriority: Integer = 5; const ADefaultValue: string = ''): ISmartSuggestionBuilder;
    function AddFormat(const AFormat: string; APriority: Integer = 7): ISmartSuggestionBuilder;
    
    function ForString: ISmartSuggestionBuilder;
    function ForNumber: ISmartSuggestionBuilder;
    function ForArray: ISmartSuggestionBuilder;
    function ForObject: ISmartSuggestionBuilder;
    function ForRoot: ISmartSuggestionBuilder;
    
    function WithPriority(APriority: Integer): ISmartSuggestionBuilder;
    function WithDefault(const AValue: string): ISmartSuggestionBuilder;
    function WithOptions(const AOptions: array of string): ISmartSuggestionBuilder;
    
    function Build: TArray<string>;
    function Count: Integer;
  end;

  // Factory para criar builders
  TSuggestionFactory = class
  public
    class function NewBuilder: ISmartSuggestionBuilder;
    class function ForContext(const AContextType: string): ISmartSuggestionBuilder;
  end;

implementation

{ TSmartSuggestionBuilder }

constructor TSmartSuggestionBuilder.Create;
begin
  inherited;
  FSuggestions := TList<string>.Create;
  ResetCurrent;
end;

destructor TSmartSuggestionBuilder.Destroy;
begin
  FSuggestions.Free;
  inherited;
end;

procedure TSmartSuggestionBuilder.ResetCurrent;
begin
  FCurrentPriority := 5;
  FCurrentDefault := '';
  SetLength(FCurrentOptions, 0);
end;

procedure TSmartSuggestionBuilder.AddSuggestion(const AKeyword, ACategory: string; APriority: Integer; const ADefaultValue: string);
var
  Suggestion: string;
begin
  Suggestion := Format('%s [%s] (prioridade: %d)', [AKeyword, ACategory, APriority]);
  if ADefaultValue <> '' then
    Suggestion := Suggestion + Format(' = "%s"', [ADefaultValue]);
  
  FSuggestions.Add(Suggestion);
  ResetCurrent;
end;

function TSmartSuggestionBuilder.AddValidation(const AKeyword: string; APriority: Integer; const ADefaultValue: string): ISmartSuggestionBuilder;
begin
  AddSuggestion(AKeyword, 'validation', APriority, ADefaultValue);
  Result := Self;
end;

function TSmartSuggestionBuilder.AddStructure(const AKeyword: string; APriority: Integer; const ADefaultValue: string): ISmartSuggestionBuilder;
begin
  AddSuggestion(AKeyword, 'structure', APriority, ADefaultValue);
  Result := Self;
end;

function TSmartSuggestionBuilder.AddDocumentation(const AKeyword: string; APriority: Integer; const ADefaultValue: string): ISmartSuggestionBuilder;
begin
  AddSuggestion(AKeyword, 'documentation', APriority, ADefaultValue);
  Result := Self;
end;

function TSmartSuggestionBuilder.AddMeta(const AKeyword: string; APriority: Integer; const ADefaultValue: string): ISmartSuggestionBuilder;
begin
  AddSuggestion(AKeyword, 'meta', APriority, ADefaultValue);
  Result := Self;
end;

function TSmartSuggestionBuilder.AddFormat(const AFormat: string; APriority: Integer): ISmartSuggestionBuilder;
begin
  AddSuggestion('format', 'validation', APriority, AFormat);
  Result := Self;
end;

function TSmartSuggestionBuilder.ForString: ISmartSuggestionBuilder;
begin
  AddValidation('minLength', 6)
    .AddValidation('maxLength', 7)
    .AddValidation('pattern', 5)
    .AddFormat('email', 8)
    .AddFormat('date', 7)
    .AddFormat('uri', 6);
  Result := Self;
end;

function TSmartSuggestionBuilder.ForNumber: ISmartSuggestionBuilder;
begin
  AddValidation('minimum', 7)
    .AddValidation('maximum', 8)
    .AddValidation('multipleOf', 5)
    .AddValidation('exclusiveMinimum', 4)
    .AddValidation('exclusiveMaximum', 4);
  Result := Self;
end;

function TSmartSuggestionBuilder.ForArray: ISmartSuggestionBuilder;
begin
  AddStructure('items', 9)
    .AddValidation('minItems', 6)
    .AddValidation('maxItems', 7)
    .AddValidation('uniqueItems', 5, 'true');
  Result := Self;
end;

function TSmartSuggestionBuilder.ForObject: ISmartSuggestionBuilder;
begin
  AddStructure('properties', 10)
    .AddValidation('required', 8)
    .AddValidation('additionalProperties', 6, 'false')
    .AddValidation('minProperties', 4)
    .AddValidation('maxProperties', 5);
  Result := Self;
end;

function TSmartSuggestionBuilder.ForRoot: ISmartSuggestionBuilder;
begin
  AddMeta('$schema', 10, 'http://json-schema.org/draft-07/schema#')
    .AddDocumentation('title', 8)
    .AddDocumentation('description', 7)
    .AddStructure('type', 9, 'object');
  Result := Self;
end;

function TSmartSuggestionBuilder.WithPriority(APriority: Integer): ISmartSuggestionBuilder;
begin
  FCurrentPriority := APriority;
  Result := Self;
end;

function TSmartSuggestionBuilder.WithDefault(const AValue: string): ISmartSuggestionBuilder;
begin
  FCurrentDefault := AValue;
  Result := Self;
end;

function TSmartSuggestionBuilder.WithOptions(const AOptions: array of string): ISmartSuggestionBuilder;
var
  I: Integer;
begin
  SetLength(FCurrentOptions, Length(AOptions));
  for I := 0 to High(AOptions) do
    FCurrentOptions[I] := AOptions[I];
  Result := Self;
end;

function TSmartSuggestionBuilder.Build: TArray<string>;
begin
  Result := FSuggestions.ToArray;
end;

function TSmartSuggestionBuilder.Count: Integer;
begin
  Result := FSuggestions.Count;
end;

{ TSuggestionFactory }

class function TSuggestionFactory.NewBuilder: ISmartSuggestionBuilder;
begin
  Result := TSmartSuggestionBuilder.Create;
end;

class function TSuggestionFactory.ForContext(const AContextType: string): ISmartSuggestionBuilder;
begin
  Result := NewBuilder;
  
  if AContextType = 'string' then
    Result.ForString
  else if AContextType = 'number' then
    Result.ForNumber
  else if AContextType = 'array' then
    Result.ForArray
  else if AContextType = 'object' then
    Result.ForObject
  else if AContextType = 'root' then
    Result.ForRoot;
end;

end.