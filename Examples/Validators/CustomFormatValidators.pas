unit CustomFormatValidators;

{
  JsonFlow4D - Exemplos de Validadores de Formato Customizados
  
  Este arquivo demonstra como criar e registrar validadores de formato
  customizados usando o sistema plugável do JsonFlow4D.
  
  Exemplos incluídos:
  - Validador de CPF brasileiro
  - Validador de CNPJ brasileiro
  - Validador de CEP brasileiro
  - Validador de telefone brasileiro
  
  Autor: JsonFlow4D Framework
  Data: 2024
}

interface

uses
  System.SysUtils,
  System.Classes,
  System.RegularExpressions,
  JsonFlow.FormatRegistry;

type
  // Validador de CPF brasileiro
  TCPFFormatValidator = class(TBaseFormatValidator)
  private
    function IsValidCPF(const ACPF: string): Boolean;
    function CalculateDigit(const ANumbers: string; AWeight: Integer): Integer;
  protected
    function DoValidate(const AValue: string): Boolean; override;
    function GetDefaultErrorMessage(const AValue: string): string; override;
  public
    constructor Create;
  end;

  // Validador de CNPJ brasileiro
  TCNPJFormatValidator = class(TBaseFormatValidator)
  private
    function IsValidCNPJ(const ACNPJ: string): Boolean;
    function CalculateDigit(const ANumbers: string; const AWeights: array of Integer): Integer;
  protected
    function DoValidate(const AValue: string): Boolean; override;
    function GetDefaultErrorMessage(const AValue: string): string; override;
  public
    constructor Create;
  end;

  // Validador de CEP brasileiro
  TCEPFormatValidator = class(TBaseFormatValidator)
  protected
    function DoValidate(const AValue: string): Boolean; override;
    function GetDefaultErrorMessage(const AValue: string): string; override;
  public
    constructor Create;
  end;

  // Validador de telefone brasileiro
  TBrazilianPhoneFormatValidator = class(TBaseFormatValidator)
  protected
    function DoValidate(const AValue: string): Boolean; override;
    function GetDefaultErrorMessage(const AValue: string): string; override;
  public
    constructor Create;
  end;

  // Validador de placa de carro brasileira (formato antigo e Mercosul)
  TBrazilianLicensePlateValidator = class(TBaseFormatValidator)
  protected
    function DoValidate(const AValue: string): Boolean; override;
    function GetDefaultErrorMessage(const AValue: string): string; override;
  public
    constructor Create;
  end;

// Procedimento para registrar todos os validadores customizados brasileiros
procedure RegisterBrazilianFormatValidators;

// Procedimento para demonstrar o uso dos validadores
procedure DemonstrateCustomValidators;

implementation

uses
  JsonFlow.Interfaces,
  JsonFlow.Reader;

{ TCPFFormatValidator }

constructor TCPFFormatValidator.Create;
begin
  inherited Create('cpf');
end;

function TCPFFormatValidator.CalculateDigit(const ANumbers: string; AWeight: Integer): Integer;
var
  I, Sum: Integer;
begin
  Sum := 0;
  for I := 1 to Length(ANumbers) do
  begin
    Sum := Sum + (StrToInt(ANumbers[I]) * AWeight);
    Dec(AWeight);
  end;
  
  Result := 11 - (Sum mod 11);
  if Result >= 10 then
    Result := 0;
end;

function TCPFFormatValidator.IsValidCPF(const ACPF: string): Boolean;
var
  LNumbers: string;
  LDigit1, LDigit2: Integer;
begin
  // Remove formatação
  LNumbers := ACPF.Replace('.', '').Replace('-', '');
  
  // Verifica se tem 11 dígitos
  if Length(LNumbers) <> 11 then
    Exit(False);
  
  // Verifica se não são todos iguais
  if LNumbers = StringOfChar(LNumbers[1], 11) then
    Exit(False);
  
  // Calcula primeiro dígito verificador
  LDigit1 := CalculateDigit(Copy(LNumbers, 1, 9), 10);
  if LDigit1 <> StrToInt(LNumbers[10]) then
    Exit(False);
  
  // Calcula segundo dígito verificador
  LDigit2 := CalculateDigit(Copy(LNumbers, 1, 10), 11);
  Result := LDigit2 = StrToInt(LNumbers[11]);
