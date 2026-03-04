{
  ------------------------------------------------------------------------------
  JsonFlow
  Fluent and expressive JSON manipulation API for Delphi.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ../../../JsonFlow.inc}
unit JsonFlow.FormatValidators.Uri;

interface

uses
  System.SysUtils,
  System.RegularExpressions,
  JsonFlow.FormatValidators.Base;

type
  TUriFormatValidator = class(TBaseFormatValidatorPlugin)
  protected
    function DoValidate(const AValue: string): Boolean; override;
    function GetCustomErrorMessage(const AValue: string): string; override;
  public
    constructor Create;
  end;

  // Função para registrar o validador
  procedure RegisterUriValidator;

implementation

uses
  JsonFlow.FormatRegistry;

{ TUriFormatValidator }

constructor TUriFormatValidator.Create;
begin
  inherited Create('uri', 'String does not match URI format');
end;

function TUriFormatValidator.DoValidate(const AValue: string): Boolean;
var
  LRegex: TRegEx;
begin
  if AValue.IsEmpty then
  begin
    Result := False;
    Exit;
  end;
  
  // Regex mais abrangente para URIs (http, https, ftp, etc.)
  LRegex := TRegEx.Create('^(https?|ftp)://[^\s/$.?#].[^\s]*$', [roIgnoreCase]);
  Result := LRegex.IsMatch(AValue);
end;

function TUriFormatValidator.GetCustomErrorMessage(const AValue: string): string;
begin
  if AValue.IsEmpty then
    Result := 'URI cannot be empty'
  else if not (AValue.StartsWith('http://') or AValue.StartsWith('https://') or AValue.StartsWith('ftp://')) then
    Result := 'URI must start with a valid scheme (http://, https://, ftp://)'
  else
    Result := Format('String "%s" is not a valid URI format', [AValue]);
end;

// Função para registrar o validador
procedure RegisterUriValidator;
begin
  TFormatRegistry.RegisterValidator('uri', TUriFormatValidator.Create);
end;

end.
