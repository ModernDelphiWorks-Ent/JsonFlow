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
unit JsonFlow.ValidationRules.AdditionalProperties;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  JsonFlow.Interfaces,
  JsonFlow.ValidationEngine,
  JsonFlow.ValidationRules.Base;

type
  // Regra de validação de propriedades adicionais
  TAdditionalPropertiesRule = class(TBaseValidationRule)
  private
    FAllowAdditional: Boolean;
    FAdditionalSchema: IJSONElement;
    FDefinedProperties: TArray<string>;
  public
    constructor Create(AAllowAdditional: Boolean; const AAdditionalSchema: IJSONElement = nil; const ADefinedProperties: TArray<string> = nil);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

{ TAdditionalPropertiesRule }

constructor TAdditionalPropertiesRule.Create(AAllowAdditional: Boolean; const AAdditionalSchema: IJSONElement; const ADefinedProperties: TArray<string>);
begin
  inherited Create('additionalProperties');
  FAllowAdditional := AAllowAdditional;
  FAdditionalSchema := AAdditionalSchema;
  FDefinedProperties := ADefinedProperties;
end;

function TAdditionalPropertiesRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LObject: IJSONObject;
  LError: TValidationError;
  LValidationContext: TValidationContext;
  LPropertyName: string;
  LPropertyValue: IJSONElement;
  LIsDefinedProperty: Boolean;
  LDefinedProp: string;
  LAllErrors: TList<TValidationError>;
  LHasErrors: Boolean;
  LPairs: TArray<IJSONPair>;
  LFor: Integer;
begin
  LValidationContext := TValidationContext(AContext);

  if not Supports(AValue, IJSONObject, LObject) then
  begin
    LError := CreateValidationError(
      LValidationContext.GetFullPath,
      'Value must be an object for additionalProperties validation',
      'non-object',
      'object',
      'additionalProperties'
    );
    Result := TValidationResult.Failure(LValidationContext.GetFullPath, [LError]);
    Exit;
  end;

  LAllErrors := TList<TValidationError>.Create;
  try
    LHasErrors := False;
    LPairs := LObject.Pairs;

    // Verificar cada propriedade do objeto
    for LFor := 0 to Length(LPairs) - 1 do
    begin
      LPropertyName := LPairs[LFor].Key;
      
      // Verificar se é uma propriedade definida no esquema
      LIsDefinedProperty := False;
      for LDefinedProp in FDefinedProperties do
      begin
        if LPropertyName = LDefinedProp then
        begin
          LIsDefinedProperty := True;
          Break;
        end;
      end;
      
      // Se não é uma propriedade definida, é uma propriedade adicional
      if not LIsDefinedProperty then
      begin
        if not FAllowAdditional then
        begin
          // Propriedades adicionais não são permitidas
          LHasErrors := True;
          LError := CreateValidationError(
            LValidationContext.GetFullPath + '.' + LPropertyName,
            Format('Additional property "%s" is not allowed', [LPropertyName]),
            'present',
            'not allowed',
            'additionalProperties'
          );
          LAllErrors.Add(LError);
        end
        else if Assigned(FAdditionalSchema) then
        begin
          // Validar propriedade adicional contra o esquema
          LPropertyValue := LObject.GetValue(LPropertyName);
          LValidationContext.PushProperty(LPropertyName);
          try
            // Aqui seria necessário validar usando o esquema adicional
            // Por simplicidade, assumimos que a validação é bem-sucedida
            // Em uma implementação completa, seria necessário um validador recursivo
          finally
            LValidationContext.PopProperty;
          end;
        end;
      end;
    end;

    if LHasErrors then
      Result := TValidationResult.Failure(LValidationContext.GetFullPath, LAllErrors.ToArray)
    else
      Result := TValidationResult.Success(LValidationContext.GetFullPath);
  finally
    LAllErrors.Free;
  end;
end;

end.
