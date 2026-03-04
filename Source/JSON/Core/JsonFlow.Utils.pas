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

{$include ../../JsonFlow.inc}

unit JsonFlow.Utils;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.DateUtils;

function DateTimeToIso8601(const AValue: TDateTime; const AUseISO8601DateFormat: Boolean): String;
function Iso8601ToDateTime(const AValue: String; const AUseISO8601DateFormat: Boolean): TDateTime;

var
  JsonFormatSettings: TFormatSettings;

implementation

function DateTimeToIso8601(const AValue: TDateTime; const AUseISO8601DateFormat: Boolean): String;
var
  LDatePart: String;
  LTimePart: String;
begin
  Result := '';
  if AValue = 0 then
    Exit;

  if AUseISO8601DateFormat then
    LDatePart := FormatDateTime('yyyy-mm-dd', AValue)
  else
    LDatePart := DateToStr(AValue, JsonFormatSettings);

  if Frac(AValue) = 0 then
    Result := IfThen(AUseISO8601DateFormat, LDatePart, DateToStr(AValue, JsonFormatSettings))
  else
  begin
    LTimePart := FormatDateTime('hh:nn:ss', AValue);
    Result := IfThen(AUseISO8601DateFormat, LDatePart + 'T' + LTimePart, LDatePart + ' ' + LTimePart);
  end;
end;

function Iso8601ToDateTime(const AValue: String; const AUseISO8601DateFormat: Boolean): TDateTime;
begin
  if not AUseISO8601DateFormat then
  begin
    Result := StrToDateTimeDef(AValue, 0, JsonFormatSettings);
  end
  else
  begin
    try
      Result := ISO8601ToDate(AValue, True);
    except
      on E: EConvertError do
        Result := 0;
    end;
  end;
end;

initialization
  JsonFormatSettings := TFormatSettings.Create('en-US');
  JsonFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  JsonFormatSettings.DateSeparator := '-';
  JsonFormatSettings.TimeSeparator := ':';
  JsonFormatSettings.DecimalSeparator := '.';

end.
