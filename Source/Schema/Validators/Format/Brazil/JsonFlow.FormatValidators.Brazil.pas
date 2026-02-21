unit JsonFlow.FormatValidators.Brazil;

{
  JsonFlow4D - Validadores de Formato Brasileiros
  
  Arquivo centralizador para registro de todos os validadores de formato
  específicos do Brasil.
  
  Validadores incluídos:
  - CPF (Cadastro de Pessoas Físicas)
  - CNPJ (Cadastro Nacional da Pessoa Jurídica)
  - CEP (Código de Endereçamento Postal)
  - Telefone brasileiro
  - Placa de carro brasileira (antigo e Mercosul)
  
  Autor: JsonFlow4D Framework
  Data: 2024
}

interface

uses
  JsonFlow4D.FormatValidators.CPF,
  JsonFlow4D.FormatValidators.CNPJ,
  JsonFlow4D.FormatValidators.CEP,
  JsonFlow4D.FormatValidators.BrazilianPhone,
  JsonFlow4D.FormatValidators.BrazilianLicensePlate;

// Registra todos os validadores brasileiros
procedure RegisterAllBrazilianFormatValidators;

// Registra validadores individuais
procedure RegisterBuiltInCPFValidator;
procedure RegisterBuiltInCNPJValidator;
procedure RegisterBuiltInCEPValidator;
procedure RegisterBuiltInBrazilianPhoneValidator;
procedure RegisterBuiltInBrazilianLicensePlateValidator;

implementation

procedure RegisterBuiltInCPFValidator;
begin
  RegisterCPFValidator;
end;

procedure RegisterBuiltInCNPJValidator;
begin
  RegisterCNPJValidator;
end;

procedure RegisterBuiltInCEPValidator;
begin
  RegisterCEPValidator;
end;

procedure RegisterBuiltInBrazilianPhoneValidator;
begin
  RegisterBrazilianPhoneValidator;
end;

procedure RegisterBuiltInBrazilianLicensePlateValidator;
begin
  RegisterBrazilianLicensePlateValidator;
end;

procedure RegisterAllBrazilianFormatValidators;
begin
  RegisterBuiltInCPFValidator;
  RegisterBuiltInCNPJValidator;
  RegisterBuiltInCEPValidator;
  RegisterBuiltInBrazilianPhoneValidator;
  RegisterBuiltInBrazilianLicensePlateValidator;
end;

end.