end;

function TCPFFormatValidator.DoValidate(const AValue: string): Boolean;
begin
  Result := IsValidCPF(AValue);
end;

function TCPFFormatValidator.GetDefaultErrorMessage(const AValue: string): string;
begin
  Result := Format('O valor "%s" não é um CPF válido', [AValue]);
end;

{ TCNPJFormatValidator }

constructor TCNPJFormatValidator.Create;
begin
  inherited Create('cnpj');
end;

function TCNPJFormatValidator.CalculateDigit(const ANumbers: string; const AWeights: array of Integer): Integer;
var
  I, Sum: Integer;
begin
  Sum := 0;
  for I := 1 to Length(ANumbers) do
    Sum := Sum + (StrToInt(ANumbers[I]) * AWeights[I - 1]);
  
  Result := Sum mod 11;
  if Result < 2 then
    Result := 0
  else
    Result := 11 - Result;
end;

function TCNPJFormatValidator.IsValidCNPJ(const ACNPJ: string): Boolean;
var
  LNumbers: string;
  LDigit1, LDigit2: Integer;
  LWeights1: array[0..11] of Integer;
  LWeights2: array[0..12] of Integer;
  I: Integer;
begin
  // Initialize weight arrays
  LWeights1[0] := 5; LWeights1[1] := 4; LWeights1[2] := 3; LWeights1[3] := 2;
  LWeights1[4] := 9; LWeights1[5] := 8; LWeights1[6] := 7; LWeights1[7] := 6;
  LWeights1[8] := 5; LWeights1[9] := 4; LWeights1[10] := 3; LWeights1[11] := 2;
  
  LWeights2[0] := 6; LWeights2[1] := 5; LWeights2[2] := 4; LWeights2[3] := 3;
  LWeights2[4] := 2; LWeights2[5] := 9; LWeights2[6] := 8; LWeights2[7] := 7;
  LWeights2[8] := 6; LWeights2[9] := 5; LWeights2[10] := 4; LWeights2[11] := 3;
  LWeights2[12] := 2;
  
  // Remove formatação
  LNumbers := ACNPJ.Replace('.', '').Replace('/', '').Replace('-', '');
  
  // Verifica se tem 14 dígitos
  if Length(LNumbers) <> 14 then
    Exit(False);
  
  // Verifica se não são todos iguais
  if LNumbers = StringOfChar(LNumbers[1], 14) then
    Exit(False);
  
  // Calcula primeiro dígito verificador
  LDigit1 := CalculateDigit(Copy(LNumbers, 1, 12), LWeights1);
  if LDigit1 <> StrToInt(LNumbers[13]) then
    Exit(False);
  
  // Calcula segundo dígito verificador
  LDigit2 := CalculateDigit(Copy(LNumbers, 1, 13), LWeights2);
  Result := LDigit2 = StrToInt(LNumbers[14]);
end;

function TCNPJFormatValidator.DoValidate(const AValue: string): Boolean;
begin
  Result := IsValidCNPJ(AValue);
end;

function TCNPJFormatValidator.GetDefaultErrorMessage(const AValue: string): string;
begin
  Result := Format('O valor "%s" não é um CNPJ válido', [AValue]);
end;

{ TCEPFormatValidator }

constructor TCEPFormatValidator.Create;
begin
  inherited Create('cep');
end;

function TCEPFormatValidator.DoValidate(const AValue: string): Boolean;
var
  LRegex: TRegEx;
begin
  // Aceita formatos: 12345-678 ou 12345678
  LRegex := TRegEx.Create('^\d{5}-?\d{3}$');
  Result := LRegex.IsMatch(AValue);
end;

function TCEPFormatValidator.GetDefaultErrorMessage(const AValue: string): string;
begin
  Result := Format('O valor "%s" não é um CEP válido (formato esperado: 12345-678)', [AValue]);
end;

{ TBrazilianPhoneFormatValidator }

constructor TBrazilianPhoneFormatValidator.Create;
begin
  inherited Create('brazilian-phone');
end;

