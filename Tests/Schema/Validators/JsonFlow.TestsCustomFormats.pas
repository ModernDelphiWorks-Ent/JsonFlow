unit JsonFlow.TestsCustomFormats;

{
  JsonFlow4D - Testes para Validadores de Formato Customizados
  
  Este arquivo testa o sistema de formatos plugáveis do JsonFlow4D,
  incluindo validadores built-in e customizados.
  
  Autor: JsonFlow4D Framework
  Data: 2024
}

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  JsonFlow.Interfaces,
  JsonFlow.Reader,
  JsonFlow.SchemaValidator,
  JsonFlow.FormatRegistry,
  JsonFlow.FormatValidators;

type
  [TestFixture]
  TCustomFormatsTests = class
  private
    FValidator: TJSONSchemaValidator;
    FReader: TJSONReader;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    
    // Testes dos validadores built-in via registry
    [Test]
    procedure TestBuiltInFormats_Email;
    [Test]
    procedure TestBuiltInFormats_Uri;
    [Test]
    procedure TestBuiltInFormats_DateTime;
    [Test]
    procedure TestBuiltInFormats_Uuid;

    // Testes de registro de validadores customizados
    [Test]
    procedure TestCustomValidator_Registration;
    [Test]
    procedure TestCustomValidator_CPF_Valid;
    [Test]
    procedure TestCustomValidator_CPF_Invalid;
    [Test]
    procedure TestCustomValidator_CEP_Valid;
    [Test]
    procedure TestCustomValidator_CEP_Invalid;

    // Testes de funcionalidades do registry
    [Test]
    procedure TestFormatRegistry_IsRegistered;
    [Test]
    procedure TestFormatRegistry_GetRegisteredFormats;
    [Test]
    procedure TestFormatRegistry_UnregisterValidator;

    // Teste de fallback para formatos não registrados
    [Test]
    procedure TestUnknownFormat_Fallback;
  end;

  // Validador customizado simples para testes
  TTestCustomValidator = class(TBaseFormatValidator)
  protected
    function DoValidate(const AValue: string): Boolean; override;
  public
    constructor Create;
  end;

implementation

uses
  CustomFormatValidators;

{ TTestCustomValidator }

constructor TTestCustomValidator.Create;
begin
  inherited Create('test-format');
end;

function TTestCustomValidator.DoValidate(const AValue: string): Boolean;
begin
  // Validador simples: aceita apenas "valid"
  Result := AValue = 'valid';
end;

{ TCustomFormatsTests }

procedure TCustomFormatsTests.Setup;
begin
  FValidator := TJSONSchemaValidator.Create;
  FReader := TJSONReader.Create;
  
  // Limpa o registry para testes isolados
  TFormatRegistry.ClearRegistry;
  
  // Registra validadores built-in usando o novo sistema
  RegisterAllFormatValidators;
end;

procedure TCustomFormatsTests.TearDown;
begin
  FValidator.Free;
  FReader.Free;
end;

procedure TCustomFormatsTests.TestBuiltInFormats_Email;
var
  LSchema, LValidData, LInvalidData: IJSONElement;
begin
  // Schema
  LSchema := FReader.Read('{' +
    '  "type": "string",' +
    '  "format": "email"' +
    '}');
  
  // Teste com email válido
  // Configura o schema no validador
  FValidator.ParseSchema(LSchema);
  
  LValidData := FReader.Read('"test@example.com"');
  Assert.IsTrue(FValidator.Validate(LValidData), 'Email válido deveria passar na validação');
  
  // Teste com email inválido
  LInvalidData := FReader.Read('"invalid-email"');
  Assert.IsFalse(FValidator.Validate(LInvalidData), 'Email inválido deveria falhar na validação');
end;

procedure TCustomFormatsTests.TestBuiltInFormats_Uri;
var
  LSchema, LValidData, LInvalidData: IJSONElement;
begin
  LSchema := FReader.Read('{' +
    '  "type": "string",' +
    '  "format": "uri"' +
    '}');
  
  // Configura o schema no validador
  FValidator.ParseSchema(LSchema);
  
  LValidData := FReader.Read('"https://example.com"');
  Assert.IsTrue(FValidator.Validate(LValidData), 'URI válida deveria passar na validação');
  
  LInvalidData := FReader.Read('"not-a-uri"');
  Assert.IsFalse(FValidator.Validate(LInvalidData), 'URI inválida deveria falhar na validação');
