# Converters - Exemplos de Conversores Unificados

Esta pasta contém exemplos demonstrando o uso dos conversores unificados do JsonFlow4D.

## 📁 Exemplos Disponíveis

### 🎯 **CentralizedJsonFlowDemo** (RECOMENDADO)
- **Arquivo:** `CentralizedJsonFlowDemo.dpr`
- **Descrição:** Demonstra o uso da facade centralizada `TJsonFlow`
- **Compilar:** `compile_centralized_demo.bat`
- **Vantagens:** Interface mais simples, tudo em uma classe
- **Funcionalidades:**
  - Conversões XML ↔ JSON
  - Conversões DataSet ↔ JSON
  - Conversões Object ↔ JSON
  - Métodos utilitários (validação)
  - Configurações avançadas

### 🔧 **UnifiedConvertersDemo** (Alternativo)
- **Arquivo:** `UnifiedConvertersDemo.dpr`
- **Descrição:** Demonstra o uso da interface `IJsonFlowConverters`
- **Compilar:** `compile_unified_demo.bat`
- **Uso:** Para casos que precisam de controle mais granular
- **Funcionalidades:**
  - Acesso direto aos conversores específicos
  - Controle de ciclo de vida dos conversores
  - Configurações personalizadas por conversor

## 🚀 Como Executar

1. **Compilação Rápida:**
   ```bash
   # Para o exemplo centralizado
   compile_centralized_demo.bat
   
   # Para o exemplo unificado
   compile_unified_demo.bat
   ```

2. **Execução:**
   ```bash
   CentralizedJsonFlowDemo.exe
   UnifiedConvertersDemo.exe
   ```

## 💡 Qual Escolher?

- **Use CentralizedJsonFlowDemo** se você quer simplicidade e facilidade de uso
- **Use UnifiedConvertersDemo** se você precisa de controle granular sobre os conversores

## 📋 Requisitos

- Delphi 10.3 ou superior
- JsonFlow4D framework
- Windows (para os scripts .bat)