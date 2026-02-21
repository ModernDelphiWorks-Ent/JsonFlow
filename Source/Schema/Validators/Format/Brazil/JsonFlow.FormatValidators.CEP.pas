unit JsonFlow.FormatValidators.CEP;

{*******************************************************************************
  Validador de formato para CEP brasileiro
  
  Este validador verifica se uma string está no formato de CEP válido.
  
  Formatos aceitos:
  - 01234-567
  - 01234567
  
  Autor: JsonFlow4D
  Data: 2024
*******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.RegularExpressions,
  JsonFlow4D.FormatValidators.Base,
  JsonFlow4D.FormatRegistry;

type
  // Validador de CEP brasileiro
  TCEPFormatValidator = class(TBaseFormatValidatorPlugin)
  protected
    function DoValidate(const AValue: string): Boolean; override;
  end;

// Procedimento para registrar o validador
procedure RegisterCEPValidator;

implementation

{ TCEPFormatValidator }

function TCEPFormatValidator.DoValidate(const AValue: string): Boolean;
var
  LPattern: string;
begin
  // Padrão para CEP: 8 dígitos com ou sem hífen
  // Formatos aceitos: 12345-678 ou 12345678
  LPattern := '^\d{5}-?\d{3}$';
  
  Result := TRegEx.IsMatch(AValue, LPattern);
end;

procedure RegisterCEPValidator;
begin
  TFormatRegistry.RegisterValidator('cep', TCEPFormatValidator.Create('cep', 'CEP inválido'));
end;

end.