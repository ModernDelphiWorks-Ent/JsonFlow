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
unit JsonFlow.ValidationRules.Pattern;

interface

uses
  System.SysUtils, System.Classes, System.RegularExpressions,
  JsonFlow.Interfaces, JsonFlow.ValidationEngine,
  JsonFlow.ValidationRules.Base;

type
  // Regra de validação de padrão (regex)
  TPatternRule = class(TBaseValidationRule)
  private
    FPattern: string;
  public
    constructor Create(const APattern: string);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TPatternRule }

constructor TPatternRule.Create(const APattern: string);
begin
  inherited Create('pattern');
  FPattern := APattern;
end;

function TPatternRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LValue: IJSONValue;
  LError: TValidationError;
  LValidationContext: TValidationContext;
  LRegex: TRegEx;
begin
  LValidationContext := TValidationContext(AContext);
  
  if not Supports(AValue, IJSONValue, LValue) then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be a string for pattern validation',
      'non-string',
      'string',
      'pattern'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  if not LValue.IsString then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be a string for pattern validation',
      'non-string',
      'string',
      'pattern'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  try
    LRegex := TRegEx.Create(FPattern);
    if LRegex.IsMatch(LValue.AsString) then
      Result := TValidationResult.Success(LValidationContext.GetFullPath)
    else
    begin
      LError := CreateValidationError(
        LValidationContext.GetFullPath,
        Format('String "%s" does not match pattern "%s"', [LValue.AsString, FPattern]),
        LValue.AsString,
        FPattern,
        'pattern'
      );
      Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    end;
  except
    on E: Exception do
    begin
      LError := CreateValidationError(
        LValidationContext.GetFullPath,
        Format('Invalid regex pattern "%s": %s', [FPattern, E.Message]),
        FPattern,
        'valid regex',
        'pattern'
      );
      Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    end;
  end;
end;

end.
