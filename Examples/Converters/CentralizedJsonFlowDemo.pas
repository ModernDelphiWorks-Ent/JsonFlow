unit CentralizedJsonFlowDemo;

{$I ../Source/jsonflow4d.inc}

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  JsonFlow;

type
  /// <summary>
  /// Classe de demonstração para o uso centralizado do TJsonFlow
  /// Mostra como usar uma única classe para todas as conversões
  /// </summary>
  TCentralizedJsonFlowDemo = class
  private
    class procedure WriteHeader(const ATitle: string);
    class procedure WriteSeparator;
    class procedure WriteResult(const AOperation, AResult: string);
    class procedure WriteError(const AOperation, AError: string);
  public
    /// <summary>
    /// Executa todos os exemplos de demonstração
    /// </summary>
    class procedure RunAllExamples;
    
    /// <summary>
    /// Demonstra conversões XML <-> JSON
    /// </summary>
    class procedure DemoXMLConversions;
    
    /// <summary>
    /// Demonstra conversões DataSet <-> JSON
    /// </summary>
    class procedure DemoDataSetConversions;
    
    /// <summary>
    /// Demonstra conversões Object <-> JSON
    /// </summary>
    class procedure DemoObjectConversions;
    
    /// <summary>
    /// Demonstra métodos utilitários
    /// </summary>
    class procedure DemoUtilityMethods;
    
    /// <summary>
    /// Demonstra configurações avançadas
    /// </summary>
    class procedure DemoAdvancedConfiguration;
  end;

  /// <summary>
  /// Classe de exemplo para demonstrar conversão de objetos
  /// </summary>
  TPerson = class
  private
    FName: string;
    FAge: Integer;
    FEmail: string;
  public
    constructor Create(const AName: string; AAge: Integer; const AEmail: string);
    property Name: string read FName write FName;
    property Age: Integer read FAge write FAge;
    property Email: string read FEmail write FEmail;
  end;

implementation

{ TCentralizedJsonFlowDemo }

class procedure TCentralizedJsonFlowDemo.WriteHeader(const ATitle: string);
begin
  Writeln;
  Writeln('=' + StringOfChar('=', Length(ATitle) + 2) + '=');
  Writeln('| ' + ATitle + ' |');
  Writeln('=' + StringOfChar('=', Length(ATitle) + 2) + '=');
  Writeln;
end;

class procedure TCentralizedJsonFlowDemo.WriteSeparator;
begin
  Writeln(StringOfChar('-', 60));
end;

class procedure TCentralizedJsonFlowDemo.WriteResult(const AOperation, AResult: string);
begin
  Writeln(Format('[%s] Resultado:', [AOperation]));
  Writeln(AResult);
  Writeln;
end;

class procedure TCentralizedJsonFlowDemo.WriteError(const AOperation, AError: string);
begin
  Writeln(Format('[%s] ERRO: %s', [AOperation, AError]));
  Writeln;
end;

class procedure TCentralizedJsonFlowDemo.RunAllExamples;
begin
  WriteHeader('DEMONSTRAÇÃO CENTRALIZADA DO JSONFLOW4D');
  Writeln('Esta demonstração mostra como usar o TJsonFlow como interface unificada');
  Writeln('para todas as funcionalidades de conversão do JsonFlow4D.');
  Writeln;
  
  DemoXMLConversions;
  DemoDataSetConversions;
  DemoObjectConversions;
  DemoUtilityMethods;
  DemoAdvancedConfiguration;
  
  WriteHeader('DEMONSTRAÇÃO CONCLUÍDA');
  Writeln('Pressione ENTER para sair...');
  Readln;
end;

class procedure TCentralizedJsonFlowDemo.DemoXMLConversions;
var
  LXML, LJSON, LXMLResult: string;
begin
  WriteHeader('CONVERSÕES XML <-> JSON');
  
  // XML de exemplo
  LXML := '<person><name>João Silva</name><age>30</age><email>joao@email.com</email></person>';
  
  Writeln('XML Original:');
  Writeln(LXML);
  WriteSeparator;
  
  try
    // XML para JSON
    LJSON := TJsonFlow4D.XMLToJSON(LXML);
    WriteResult('XML -> JSON', LJSON);
    
    // JSON para XML
    LXMLResult := TJsonFlow4D.JSONToXML(LJSON);
    WriteResult('JSON -> XML', LXMLResult);
    
    // Conversão com opções
    LJSON := TJsonFlow4D.XMLToJSON(LXML, 'pretty=true;encoding=utf8');
    WriteResult('XML -> JSON (com opções)', LJSON);
    
  except
    on E: Exception do
      WriteError('Conversão XML', E.Message);
  end;
end;

class procedure TCentralizedJsonFlowDemo.DemoDataSetConversions;
var
  LDataSet: TDataSet;
  LJSON: string;
  LSuccess: Boolean;
