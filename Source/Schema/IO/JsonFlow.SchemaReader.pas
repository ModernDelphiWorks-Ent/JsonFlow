unit JsonFlow.SchemaReader;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.StrUtils,
  JsonFlow4D.Interfaces,
  JsonFlow4D.Reader;

type
  TJSONSchemaReader = class(TInterfacedObject, IJSONSchemaReader)
  private
    FLogProc: TProc<String>;
    FSchema: IJSONElement;
    FValidator: IJSONSchemaValidator;
    FReader: IJSONReader;
    function _DetectVersion(const AElement: IJSONElement): TJsonSchemaVersion;
    procedure _CreateValidator(const AVersion: TJsonSchemaVersion);
    function _LoadSchema(const AJson: string): Boolean;
  protected
    procedure _Log(const AMessage: string);
  public
    constructor Create;
    destructor Destroy; override;
    function LoadFromFile(const AFileName: string): Boolean;
    function LoadFromString(const AJsonString: string): Boolean;
    function Validate(const AJson: string): Boolean; overload;
    function Validate(const AElement: IJSONElement): Boolean; overload;
    function Validate(const AJson, AJsonSchema: String): Boolean; overload;
    function GetErrors: TArray<TValidationError>;
    function GetVersion: TJsonSchemaVersion;
    function GetSchema: IJSONElement;
  end;

implementation

uses
  JsonFlow4D.SchemaValidator;

constructor TJSONSchemaReader.Create;
begin
  FReader := TJSONReader.Create;
  FValidator := TJSONSchemaValidator.Create(jsvDraft7);
end;

destructor TJSONSchemaReader.Destroy;
begin
  FValidator := nil;
  FReader := nil;
  inherited;
end;

function TJSONSchemaReader._DetectVersion(const AElement: IJSONElement): TJsonSchemaVersion;
var
  LObj: IJSONObject;
  LSchemaValue: IJSONElement;
  LSchemaValueObj: IJSONValue;
  LSchema: string;
begin
  Result := jsvDraft7; // Default
  
  if not Assigned(AElement) then
    Exit;
    
  if Supports(AElement, IJSONObject, LObj) then
  begin
    if LObj.ContainsKey('$schema') then
    begin
      LSchemaValue := LObj.GetValue('$schema');
      if Assigned(LSchemaValue) and Supports(LSchemaValue, IJSONValue, LSchemaValueObj) then
      begin
        if LSchemaValueObj.IsString then
        begin
          LSchema := LSchemaValueObj.AsString;
          if Pos('draft-03', LSchema) > 0 then
            Result := jsvDraft3
          else if Pos('draft-04', LSchema) > 0 then
            Result := jsvDraft4
          else if Pos('draft-06', LSchema) > 0 then
            Result := jsvDraft6
          else if Pos('draft-07', LSchema) > 0 then
            Result := jsvDraft7
          else if Pos('2019-09', LSchema) > 0 then
            Result := jsvDraft201909
          else if Pos('2020-12', LSchema) > 0 then
            Result := jsvDraft202012;
        end;
      end;
    end;
  end;
end;

procedure TJSONSchemaReader._CreateValidator(const AVersion: TJsonSchemaVersion);
begin
  if Assigned(FValidator) then
    FValidator := nil; // Liberar referência anterior
  FValidator := TJSONSchemaValidator.Create(AVersion);
end;

function TJSONSchemaReader._LoadSchema(const AJson: string): Boolean;
var
  LVersion: TJsonSchemaVersion;
  LOldErrors: TArray<TValidationError>;
  LFor: Integer;
begin
  Result := True;
  try
    FSchema := FReader.Read(AJson);
    LVersion := _DetectVersion(FSchema);
    
    if LVersion <> FValidator.GetVersion then
    begin
      LOldErrors := FValidator.GetErrors;
      _CreateValidator(LVersion);
      for LFor := 0 to Length(LOldErrors) - 1 do
        FValidator.AddError(LOldErrors[LFor].Path, LOldErrors[LFor].Message,
          LOldErrors[LFor].FoundValue, LOldErrors[LFor].ExpectedValue,
          LOldErrors[LFor].Keyword, LOldErrors[LFor].LineNumber,
          LOldErrors[LFor].ColumnNumber, LOldErrors[LFor].Context);
    end;
    
    FValidator.ParseSchema(FSchema);
  except
    on E: Exception do
    begin
      _CreateValidator(jsvDraft7);
      FValidator.AddError('', 'Failed to load schema', '', 'valid JSON', 'load', -1, -1, E.Message);
      Result := False;
    end;
  end;
end;

procedure TJSONSchemaReader._Log(const AMessage: string);
begin
  if Assigned(FLogProc) then
    FLogProc(Amessage);
end;

function TJSONSchemaReader.LoadFromFile(const AFileName: string): Boolean;
begin
  Result := _LoadSchema(TFile.ReadAllText(AFileName));
end;

function TJSONSchemaReader.LoadFromString(const AJsonString: string): Boolean;
begin
  Result := _LoadSchema(AJsonString);
end;

function TJSONSchemaReader.Validate(const AJson: string): Boolean;
var
  LElement: IJSONElement;
begin
  LElement := FReader.Read(AJson);
  Result := Validate(LElement);
end;

function TJSONSchemaReader.Validate(const AElement: IJSONElement): Boolean;
begin
  if not Assigned(FSchema) then
    raise Exception.Create('No schema loaded');
  Result := FValidator.Validate(AElement, '');
end;

function TJSONSchemaReader.Validate(const AJson, AJsonSchema: String): Boolean;
begin
  Result := FValidator.Validate(AJson, AJsonSchema);
end;

function TJSONSchemaReader.GetErrors: TArray<TValidationError>;
begin
  Result := FValidator.GetErrors;
end;

function TJSONSchemaReader.GetVersion: TJsonSchemaVersion;
begin
  Result := FValidator.GetVersion;
end;

function TJSONSchemaReader.GetSchema: IJSONElement;
begin
  Result := FSchema;
end;

end.
