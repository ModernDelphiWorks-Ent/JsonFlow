program SchemaRefAndSchemaPathDemo;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.IOUtils,
  JsonFlow.SchemaReader,
  JsonFlow.Interfaces;

procedure PrintErrors(const AErrors: TArray<TValidationError>);
var
  I: Integer;
begin
  for I := 0 to Length(AErrors) - 1 do
  begin
    Writeln('Path:       ', AErrors[I].Path);
    Writeln('SchemaPath: ', AErrors[I].SchemaPath);
    Writeln('Keyword:    ', AErrors[I].Keyword);
    Writeln('Message:    ', AErrors[I].Message);
    Writeln;
  end;
end;

procedure DemoSchemaPath;
var
  LReader: TJSONSchemaReader;
  LSchema: string;
begin
  Writeln('=== Demo: SchemaPath (minLength deep) ===');

  LSchema :=
    '{' +
    '  "type":"object",' +
    '  "properties": {' +
    '    "a": {' +
    '      "type":"object",' +
    '      "properties": {' +
    '        "b": {"type":"string","minLength": 3}' +
    '      },' +
    '      "required": ["b"]' +
    '    }' +
    '  },' +
    '  "required": ["a"]' +
    '}';

  LReader := TJSONSchemaReader.Create;
  try
    if not LReader.LoadFromString(LSchema) then
    begin
      PrintErrors(LReader.GetErrors);
      Exit;
    end;

    if not LReader.Validate('{"a":{"b":"hi"}}') then
      PrintErrors(LReader.GetErrors)
    else
      Writeln('OK');
  finally
    LReader.Free;
  end;

  Writeln;
end;

procedure DemoRefFile;
var
  LReader: TJSONSchemaReader;
  LSchemaFile: string;
begin
  Writeln('=== Demo: $ref por arquivo relativo ===');

  LSchemaFile := TPath.Combine(ExtractFilePath(ParamStr(0)), 'schemas\root-file-ref.json');

  LReader := TJSONSchemaReader.Create;
  try
    if not LReader.LoadFromFile(LSchemaFile) then
    begin
      PrintErrors(LReader.GetErrors);
      Exit;
    end;

    if not LReader.Validate('{"zip":"123"}') then
      PrintErrors(LReader.GetErrors)
    else
      Writeln('OK');
  finally
    LReader.Free;
  end;

  Writeln;
end;

begin
  try
    DemoSchemaPath;
    DemoRefFile;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

