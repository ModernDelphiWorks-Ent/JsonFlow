unit UnifiedConvertersDemo;

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  JsonFlow4D.Converters;

type
  /// <summary>
  /// Demonstração do uso da interface unificada de conversores
  /// Mostra como usar uma única classe para todas as conversões
  /// </summary>
  TUnifiedConvertersDemo = class
  private
    FConverters: IJsonFlowConverters;
  public
    constructor Create;
    destructor Destroy; override;
    
    // Demonstrações de uso
    procedure DemoXMLConversions;
    procedure DemoDataSetConversions;
    procedure DemoObjectConversions;
    procedure DemoUtilityMethods;
    procedure DemoConfigurationOptions;
    procedure RunAllDemos;
  end;

  /// <summary>
  /// Classe de exemplo para demonstrar conversão de objetos
  /// </summary>
  TPerson = class
  private
    FName: string;
    FAge: Integer;
    FEmail: string;
    FActive: Boolean;
  public
    property Name: string read FName write FName;
    property Age: Integer read FAge write FAge;
    property Email: string read FEmail write FEmail;
    property Active: Boolean read FActive write FActive;
  end;

implementation

{ TUnifiedConvertersDemo }

constructor TUnifiedConvertersDemo.Create;
begin
  inherited Create;
  // Criar instância padrão dos conversores unificados
  FConverters := TJsonFlowConvertersFactory.CreateDefault;
end;

destructor TUnifiedConvertersDemo.Destroy;
begin
  FConverters := nil;
  inherited Destroy;
end;

procedure TUnifiedConvertersDemo.DemoXMLConversions;
var
  LXML, LJSON, LXMLResult: string;
begin
  WriteLn('=== DEMONSTRAÇÃO: Conversões XML ===');
  WriteLn('');
  
  // XML para JSON
  LXML := '<person><name>João Silva</name><age>30</age><active>true</active></person>';
  WriteLn('XML Original:');
  WriteLn(LXML);
  WriteLn('');
  
  LJSON := FConverters.XMLToJSON(LXML);
  WriteLn('Convertido para JSON:');
  WriteLn(LJSON);
  WriteLn('');
  
  // JSON para XML
  LXMLResult := FConverters.JSONToXML(LJSON);
  WriteLn('Convertido de volta para XML:');
  WriteLn(LXMLResult);
  WriteLn('');
  
  // Conversão com opções
  LJSON := FConverters.XMLToJSON(LXML, 'preserve_attributes=true;format=pretty');
  WriteLn('XML para JSON com opções:');
  WriteLn(LJSON);
  WriteLn('');
  
  if not FConverters.GetLastError.IsEmpty then
  begin
    WriteLn('Erro: ' + FConverters.GetLastError);
    FConverters.ClearError;
  end;
  
  WriteLn('--- Fim das conversões XML ---');
  WriteLn('');
end;

procedure TUnifiedConvertersDemo.DemoDataSetConversions;
var
  LDataSet: TDataSet;
  LJSON: string;
  LSuccess: Boolean;
begin
  WriteLn('=== DEMONSTRAÇÃO: Conversões DataSet ===');
  WriteLn('');
  
  // Nota: Em um exemplo real, você criaria um DataSet real
  // Aqui estamos simulando para demonstrar a interface
  LDataSet := nil; // Simular DataSet
  
  try
    // DataSet para JSON
    WriteLn('Convertendo DataSet para JSON...');
    LJSON := FConverters.DataSetToJSON(LDataSet);
    WriteLn('JSON gerado:');
    WriteLn(LJSON);
    WriteLn('');
    
    // DataSet para JSON com opções
    LJSON := FConverters.DataSetToJSON(LDataSet, 'include_metadata=true;null_handling=exclude');
    WriteLn('DataSet para JSON com opções:');
    WriteLn(LJSON);
    WriteLn('');
    
    // JSON para DataSet
    LJSON := '[{"name":"João","age":30},{"name":"Maria","age":25}]';
    WriteLn('Convertendo JSON para DataSet:');
    WriteLn('JSON: ' + LJSON);
    
    LSuccess := FConverters.JSONToDataSet(LJSON, LDataSet);
    WriteLn('Conversão bem-sucedida: ' + BoolToStr(LSuccess, True));
    WriteLn('');
    
    // JSON para DataSet com opções
    LSuccess := FConverters.JSONToDataSet(LJSON, LDataSet, 'auto_create_fields=true;field_case=lower');
    WriteLn('JSON para DataSet com opções - Sucesso: ' + BoolToStr(LSuccess, True));
    WriteLn('');
    
  except
    on E: Exception do
      WriteLn('Erro na demonstração DataSet: ' + E.Message);
  end;
  
  if not FConverters.GetLastError.IsEmpty then
  begin
    WriteLn('Erro: ' + FConverters.GetLastError);
    FConverters.ClearError;
  end;
  
  WriteLn('--- Fim das conversões DataSet ---');
  WriteLn('');
