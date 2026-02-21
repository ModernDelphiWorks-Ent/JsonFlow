# Performance - Exemplos de Otimização e Performance

Esta pasta contém exemplos demonstrando otimizações e testes de performance do JsonFlow4D.

## 📁 Exemplos Disponíveis

### ⚡ **NativePerformanceConsole**
- **Arquivo:** `NativePerformanceConsole.dpr`
- **Descrição:** Testes de performance nativa do JsonFlow4D
- **Funcionalidades:**
  - Benchmarks de conversão
  - Comparação de performance entre métodos
  - Análise de uso de memória
  - Testes com grandes volumes de dados

### 📊 **NativePerformanceDemo**
- **Arquivo:** `NativePerformanceDemo.pas`
- **Descrição:** Implementação dos testes de performance
- **Funcionalidades:**
  - Métricas detalhadas
  - Relatórios de performance
  - Comparações entre versões

## 🚀 Como Executar

1. **Compilação:**
   ```bash
   dcc32 NativePerformanceConsole.dpr
   ```

2. **Execução:**
   ```bash
   NativePerformanceConsole.exe
   ```

## 📈 Métricas Avaliadas

- **Tempo de Conversão:** Velocidade de processamento
- **Uso de Memória:** Eficiência no gerenciamento de recursos
- **Throughput:** Volume de dados processados por segundo
- **Latência:** Tempo de resposta para operações individuais

## 💡 Cenários de Teste

- **Pequenos JSONs:** < 1KB
- **Médios JSONs:** 1KB - 100KB
- **Grandes JSONs:** > 100KB
- **Arrays Extensos:** Milhares de elementos
- **Objetos Complexos:** Estruturas aninhadas profundas

## 🎯 Objetivos

- Identificar gargalos de performance
- Validar otimizações implementadas
- Comparar com outras bibliotecas
- Estabelecer benchmarks de referência

## 📋 Requisitos

- Delphi 10.3 ou superior
- JsonFlow4D framework
- Dados de teste (gerados automaticamente)