begin
  WriteHeader('CONVERSÕES DATASET <-> JSON');
  
  // Nota: Esta é uma demonstração conceitual
  // Em um cenário real, você criaria e popularia um TDataSet
  
  Writeln('Demonstração conceitual de conversão DataSet <-> JSON');
  Writeln('(Requer implementação específica do DataSet)');
  WriteSeparator;
  
  try
    // Simulação de conversão DataSet para JSON
    // LDataSet := CreateSampleDataSet; // Implementar conforme necessário
    // LJSON := TJsonFlow4D.DataSetToJSON(LDataSet);
    // WriteResult('DataSet -> JSON', LJSON);
    
    // Simulação de conversão JSON para DataSet
    LJSON := '[{"id":1,"name":"João","age":30},{"id":2,"name":"Maria","age":25}]';
    Writeln('JSON de exemplo:');
    Writeln(LJSON);
    WriteSeparator;
    
    // LSuccess := TJsonFlow4D.JSONToDataSet(LJSON, LDataSet);
    // WriteResult('JSON -> DataSet', 'Sucesso: ' + BoolToStr(LSuccess, True));
    
    Writeln('Conversão DataSet implementada conceitualmente.');
    
  except
    on E: Exception do
      WriteError('Conversão DataSet', E.Message);
  end;
end;

class procedure TCentralizedJsonFlowDemo.DemoObjectConversions;
var
  LPerson: TPerson;
  LJSON: string;
  LPersonFromJSON: TPerson;
begin
  WriteHeader('CONVERSÕES OBJECT <-> JSON');
  
  // Criar objeto de exemplo
  LPerson := TPerson.Create('Maria Santos', 28, 'maria@email.com');
  try
    Writeln('Objeto Original:');
    Writeln(Format('Nome: %s, Idade: %d, Email: %s', [LPerson.Name, LPerson.Age, LPerson.Email]));
    WriteSeparator;
    
    try
      // Object para JSON (usando o método existente do TJsonFlow)
      LJSON := TJsonFlow4D.ObjectToJsonString(LPerson);
      WriteResult('Object -> JSON', LJSON);
      
      // JSON para Object (usando o método existente do TJsonFlow)
      LPersonFromJSON := TJsonFlow4D.JsonToObject<TPerson>(LJSON);
      try
        WriteResult('JSON -> Object', 
          Format('Nome: %s, Idade: %d, Email: %s', 
            [LPersonFromJSON.Name, LPersonFromJSON.Age, LPersonFromJSON.Email]));
      finally
        LPersonFromJSON.Free;
      end;
      
    except
      on E: Exception do
        WriteError('Conversão Object', E.Message);
    end;
    
  finally
    LPerson.Free;
  end;
end;

class procedure TCentralizedJsonFlowDemo.DemoUtilityMethods;
var
  LValidJSON, LInvalidJSON: string;
  LValidXML, LInvalidXML: string;
begin
  WriteHeader('MÉTODOS UTILITÁRIOS');
  
  // Teste de validação JSON
  LValidJSON := '{"name":"João","age":30}';
  LInvalidJSON := '{"name":"João","age":}';
  
  Writeln('Validação JSON:');
  Writeln(Format('JSON Válido ("%s"): %s', [LValidJSON, BoolToStr(TJsonFlow4D.IsValidJSON(LValidJSON), True)]));
  Writeln(Format('JSON Inválido ("%s"): %s', [LInvalidJSON, BoolToStr(TJsonFlow4D.IsValidJSON(LInvalidJSON), True)]));
  WriteSeparator;
  
  // Teste de validação XML
  LValidXML := '<person><name>João</name></person>';
  LInvalidXML := '<person><name>João</name>';
  
  Writeln('Validação XML:');
  Writeln(Format('XML Válido: %s', [BoolToStr(TJsonFlow4D.IsValidXML(LValidXML), True)]));
  Writeln(Format('XML Inválido: %s', [BoolToStr(TJsonFlow4D.IsValidXML(LInvalidXML), True)]));
  WriteSeparator;
  
  // Teste de gerenciamento de erros
  Writeln('Gerenciamento de Erros:');
  TJsonFlow4D.ClearConverterError;
  Writeln('Erro limpo.');
  
  // Forçar um erro
  TJsonFlow4D.XMLToJSON('');
  Writeln(Format('Último erro: %s', [TJsonFlow4D.GetConverterLastError]));
  Writeln;
end;

class procedure TCentralizedJsonFlowDemo.DemoAdvancedConfiguration;
begin
  WriteHeader('CONFIGURAÇÕES AVANÇADAS');
  
  Writeln('Configurando conversores:');
  
  // Configurar conversor XML
  TJsonFlow4D.ConfigureXMLConverter('encoding=utf8;pretty=true;validate=false');
  Writeln('✓ Conversor XML configurado');
  
  // Configurar conversor DataSet
  TJsonFlow4D.ConfigureDataSetConverter('include_metadata=true;date_format=iso8601');
  Writeln('✓ Conversor DataSet configurado');
  
  // Configurar conversor Object
  TJsonFlow4D.ConfigureObjectConverter('include_nulls=false;camel_case=true');
  Writeln('✓ Conversor Object configurado');
  
  WriteSeparator;
  
  Writeln('Configurações aplicadas com sucesso!');
  Writeln('Todas as conversões subsequentes usarão essas configurações.');
  Writeln;
end;

{ TPerson }

constructor TPerson.Create(const AName: string; AAge: Integer; const AEmail: string);
begin
  inherited Create;
  FName := AName;
  FAge := AAge;
  FEmail := AEmail;
end;

end.