end;

procedure TCustomFormatsTests.TestBuiltInFormats_DateTime;
var
  LSchema, LValidData, LInvalidData: IJSONElement;
begin
  LSchema := FReader.Read('{' +
    '  "type": "string",' +
    '  "format": "date-time"' +
    '}');
  
  // Configura o schema no validador
  FValidator.ParseSchema(LSchema);
  
  LValidData := FReader.Read('"2023-12-25T10:30:00Z"');
  Assert.IsTrue(FValidator.Validate(LValidData), 'DateTime válido deveria passar na validação');
  
  LInvalidData := FReader.Read('"not-a-datetime"');
  Assert.IsFalse(FValidator.Validate(LInvalidData), 'DateTime inválido deveria falhar na validação');
end;

procedure TCustomFormatsTests.TestBuiltInFormats_UUID;
var
  LSchema, LValidData, LInvalidData: IJSONElement;
begin
  LSchema := FReader.Read('{' +
    '  "type": "string",' +
    '  "format": "uuid"' +
    '}');
  
  // Configura o schema no validador
  FValidator.ParseSchema(LSchema);
  
  LValidData := FReader.Read('"550e8400-e29b-41d4-a716-446655440000"');
  Assert.IsTrue(FValidator.Validate(LValidData), 'UUID válido deveria passar na validação');
  
  LInvalidData := FReader.Read('"not-a-uuid"');
  Assert.IsFalse(FValidator.Validate(LInvalidData), 'UUID inválido deveria falhar na validação');
end;

procedure TCustomFormatsTests.TestCustomValidator_Registration;
var
  LValidator: IFormatValidator;
begin
  // Registra validador customizado
  TFormatRegistry.RegisterValidator('test-format', TTestCustomValidator.Create);
  
  // Verifica se foi registrado
  Assert.IsTrue(TFormatRegistry.IsFormatRegistered('test-format'), 'Validador customizado deveria estar registrado');
  
  // Obtém o validador
  LValidator := TFormatRegistry.GetValidator('test-format');
  Assert.IsNotNull(LValidator, 'Deveria retornar o validador registrado');
  Assert.AreEqual('test-format', LValidator.GetFormatName, 'Nome do formato deveria ser correto');
end;

procedure TCustomFormatsTests.TestCustomValidator_CPF_Valid;
var
  LSchema, LValidData: IJSONElement;
begin
  // Registra validadores brasileiros
  RegisterBrazilianFormatValidators;

  LSchema := FReader.Read('{' +
    '  "type": "string",' +
    '  "format": "cpf"' +
    '}');

  // Configura o schema no validador
  FValidator.ParseSchema(LSchema);

  // Teste com CPF válido (formato com pontuação)
  LValidData := FReader.Read('"123.456.789-09"');
  Assert.IsTrue(FValidator.Validate(LValidData), 'CPF válido com pontuação deveria passar na validação');
  
  // Teste com CPF válido (formato sem pontuação)
  LValidData := FReader.Read('"12345678909"');
  Assert.IsTrue(FValidator.Validate(LValidData), 'CPF válido sem pontuação deveria passar na validação');
end;

procedure TCustomFormatsTests.TestCustomValidator_CPF_Invalid;
var
  LSchema, LInvalidData: IJSONElement;
begin
  RegisterBrazilianFormatValidators;

  LSchema := FReader.Read('{' +
    '  "type": "string",' +
    '  "format": "cpf"' +
    '}');

  // Configura o schema no validador
  FValidator.ParseSchema(LSchema);

  // Teste com CPF inválido
  LInvalidData := FReader.Read('"123.456.789-00"');
  Assert.IsFalse(FValidator.Validate(LInvalidData), 'CPF inválido deveria falhar na validação');

  // Teste com formato inválido
  LInvalidData := FReader.Read('"123.456"');
  Assert.IsFalse(FValidator.Validate(LInvalidData), 'CPF com formato inválido deveria falhar na validação');
end;

procedure TCustomFormatsTests.TestCustomValidator_CEP_Valid;
var
  LSchema, LValidData: IJSONElement;
