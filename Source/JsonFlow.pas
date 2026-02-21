{
                          Apache License

       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

             http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.
}

{
  @abstract(JsonFlow4D: Advanced JSON Handling Framework for Delphi)
  @description(A versatile and powerful library for JSON serialization, deserialization, and manipulation in Delphi. It offers navigation via pointers, the ability to edit and update JSON, and supports middleware for custom type handling and JSON schema validation.)
  @created(03 Abr 2025)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @Discord(https://discord.gg/T2zJC8zX)
}

{$include ./jsonflow4d.inc}

unit JsonFlow;

interface

uses
  System.Rtti,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Data.DB,
  JsonFlow4D.Interfaces,
  JsonFlow4D.Reader,
  JsonFlow4D.Writer,
  JsonFlow4D.Serializer,
  JsonFlow4D.Converters;

type
  TJsonFlow = class
  private
    class var FReader: TJSONReader;
    class var FWriter: TJSONWriter;
    class var FSerializer: TJSONSerializer;
    class var FConverters: IJsonFlowConverters;
    class var FFormatSettings: TFormatSettings;
    class procedure _Initialization; static; inline;
    class procedure _SetFormatSettings(const Value: TFormatSettings); static; inline;
  public
    class constructor Create;
    class destructor Destroy;
    class function ObjectToJsonString(AObject: TObject; AStoreClassName: Boolean = False): String; static; inline;
    class function ObjectListToJsonString(AObjectList: TObjectList<TObject>; AStoreClassName: Boolean = False): String; overload; static; inline;
    class function ObjectListToJsonString<T: class, constructor>(AObjectList: TObjectList<T>; AStoreClassName: Boolean = False): String; overload; static; inline;
    class function JsonToObject<T: class, constructor>(const AJson: String): T; overload; static; inline;
    class function JsonToObject<T: class>(const AObject: T; const AJson: String): Boolean; overload; static; inline;
    class function JsonToObjectList<T: class, constructor>(const AJson: String): TObjectList<T>; overload; static; inline;
    class function JsonToObjectList(const AJson: String; const AType: TClass): TObjectList<TObject>; overload; static; inline;
    class function Parse(const AJson: String): IJSONElement; static; inline;
    class function ToJson(const AElement: IJSONElement; const AIdent: Boolean = False): String; static; inline;
    class function FromObject(AObject: TObject; AStoreClassName: Boolean = False): IJSONElement; static; inline;
    class function ToObject(const AElement: IJSONElement; AObject: TObject): Boolean; static; inline;
    class procedure JsonToObject(const AJson: String; AObject: TObject); overload; static; inline;
    class procedure AddMiddleware(const AMiddleware: IEventMiddleware); static; inline;
    class procedure ClearMiddlewares; static; inline;
    class procedure OnLog(const ALogProc: TProc<String>); static; inline;
    // Converter Methods
    class function XMLToJSON(const AXML: string): string; overload; static; inline;
    class function JSONToXML(const AJSON: string): string; overload; static; inline;
    class function XMLToJSON(const AXML: string; const AOptions: string): string; overload; static; inline;
    class function JSONToXML(const AJSON: string; const AOptions: string): string; overload; static; inline;
    class function DataSetToJSON(ADataSet: TDataSet): string; overload; static; inline;
    class function JSONToDataSet(const AJSON: string; ADataSet: TDataSet): Boolean; overload; static; inline;
    class function DataSetToJSON(ADataSet: TDataSet; const AOptions: string): string; overload; static; inline;
    class function JSONToDataSet(const AJSON: string; ADataSet: TDataSet; const AOptions: string): Boolean; overload; static; inline;
    class function IsValidJSON(const AJSON: string): Boolean; static; inline;
    class function IsValidXML(const AXML: string): Boolean; static; inline;
    class function GetConverterLastError: string; static; inline;
    class procedure ClearConverterError; static; inline;
    class procedure ConfigureXMLConverter(const AConfig: string); static; inline;
    class procedure ConfigureDataSetConverter(const AConfig: string); static; inline;
    class procedure ConfigureObjectConverter(const AConfig: string); static; inline;
    //
    class property FormatSettings: TFormatSettings read FFormatSettings write _SetFormatSettings;
  end;

implementation

{ TJSONBr }

class procedure TJsonFlow4D._Initialization;
begin
  FSerializer := TJSONSerializer.Create(FFormatSettings);
  FReader := TJSONReader.Create(FFormatSettings);
  FWriter := TJSONWriter.Create(FFormatSettings);
  FConverters := TJsonFlowConvertersFactory.CreateDefault;
end;

class procedure TJsonFlow4D.ClearMiddlewares;
begin
  FSerializer.Middlewares.Clear;
end;

class constructor TJsonFlow4D.Create;
begin
  FFormatSettings := TFormatSettings.Create('en-US');
  FFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  FFormatSettings.DateSeparator := '-';
  FFormatSettings.TimeSeparator := ':';
  FFormatSettings.DecimalSeparator := '.';
  _Initialization;
end;

class destructor TJsonFlow4D.Destroy;
begin
  FConverters := nil;
  FSerializer.Free;
  FWriter.Free;
  FReader.Free;
end;

class procedure TJsonFlow4D.AddMiddleware(const AMiddleware: IEventMiddleware);
begin
  FSerializer.Middlewares.Add(AMiddleware);
end;

class function TJsonFlow4D.ObjectToJsonString(AObject: TObject; AStoreClassName: Boolean): String;
begin
  Result := FSerializer.FromObject(AObject, AStoreClassName).AsJSON;
end;

class function TJsonFlow4D.ObjectListToJsonString(AObjectList: TObjectList<TObject>; AStoreClassName: Boolean): String;
var
  LFor: Integer;
  LBuilder: TStringBuilder;
begin
  LBuilder := TStringBuilder.Create;
  try
    LBuilder.Append('[');
    for LFor := 0 to AObjectList.Count - 1 do
    begin
      LBuilder.Append(ObjectToJsonString(AObjectList[LFor], AStoreClassName));
      if LFor < AObjectList.Count - 1 then
        LBuilder.Append(',');
    end;
    LBuilder.Append(']');
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function TJsonFlow4D.ObjectListToJsonString<T>(AObjectList: TObjectList<T>; AStoreClassName: Boolean): String;
var
  LFor: Integer;
  LBuilder: TStringBuilder;
begin
  LBuilder := TStringBuilder.Create;
  try
    LBuilder.Append('[');
    for LFor := 0 to AObjectList.Count - 1 do
    begin
      LBuilder.Append(ObjectToJsonString(AObjectList[LFor], AStoreClassName));
      if LFor < AObjectList.Count - 1 then
        LBuilder.Append(',');
    end;
    LBuilder.Append(']');
    Result := LBuilder.ToString;
  finally
    LBuilder.Free;
  end;
end;

class function TJsonFlow4D.JsonToObject<T>(const AJson: String): T;
var
  LElement: IJSONElement;
begin
  LElement := FReader.Read(AJson);
  Result := T.Create;
  try
    if not FSerializer.ToObject(LElement, Result) then
      raise Exception.Create('Failed to deserialize JSON to object');
  except
    Result.Free;
    raise;
  end;
end;

class function TJsonFlow4D.JsonToObject<T>(const AObject: T; const AJson: String): Boolean;
begin
  Result := FSerializer.ToObject(FReader.Read(AJson), AObject);
end;

class function TJsonFlow4D.JsonToObjectList<T>(const AJson: String): TObjectList<T>;
var
  LElement: IJSONElement;
  LArray: IJSONArray;
  LFor: Integer;
  LObj: T;
begin
  Result := TObjectList<T>.Create(True);
  try
    LElement := FReader.Read(AJson);
    if not Supports(LElement, IJSONArray, LArray) then
      raise Exception.Create('JSON must be an array for object list');
    for LFor := 0 to LArray.Count - 1 do
    begin
      LObj := T.Create;
      try
        if FSerializer.ToObject(LArray.GetItem(LFor), LObj) then
          Result.Add(LObj)
        else
          LObj.Free;
      except
        LObj.Free;
        raise;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

class function TJsonFlow4D.JsonToObjectList(const AJson: String; const AType: TClass): TObjectList<TObject>;
var
  LElement: IJSONElement;
  LArray: IJSONArray;
  LFor: Integer;
  LObj: TObject;
begin
  Result := TObjectList<TObject>.Create(True);
  try
    LElement := FReader.Read(AJson);
    if not Supports(LElement, IJSONArray, LArray) then
      raise Exception.Create('JSON must be an array for object list');
    for LFor := 0 to LArray.Count - 1 do
    begin
      LObj := AType.Create;
      try
        if FSerializer.ToObject(LArray.GetItem(LFor), LObj) then
          Result.Add(LObj)
        else
          LObj.Free;
      except
        LObj.Free;
        raise;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

class procedure TJsonFlow4D.JsonToObject(const AJson: String; AObject: TObject);
begin
  if not FSerializer.ToObject(FReader.Read(AJson), AObject) then
    raise Exception.Create('Failed to deserialize JSON to object');
end;

class procedure TJsonFlow4D._SetFormatSettings(const Value: TFormatSettings);
begin
  if Assigned(FSerializer) then
    FSerializer.Free;
  if Assigned(FReader) then
    FReader.Free;
  if Assigned(FWriter) then
    FWriter.Free;
  FConverters := nil;

  FFormatSettings := Value;
  _Initialization;
end;

class function TJsonFlow4D.Parse(const AJson: String): IJSONElement;
begin
  Result := FReader.Read(AJson);
end;

class function TJsonFlow4D.ToJson(const AElement: IJSONElement; const AIdent: Boolean): String;
begin
  Result := FWriter.Write(AElement, AIdent);
end;

class function TJsonFlow4D.FromObject(AObject: TObject; AStoreClassName: Boolean): IJSONElement;
begin
  Result := FSerializer.FromObject(AObject, AStoreClassName);
end;

class function TJsonFlow4D.ToObject(const AElement: IJSONElement; AObject: TObject): Boolean;
begin
  Result := FSerializer.ToObject(AElement, AObject);
end;

class procedure TJsonFlow4D.OnLog(const ALogProc: TProc<String>);
begin
  if Assigned(ALogProc) then
  begin
    FSerializer.OnLog(ALogProc);
    FReader.OnLog(ALogProc);
    FWriter.OnLog(ALogProc);
  end;
end;

// Converter Methods Implementation

class function TJsonFlow4D.XMLToJSON(const AXML: string): string;
begin
  Result := FConverters.XMLToJSON(AXML);
end;

class function TJsonFlow4D.JSONToXML(const AJSON: string): string;
begin
  Result := FConverters.JSONToXML(AJSON);
end;

class function TJsonFlow4D.XMLToJSON(const AXML: string; const AOptions: string): string;
begin
  Result := FConverters.XMLToJSON(AXML, AOptions);
end;

class function TJsonFlow4D.JSONToXML(const AJSON: string; const AOptions: string): string;
begin
  Result := FConverters.JSONToXML(AJSON, AOptions);
end;

class function TJsonFlow4D.DataSetToJSON(ADataSet: TDataSet): string;
begin
  Result := FConverters.DataSetToJSON(ADataSet);
end;

class function TJsonFlow4D.JSONToDataSet(const AJSON: string; ADataSet: TDataSet): Boolean;
begin
  Result := FConverters.JSONToDataSet(AJSON, ADataSet);
end;

class function TJsonFlow4D.DataSetToJSON(ADataSet: TDataSet; const AOptions: string): string;
begin
  Result := FConverters.DataSetToJSON(ADataSet, AOptions);
end;

class function TJsonFlow4D.JSONToDataSet(const AJSON: string; ADataSet: TDataSet; const AOptions: string): Boolean;
begin
  Result := FConverters.JSONToDataSet(AJSON, ADataSet, AOptions);
end;

class function TJsonFlow4D.IsValidJSON(const AJSON: string): Boolean;
begin
  Result := FConverters.IsValidJSON(AJSON);
end;

class function TJsonFlow4D.IsValidXML(const AXML: string): Boolean;
begin
  Result := FConverters.IsValidXML(AXML);
end;

class function TJsonFlow4D.GetConverterLastError: string;
begin
  Result := FConverters.GetLastError;
end;

class procedure TJsonFlow4D.ClearConverterError;
begin
  FConverters.ClearError;
end;

class procedure TJsonFlow4D.ConfigureXMLConverter(const AConfig: string);
begin
  FConverters.ConfigureXMLConverter(AConfig);
end;

class procedure TJsonFlow4D.ConfigureDataSetConverter(const AConfig: string);
begin
  FConverters.ConfigureDataSetConverter(AConfig);
end;

class procedure TJsonFlow4D.ConfigureObjectConverter(const AConfig: string);
begin
  FConverters.ConfigureObjectConverter(AConfig);
end;

end.