end;

procedure TUnifiedConvertersDemo.DemoObjectConversions;
var
  LPerson: TPerson;
  LPersonResult: TPerson;
  LJSON: string;
  LSuccess: Boolean;
begin
  WriteLn('=== DEMONSTRAÇÃO: Conversões de Objetos ===');
  WriteLn('');
  
  // Objeto para JSON
  LPerson := TPerson.Create;
  try
    LPerson.Name := 'Ana Costa';
    LPerson.Age := 28;
    LPerson.Email := 'ana@email.com';
    LPerson.Active := True;
    
    WriteLn('Objeto Original:');
    WriteLn('Nome: ' + LPerson.Name);
    WriteLn('Idade: ' + IntToStr(LPerson.Age));
    WriteLn('Email: ' + LPerson.Email);
    WriteLn('Ativo: ' + BoolToStr(LPerson.Active, True));
    WriteLn('');
    
    LJSON := FConverters.ObjectToJSON(LPerson);
    WriteLn('Convertido para JSON:');
    WriteLn(LJSON);
    WriteLn('');
    
    // Objeto para JSON com opções
    LJSON := FConverters.ObjectToJSON(LPerson, 'ignore_nulls=true;date_format=iso8601');
    WriteLn('Objeto para JSON com opções:');
    WriteLn(LJSON);
    WriteLn('');
    
    // JSON para Objeto (criando nova instância)
    LJSON := '{"name":"Carlos Silva","age":35,"email":"carlos@email.com","active":false}';
    WriteLn('Convertendo JSON para novo objeto:');
    WriteLn('JSON: ' + LJSON);
    
    LPersonResult := TPerson(FConverters.JSONToObject(LJSON, TPerson));
    if Assigned(LPersonResult) then
    begin
      WriteLn('Novo objeto criado com sucesso!');
      LPersonResult.Free;
    end
    else
      WriteLn('Falha ao criar objeto do JSON');
    WriteLn('');
    
    // JSON para Objeto (populando objeto existente)
    LSuccess := FConverters.JSONToObject(LJSON, LPerson);
    WriteLn('Populando objeto existente - Sucesso: ' + BoolToStr(LSuccess, True));
    if LSuccess then
    begin
      WriteLn('Objeto atualizado:');
      WriteLn('Nome: ' + LPerson.Name);
      WriteLn('Idade: ' + IntToStr(LPerson.Age));
    end;
    WriteLn('');
    
  finally
    LPerson.Free;
  end;
  
  if not FConverters.GetLastError.IsEmpty then
  begin
    WriteLn('Erro: ' + FConverters.GetLastError);
    FConverters.ClearError;
  end;
  
  WriteLn('--- Fim das conversões de Objetos ---');
  WriteLn('');
end;

procedure TUnifiedConvertersDemo.DemoUtilityMethods;
var
  LJSON, LXML: string;
begin
  WriteLn('=== DEMONSTRAÇÃO: Métodos Utilitários ===');
  WriteLn('');
  
  // Validação de JSON
  LJSON := '{"name":"Teste","value":123}';
  WriteLn('Testando JSON válido: ' + LJSON);
  WriteLn('É JSON válido: ' + BoolToStr(FConverters.IsValidJSON(LJSON), True));
  WriteLn('');
  
  LJSON := '{"name":"Teste","value":123';
  WriteLn('Testando JSON inválido: ' + LJSON);
  WriteLn('É JSON válido: ' + BoolToStr(FConverters.IsValidJSON(LJSON), True));
  WriteLn('');
  
  // Validação de XML
  LXML := '<root><item>Teste</item></root>';
  WriteLn('Testando XML válido: ' + LXML);
  WriteLn('É XML válido: ' + BoolToStr(FConverters.IsValidXML(LXML), True));
  WriteLn('');
  
  LXML := '<root><item>Teste</item>';
  WriteLn('Testando XML inválido: ' + LXML);
  WriteLn('É XML válido: ' + BoolToStr(FConverters.IsValidXML(LXML), True));
  WriteLn('');
  
  WriteLn('--- Fim dos métodos utilitários ---');
  WriteLn('');