begin
  RegisterBrazilianFormatValidators;

  LSchema := FReader.Read('{' +
    '  "type": "string",' +
    '  "format": "cep"' +
    '}');

  // Configura o schema no validador
  FValidator.ParseSchema(LSchema);
  
  // Teste com CEP válido (com hífen)
  LValidData := FReader.Read('"01234-567"');
  Assert.IsTrue(FValidator.Validate(LValidData), 'CEP válido com hífen deveria passar na validação');
  
  // Teste com CEP válido (sem hífen)
  LValidData := FReader.Read('"01234567"');
  Assert.IsTrue(FValidator.Validate(LValidData), 'CEP válido sem hífen deveria passar na validação');
end;

procedure TCustomFormatsTests.TestCustomValidator_CEP_Invalid;
var
  LSchema, LInvalidData: IJSONElement;
begin
  RegisterBrazilianFormatValidators;

  LSchema := FReader.Read('{' +
    '  "type": "string",' +
    '  "format": "cep"' +
    '}');
  
  // Configura o schema no validador
  FValidator.ParseSchema(LSchema);
  
  // Teste com CEP inválido (muito curto)
  LInvalidData := FReader.Read('"123"');
  Assert.IsFalse(FValidator.Validate(LInvalidData), 'CEP muito curto deveria falhar na validação');
  
  // Teste com CEP inválido (letras)
  LInvalidData := FReader.Read('"ABCDE-FGH"');
  Assert.IsFalse(FValidator.Validate(LInvalidData), 'CEP com letras deveria falhar na validação');
end;

procedure TCustomFormatsTests.TestFormatRegistry_IsRegistered;
begin
  // Testa formato built-in
  Assert.IsTrue(TFormatRegistry.IsFormatRegistered('email'), 'Email deveria estar registrado');
  
  // Testa formato não registrado
  Assert.IsFalse(TFormatRegistry.IsFormatRegistered('non-existent'), 'Formato inexistente não deveria estar registrado');
  
  // Registra e testa formato customizado
  TFormatRegistry.RegisterValidator('custom', TTestCustomValidator.Create);
  Assert.IsTrue(TFormatRegistry.IsFormatRegistered('custom'), 'Formato customizado deveria estar registrado');
end;

procedure TCustomFormatsTests.TestFormatRegistry_GetRegisteredFormats;
var
  LFormats: TArray<string>;
begin
  LFormats := TFormatRegistry.GetRegisteredFormats;
  
  // Verifica se contém formatos built-in
  Assert.Contains(LFormats, 'email', 'Lista deveria conter email');
  Assert.Contains(LFormats, 'uri', 'Lista deveria conter uri');
  Assert.Contains(LFormats, 'date-time', 'Lista deveria conter date-time');
  
  // Registra formato customizado e verifica
  TFormatRegistry.RegisterValidator('test-custom', TTestCustomValidator.Create);
  LFormats := TFormatRegistry.GetRegisteredFormats;
  Assert.Contains(LFormats, 'test-custom', 'Lista deveria conter formato customizado');
end;

procedure TCustomFormatsTests.TestFormatRegistry_UnregisterValidator;
begin
  // Registra validador
  TFormatRegistry.RegisterValidator('temp-format', TTestCustomValidator.Create);
  Assert.IsTrue(TFormatRegistry.IsFormatRegistered('temp-format'), 'Formato deveria estar registrado');
  
  // Remove validador
  TFormatRegistry.UnregisterValidator('temp-format');
  Assert.IsFalse(TFormatRegistry.IsFormatRegistered('temp-format'), 'Formato não deveria mais estar registrado');
end;

procedure TCustomFormatsTests.TestUnknownFormat_Fallback;
var
  LSchema, LData: IJSONElement;
begin
  // Schema com formato não registrado
  LSchema := FReader.Read('{' +
    '  "type": "string",' +
    '  "format": "unknown-format"' +
    '}');
  
  // Configura o schema no validador
  FValidator.ParseSchema(LSchema);
  
  // Qualquer string deveria ser válida para formato desconhecido
  LData := FReader.Read('"any-value"');
  Assert.IsTrue(FValidator.Validate(LData), 'Formato desconhecido deveria ser considerado válido (fallback)');
end;

end.
