# Validators - Exemplos de Validadores Customizados

Esta pasta contém exemplos demonstrando o uso de validadores customizados do JsonFlow4D.

## 📁 Exemplos Disponíveis

### 🇧🇷 **BrazilianValidatorsExample**
- **Arquivo:** `BrazilianValidatorsExample.dpr`
- **Descrição:** Validadores específicos para documentos brasileiros
- **Funcionalidades:**
  - Validação de CPF
  - Validação de CNPJ
  - Validação de CEP
  - Validação de telefones brasileiros
  - Validação de placas de veículos

### 🔧 **CustomFormatValidators**
- **Arquivo:** `CustomFormatValidators.pas`
- **Descrição:** Implementação de validadores de formatos personalizados
- **Funcionalidades:**
  - Validadores de email customizados
  - Validadores de URLs específicas
  - Validadores de códigos de barras
  - Validadores de formatos proprietários

## 🚀 Como Executar

1. **Compilação:**
   ```bash
   dcc32 BrazilianValidatorsExample.dpr
   ```

2. **Execução:**
   ```bash
   BrazilianValidatorsExample.exe
   ```

## 🛠️ Validadores Brasileiros Incluídos

### 📄 **CPF (Cadastro de Pessoa Física)**
- Validação de formato (XXX.XXX.XXX-XX)
- Verificação de dígitos verificadores
- Detecção de CPFs inválidos conhecidos

### 🏢 **CNPJ (Cadastro Nacional de Pessoa Jurídica)**
- Validação de formato (XX.XXX.XXX/XXXX-XX)
- Verificação de dígitos verificadores
- Validação de estrutura

### 📮 **CEP (Código de Endereçamento Postal)**
- Validação de formato (XXXXX-XXX)
- Verificação de faixas válidas
- Suporte a diferentes formatos

### 📱 **Telefones**
- Validação de telefones fixos
- Validação de celulares
- Suporte a códigos de área
- Formatos com e sem país

### 🚗 **Placas de Veículos**
- Formato antigo (ABC-1234)
- Formato Mercosul (ABC1D23)
- Validação de caracteres permitidos

## 💡 Como Criar Validadores Customizados

```pascal
// Exemplo de validador customizado
function ValidateCustomFormat(const AValue: string): Boolean;
begin
  // Implementar lógica de validação
  Result := // sua validação aqui
end;

// Registrar o validador
TJsonFlow4D.RegisterValidator('custom_format', ValidateCustomFormat);
```

## 🎯 Casos de Uso

- **Sistemas Brasileiros:** Validação de documentos nacionais
- **E-commerce:** Validação de dados de entrega
- **Cadastros:** Validação de informações pessoais
- **APIs:** Validação de entrada de dados

## 📋 Requisitos

- Delphi 10.3 ou superior
- JsonFlow4D framework
- Conhecimento de expressões regulares (opcional)
