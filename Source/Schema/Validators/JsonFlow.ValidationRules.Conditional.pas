unit JsonFlow.ValidationRules.Conditional;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  JsonFlow4D.Interfaces, JsonFlow4D.ValidationEngine,
  JsonFlow4D.ValidationRules.Base,
  JsonFlow4D.ValidationRules.Required,
  JsonFlow4D.ValidationRules.Properties,
  JsonFlow4D.ValidationRules.MinLength,
  JsonFlow4D.ValidationRules.MaxLength,
  JsonFlow4D.ValidationRules.Minimum,
  JsonFlow4D.ValidationRules.Maximum,
  JsonFlow4D.ValidationRules.Consts;

type
  // Regra de validação condicional if/then/else
  TConditionalRule = class(TBaseValidationRule)
  private
    FIfSchema: IJSONElement;
    FThenSchema: IJSONElement;
    FElseSchema: IJSONElement;
    function ValidateAgainstSchema(const AValue: IJSONElement; const ASchema: IJSONElement; const AContext: TValidationContext): TValidationResult;
  public
    constructor Create(const AIfSchema: IJSONElement; const AThenSchema: IJSONElement = nil; const AElseSchema: IJSONElement = nil);
    function Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult; override;
  end;

implementation

uses
  JsonFlow4D.ValidationRules.Types;

{ TConditionalRule }

constructor TConditionalRule.Create(const AIfSchema: IJSONElement; const AThenSchema: IJSONElement; const AElseSchema: IJSONElement);
begin
  inherited Create('if');
  FIfSchema := AIfSchema;
  FThenSchema := AThenSchema;
  FElseSchema := AElseSchema;
end;

function TConditionalRule.ValidateAgainstSchema(const AValue: IJSONElement; const ASchema: IJSONElement; const AContext: TValidationContext): TValidationResult;
var
  LSchemaObj: IJSONObject;
  LTypeValue: string;
  LRule: IValidationRule;
  LResult: TValidationResult;
  LErrors: TList<TValidationError>;
  LPropertiesObj: IJSONObject;
  LPropertySchemas: TDictionary<string, IJSONElement>;
  LPair: IJSONPair;
  LRequiredArray: IJSONArray;
  LConstValue: IJSONValue;
  LMinValue, LMaxValue: Double;
  LMinLength, LMaxLength: Integer;
  LFor: Integer;
  LRequiredFields: TArray<string>;
