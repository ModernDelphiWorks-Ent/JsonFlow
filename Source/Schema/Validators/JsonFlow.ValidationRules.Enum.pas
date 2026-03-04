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
unit JsonFlow.ValidationRules.Enum;

interface

uses
  System.SysUtils, System.Classes,
  JsonFlow.Interfaces, JsonFlow.ValidationEngine,
  JsonFlow.ValidationRules.Base;

type
  // Regra de validação de enumeração
  TEnumRule = class(TBaseValidationRule)
  private
    FAllowedValues: TArray<string>;
  public
    constructor Create(const AAllowedValues: TArray<string>);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TEnumRule }

constructor TEnumRule.Create(const AAllowedValues: TArray<string>);
begin
  inherited Create('enum');
  FAllowedValues := AAllowedValues;
end;

function TEnumRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LValue: IJSONValue;
  LError: TValidationError;
  LValidationContext: TValidationContext;
  LValueStr: string;
  LAllowedValue: string;
begin
  LValidationContext := TValidationContext(AContext);
  
  if not Supports(AValue, IJSONValue, LValue) then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be a primitive for enum validation',
      'non-primitive',
      'primitive',
      'enum'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  // Converter valor para string para comparação
  if LValue.IsString then
    LValueStr := LValue.AsString
  else if LValue.IsInteger then
    LValueStr := IntToStr(LValue.AsInteger)
  else if LValue.IsFloat then
    LValueStr := FloatToStr(LValue.AsFloat)
  else if LValue.IsBoolean then
    LValueStr := BoolToStr(LValue.AsBoolean, True)
  else if LValue.IsNull then
    LValueStr := 'null'
  else
    LValueStr := 'unknown';

  // Verificar se o valor está na lista de valores permitidos
  for LAllowedValue in FAllowedValues do
  begin
    if LValueStr = LAllowedValue then
    begin
      Result := TValidationResult.Success(LValidationContext.GetFullPath);
      Exit;
    end;
  end;

  // Valor não encontrado na enumeração
  LError := CreateValidationError(
    LValidationContext.GetFullPath,
    Format('Value "%s" is not in the allowed enumeration', [LValueStr]),
    LValueStr,
    'one of: ' + string.Join(', ', FAllowedValues),
    'enum'
  );
  Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
end;

end.