end;

procedure TUnifiedConvertersDemo.DemoConfigurationOptions;
var
  LOptimizedConverters, LFullConverters, LCustomConverters: IJsonFlowConverters;
  LJSON: string;
begin
  WriteLn('=== DEMONSTRAÇÃO: Opções de Configuração ===');
  WriteLn('');
  
  // Conversor otimizado
  WriteLn('Criando conversor otimizado...');
  LOptimizedConverters := TJsonFlowConvertersFactory.CreateOptimized;
  LJSON := LOptimizedConverters.ObjectToJSON(Self);
  WriteLn('Resultado otimizado: ' + LJSON);
  WriteLn('');
  
  // Conversor completo
  WriteLn('Criando conversor completo...');
  LFullConverters := TJsonFlowConvertersFactory.CreateFull;
  LJSON := LFullConverters.ObjectToJSON(Self);
  WriteLn('Resultado completo: ' + LJSON);
  WriteLn('');
  
  // Conversor customizado
  WriteLn('Criando conversor customizado...');
  LCustomConverters := TJsonFlowConvertersFactory.CreateCustom(
    'xml_config=custom;preserve_cdata=true',
    'dataset_config=custom;include_metadata=false',
    'object_config=custom;serialize_private=true'
  );
  LJSON := LCustomConverters.ObjectToJSON(Self);
  WriteLn('Resultado customizado: ' + LJSON);
  WriteLn('');
  
  // Configuração dinâmica
  WriteLn('Configurando conversor dinamicamente...');
  FConverters.ConfigureXMLConverter('dynamic_xml_config');
  FConverters.ConfigureDataSetConverter('dynamic_dataset_config');
  FConverters.ConfigureObjectConverter('dynamic_object_config');
  WriteLn('Configurações aplicadas com sucesso!');
  WriteLn('');
  
  WriteLn('--- Fim das opções de configuração ---');
  WriteLn('');
end;

procedure TUnifiedConvertersDemo.RunAllDemos;
begin
  WriteLn('===============================================');
  WriteLn('    DEMONSTRAÇÃO: JsonFlow4D Conversores Unificados');
  WriteLn('===============================================');
  WriteLn('');
  WriteLn('Esta demonstração mostra como usar uma única interface');
  WriteLn('para acessar todas as funcionalidades de conversão:');
  WriteLn('- XMLToJSON / JSONToXML');
  WriteLn('- DataSetToJSON / JSONToDataSet');
  WriteLn('- ObjectToJSON / JSONToObject');
  WriteLn('- Métodos utilitários e configurações');
  WriteLn('');
  WriteLn('===============================================');
  WriteLn('');
  
  try
    DemoXMLConversions;
    DemoDataSetConversions;
    DemoObjectConversions;
    DemoUtilityMethods;
    DemoConfigurationOptions;
    
    WriteLn('===============================================');
    WriteLn('    TODAS AS DEMONSTRAÇÕES CONCLUÍDAS!');
    WriteLn('===============================================');
    WriteLn('');
    WriteLn('Vantagens da Interface Unificada:');
    WriteLn('✓ Uma única classe para todas as conversões');
    WriteLn('✓ Interface consistente e intuitiva');
    WriteLn('✓ Tratamento de erros centralizado');
    WriteLn('✓ Configurações flexíveis');
    WriteLn('✓ Métodos utilitários integrados');
    WriteLn('✓ Fácil manutenção e evolução');
    WriteLn('');
    WriteLn('Para usar apenas conversores específicos,');
    WriteLn('você ainda pode usar as units independentes!');
    WriteLn('');
    
  except
    on E: Exception do
    begin
      WriteLn('Erro durante a demonstração: ' + E.Message);
      if not FConverters.GetLastError.IsEmpty then
      begin
        WriteLn('Último erro do conversor: ' + FConverters.GetLastError);
      end;
    end;
  end;
end;

end.