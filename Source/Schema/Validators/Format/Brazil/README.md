# Validadores de Formato Brasileiros

Este diretório contém validadores de formato específicos para documentos e formatos brasileiros, organizados de forma modular para facilitar manutenção e extensibilidade.

## Validadores Disponíveis

### 1. CPF (Cadastro de Pessoas Físicas)
**Arquivo:** `JsonFlow4D.FormatValidators.CPF.pas`  
**Formato:** `cpf`

**Formatos aceitos:**
- `123.456.789-09` (com pontuação)
- `12345678909` (sem pontuação)

**Validação:** Inclui verificação do dígito verificador conforme algoritmo oficial.

### 2. CNPJ (Cadastro Nacional da Pessoa Jurídica)
**Arquivo:** `JsonFlow4D.FormatValidators.CNPJ.pas`  
**Formato:** `cnpj`

**Formatos aceitos:**
- `11.222.333/0001-81` (com pontuação)
- `11222333000181` (sem pontuação)

**Validação:** Inclui verificação do dígito verificador conforme algoritmo oficial.

### 3. CEP (Código de Endereçamento Postal)
**Arquivo:** `JsonFlow4D.FormatValidators.CEP.pas`  
**Formato:** `cep`

**Formatos aceitos:**
- `01234-567` (com hífen)
- `01234567` (sem hífen)

**Validação:** Verifica se possui exatamente 8 dígitos numéricos.

### 4. Telefone Brasileiro
**Arquivo:** `JsonFlow4D.FormatValidators.BrazilianPhone.pas`  
**Formato:** `brazilian-phone`

**Formatos aceitos:**
- `(11) 99999-9999` (celular com formatação)
- `(11) 3333-4444` (fixo com formatação)
- `11999999999` (celular sem formatação)
- `1133334444` (fixo sem formatação)
- `+55 11 99999-9999` (internacional com espaços)
- `+5511999999999` (internacional sem espaços)

**Validação:** 
- Verifica DDD válido (11-99, excluindo alguns códigos não utilizados)
- Para celulares: primeiro dígito após DDD deve ser 9
- Para fixos: primeiro dígito após DDD deve ser 2-5

### 5. Placa de Veículo Brasileira
**Arquivo:** `JsonFlow4D.FormatValidators.BrazilianLicensePlate.pas`  
**Formato:** `brazilian-license-plate`

**Formatos aceitos:**
- `ABC-1234` (formato antigo com hífen)
- `ABC1234` (formato antigo sem hífen)
- `ABC1D23` (formato Mercosul sem hífen)
- `ABC-1D23` (formato Mercosul com hífen)

**Validação:** Suporta tanto o formato antigo quanto o novo formato Mercosul.

## Como Usar

### 1. Registro Individual

```pascal
uses
  JsonFlow4D.FormatValidators.CPF;

begin
  // Registra apenas o validador de CPF
  RegisterCPFValidator;
end;
```

### 2. Registro de Todos os Validadores Brasileiros

```pascal
uses
  JsonFlow4D.FormatValidators.Brazil;

begin
  // Registra todos os validadores brasileiros de uma vez
  RegisterAllBrazilianFormatValidators;
end;
```

### 3. Uso em Schema JSON

```json
{
  "type": "object",
  "properties": {
    "cpf": {
      "type": "string",
      "format": "cpf"
    },
    "cnpj": {
      "type": "string",
      "format": "cnpj"
    },
    "cep": {
      "type": "string",
      "format": "cep"
    },
    "telefone": {
      "type": "string",
      "format": "brazilian-phone"
    },
    "placa": {
      "type": "string",
      "format": "brazilian-license-plate"
    }
  }
}
```

### 4. Validação Programática

```pascal
uses
  JsonFlow4D.FormatRegistry,
  JsonFlow4D.FormatValidators.Brazil;

var
  LValidator: IFormatValidator;
begin
  // Registra os validadores
  RegisterAllBrazilianFormatValidators;
  
  // Obtém um validador específico
  LValidator := TFormatRegistry.GetValidator('cpf');
  
  // Valida um CPF
  if LValidator.Validate('123.456.789-09') then
    WriteLn('CPF válido')
  else
    WriteLn('CPF inválido');
end;
```

## Estrutura dos Arquivos

Cada validador segue a mesma estrutura:

1. **Classe Validadora:** Herda de `TBaseFormatValidatorPlugin`
2. **Método `DoValidate`:** Implementa a lógica de validação
3. **Procedimento de Registro:** Registra o validador no sistema

## Dependências

- `JsonFlow4D.FormatValidators.Base` - Classe base para validadores
- `JsonFlow4D.FormatRegistry` - Sistema de registro de validadores
- `System.RegularExpressions` - Para validações com regex (quando aplicável)

## Exemplos

Veja o arquivo `Examples/BrazilianValidatorsExample.dpr` para um exemplo completo de uso dos validadores brasileiros.

## Contribuindo

Para adicionar novos validadores brasileiros:

1. Crie um novo arquivo seguindo o padrão `JsonFlow4D.FormatValidators.{Nome}.pas`
2. Implemente a classe herdando de `TBaseFormatValidatorPlugin`
3. Adicione o procedimento de registro
4. Inclua a unit no arquivo `JsonFlow4D.FormatValidators.Brazil.pas`
5. Atualize este README com a documentação do novo validador