function TBrazilianPhoneFormatValidator.DoValidate(const AValue: string): Boolean;
var
  LRegex: TRegEx;
begin
  // Aceita formatos: (11) 99999-9999, (11) 9999-9999, 11999999999, 1199999999
  LRegex := TRegEx.Create('^(\(?\d{2}\)?\s?)?(9?\d{4}-?\d{4})$');
  Result := LRegex.IsMatch(AValue);
end;

function TBrazilianPhoneFormatValidator.GetDefaultErrorMessage(const AValue: string): string;
begin
  Result := Format('O valor "%s" não é um telefone brasileiro válido', [AValue]);
end;

{ TBrazilianLicensePlateValidator }

constructor TBrazilianLicensePlateValidator.Create;
begin
  inherited Create('brazilian-license-plate');
end;

function TBrazilianLicensePlateValidator.DoValidate(const AValue: string): Boolean;
var
  LRegexOld, LRegexMercosul: TRegEx;
begin
  // Formato antigo: ABC-1234
  LRegexOld := TRegEx.Create('^[A-Z]{3}-?\d{4}$');
  
  // Formato Mercosul: ABC1D23
  LRegexMercosul := TRegEx.Create('^[A-Z]{3}\d[A-Z]\d{2}$');
  
  Result := LRegexOld.IsMatch(AValue.ToUpper) or LRegexMercosul.IsMatch(AValue.ToUpper);
end;

function TBrazilianLicensePlateValidator.GetDefaultErrorMessage(const AValue: string): string;
begin
  Result := Format('O valor "%s" não é uma placa brasileira válida (formatos: ABC-1234 ou ABC1D23)', [AValue]);
end;

{ Procedimentos auxiliares }

procedure RegisterBrazilianFormatValidators;
begin
  TFormatRegistry.RegisterValidator('cpf', TCPFFormatValidator.Create);
  TFormatRegistry.RegisterValidator('cnpj', TCNPJFormatValidator.Create);
  TFormatRegistry.RegisterValidator('cep', TCEPFormatValidator.Create);
  TFormatRegistry.RegisterValidator('brazilian-phone', TBrazilianPhoneFormatValidator.Create);
  TFormatRegistry.RegisterValidator('brazilian-license-plate', TBrazilianLicensePlateValidator.Create);
end;

procedure DemonstrateCustomValidators;
var
  LSchema, LData: IJSONElement;
  LReader: TJSONReader;
  LSchemaStr, LDataStr: string;
begin
  // Registra os validadores customizados
  RegisterBrazilianFormatValidators;
  
  WriteLn('=== Demonstração de Validadores de Formato Customizados ===');
  WriteLn;
  
  // Exemplo de schema usando os novos formatos
  LSchemaStr := '{' +
    '  "type": "object",' +
    '  "properties": {' +
    '    "cpf": { "type": "string", "format": "cpf" },' +
    '    "cnpj": { "type": "string", "format": "cnpj" },' +
    '    "cep": { "type": "string", "format": "cep" },' +
    '    "telefone": { "type": "string", "format": "brazilian-phone" },' +
    '    "placa": { "type": "string", "format": "brazilian-license-plate" }' +
    '  }' +
    '}';
  
  // Dados de teste válidos
  LDataStr := '{' +
    '  "cpf": "123.456.789-09",' +
    '  "cnpj": "11.222.333/0001-81",' +
    '  "cep": "01234-567",' +
    '  "telefone": "(11) 99999-9999",' +
    '  "placa": "ABC-1234"' +
    '}';
  
  LReader := TJSONReader.Create;
  try
    LSchema := LReader.Read(LSchemaStr);
    LData := LReader.Read(LDataStr);
    
    WriteLn('Schema com formatos customizados:');
    WriteLn(LSchemaStr);
    WriteLn;
    WriteLn('Dados de teste:');
    WriteLn(LDataStr);
    WriteLn;
    
    // Aqui você usaria o JsonFlow4D para validar os dados contra o schema
    WriteLn('Os validadores customizados foram registrados com sucesso!');
    WriteLn('Formatos disponíveis: '); // Note: GetRegisteredFormats method would need to be implemented
    
  finally
    LReader.Free;
  end;
end;

end.