begin
  if not Assigned(ASchema) then
  begin
    Result := TValidationResult.Success(AContext.GetFullPath);
    Exit;
  end;

  if not Supports(ASchema, IJSONObject, LSchemaObj) then
  begin
    Result := TValidationResult.Success(AContext.GetFullPath);
    Exit;
  end;

  LErrors := TList<TValidationError>.Create;
  try
    // Validate type
    if LSchemaObj.ContainsKey('type') then
    begin
      LTypeValue := (LSchemaObj.GetValue('type') as IJSONValue).AsString;
      LRule := TTypeRule.Create(LTypeValue);
      try
        LResult := LRule.Validate(AValue, AContext);
        if not LResult.IsValid then
          LErrors.AddRange(LResult.Errors);
      finally
        LRule := nil;
      end;
    end;

    // Validate const
    if LSchemaObj.ContainsKey('const') then
    begin
      LConstValue := LSchemaObj.GetValue('const') as IJSONValue;
      LRule := TConstRule.Create(LConstValue.AsString);
      try
        LResult := LRule.Validate(AValue, AContext);
        if not LResult.IsValid then
          LErrors.AddRange(LResult.Errors);
      finally
        LRule := nil;
      end;
    end;

    // Validate required (for objects)
    if LSchemaObj.ContainsKey('required') and Supports(AValue, IJSONObject) then
    begin
      LRequiredArray := LSchemaObj.GetValue('required') as IJSONArray;
      SetLength(LRequiredFields, LRequiredArray.Count);
      for LFor := 0 to LRequiredArray.Count - 1 do
        LRequiredFields[LFor] := (LRequiredArray.GetItem(LFor) as IJSONValue).AsString;
      
      LRule := TRequiredRule.Create(LRequiredFields);
      try
        LResult := LRule.Validate(AValue, AContext);
        if not LResult.IsValid then
          LErrors.AddRange(LResult.Errors);
      finally
        LRule := nil;
      end;
    end;
    
    // Validate properties (for objects) - special handling for conditional validation
    if LSchemaObj.ContainsKey('properties') and Supports(AValue, IJSONObject) then
    begin
      LPropertiesObj := LSchemaObj.GetValue('properties') as IJSONObject;
      
      // For conditional validation, we need to check each property individually
      // and fail if any property doesn't exist or doesn't match its schema
      for LPair in LPropertiesObj.Pairs do
      begin
        if not (AValue as IJSONObject).ContainsKey(LPair.Key) then
        begin
          // Property doesn't exist - this should fail the condition
          LErrors.Add(CreateValidationError(
            AContext.GetFullPath,
            Format('Property "%s" is required for conditional validation', [LPair.Key]),
            'missing',
            'present',
            'properties'
          ));
        end
        else
        begin
          // Property exists - validate it against its schema
          var LPropertyValue := (AValue as IJSONObject).GetValue(LPair.Key);
          var LPropertySchema := LPair.Value;
          
          // Handle const validation directly
          if Supports(LPropertySchema, IJSONObject) and 
             (LPropertySchema as IJSONObject).ContainsKey('const') then
          begin
            var LPropertyConstValue := ((LPropertySchema as IJSONObject).GetValue('const') as IJSONValue);
            LRule := TConstRule.Create(LPropertyConstValue.AsString);
            try
              LResult := LRule.Validate(LPropertyValue, AContext);
              if not LResult.IsValid then
                LErrors.AddRange(LResult.Errors);
            finally
              LRule := nil;
            end;
          end;
        end;
      end;
    end;
    
    // Validate minLength/maxLength (for strings)
    if Supports(AValue, IJSONValue) and (AValue as IJSONValue).IsString then
    begin
      if LSchemaObj.ContainsKey('minLength') then
      begin
        LMinLength := Trunc((LSchemaObj.GetValue('minLength') as IJSONValue).AsFloat);
        LRule := TMinLengthRule.Create(LMinLength);
        try
          LResult := LRule.Validate(AValue, AContext);
          if not LResult.IsValid then
            LErrors.AddRange(LResult.Errors);
        finally
          LRule := nil;
        end;
      end;
      
      if LSchemaObj.ContainsKey('maxLength') then
      begin
        LMaxLength := Trunc((LSchemaObj.GetValue('maxLength') as IJSONValue).AsFloat);
        LRule := TMaxLengthRule.Create(LMaxLength);
        try
          LResult := LRule.Validate(AValue, AContext);
          if not LResult.IsValid then
            LErrors.AddRange(LResult.Errors);
        finally
          LRule := nil;
        end;
      end;
    end;
    
    // Validate minimum/maximum (for numbers)
    if Supports(AValue, IJSONValue) and ((AValue as IJSONValue).IsFloat or (AValue as IJSONValue).IsInteger) then
    begin
      if LSchemaObj.ContainsKey('minimum') then
      begin
        LMinValue := (LSchemaObj.GetValue('minimum') as IJSONValue).AsFloat;
        LRule := TMinimumRule.Create(LMinValue);
        try
          LResult := LRule.Validate(AValue, AContext);
          if not LResult.IsValid then
            LErrors.AddRange(LResult.Errors);
        finally
          LRule := nil;
        end;
      end;
      
      if LSchemaObj.ContainsKey('maximum') then
      begin
        LMaxValue := (LSchemaObj.GetValue('maximum') as IJSONValue).AsFloat;
        LRule := TMaximumRule.Create(LMaxValue);
        try
          LResult := LRule.Validate(AValue, AContext);
          if not LResult.IsValid then
            LErrors.AddRange(LResult.Errors);
        finally
          LRule := nil;
        end;
      end;
    end;
    
    // Return result
    if LErrors.Count = 0 then
      Result := TValidationResult.Success(AContext.GetFullPath)
    else
      Result := TValidationResult.Failure(AContext.GetFullPath, LErrors.ToArray);
      
  finally
    LErrors.Free;
  end;
end;

function TConditionalRule.Validate(const AValue: IJSONElement; const AContext: TObject): TValidationResult;
var
  LValidationContext: TValidationContext;
  LIfResult: TValidationResult;
  LThenResult: TValidationResult;
  LElseResult: TValidationResult;
begin
  LValidationContext := TValidationContext(AContext);
  
  // Avaliar a condição 'if'
  LIfResult := ValidateAgainstSchema(AValue, FIfSchema, LValidationContext);
  
  if LIfResult.IsValid then
  begin
    // Se 'if' é válido, aplicar 'then' se existir
    if Assigned(FThenSchema) then
    begin
      LThenResult := ValidateAgainstSchema(AValue, FThenSchema, LValidationContext);
      Result := LThenResult;
    end
    else
    begin
      // Se não há 'then', considera válido
      Result := TValidationResult.Success(LValidationContext.GetFullPath);
    end;
  end
  else
  begin
    // Se 'if' é inválido, aplicar 'else' se existir
    if Assigned(FElseSchema) then
    begin
      LElseResult := ValidateAgainstSchema(AValue, FElseSchema, LValidationContext);
      Result := LElseResult;
    end
    else
    begin
      // Se não há 'else', considera válido
      Result := TValidationResult.Success(LValidationContext.GetFullPath);
    end;
  end;
end;

end.