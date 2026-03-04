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
unit JsonFlow.ValidationRules.Base;

interface

uses
  System.SysUtils,
  System.Classes,
  JsonFlow.Interfaces,
  JsonFlow.ValidationEngine;

type
  // Regra base para todas as regras de validação
  TBaseValidationRule = class(TInterfacedObject, IValidationRule)
  protected
    FKeyword: string;
  public
    constructor Create(const AKeyword: string);
    function GetRuleType: TRuleType; virtual;
    function GetKeyword: string;
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; virtual; abstract;
  end;

implementation

{ TBaseValidationRule }

constructor TBaseValidationRule.Create(const AKeyword: string);
begin
  inherited Create;
  FKeyword := AKeyword;
end;

function TBaseValidationRule.GetRuleType: TRuleType;
begin
  Result := rtPrimitive;
end;

function TBaseValidationRule.GetKeyword: string;
begin
  Result := FKeyword;
end;

end.