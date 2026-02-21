unit JsonFlow.FormatValidators;

// Unidade centralizada para registro de todos os validadores de formato
// Esta unidade substitui o registro manual no JsonFlow4D.FormatRegistry.pas

interface

// Procedimento principal para registrar todos os validadores built-in
procedure RegisterAllFormatValidators;

// Procedimentos individuais para registro seletivo
procedure RegisterBuiltInEmailValidator;
procedure RegisterBuiltInUriValidator;
procedure RegisterBuiltInDateValidator;
procedure RegisterBuiltInTimeValidator;
procedure RegisterBuiltInDateTimeValidator;
procedure RegisterBuiltInUuidValidator;
procedure RegisterBuiltInIpv4Validator;
procedure RegisterBuiltInIpv6Validator;

implementation

uses
  JsonFlow4D.FormatValidators.Email,
  JsonFlow4D.FormatValidators.Uri,
  JsonFlow4D.FormatValidators.Date,
  JsonFlow4D.FormatValidators.Time,
  JsonFlow4D.FormatValidators.DateTime,
  JsonFlow4D.FormatValidators.Uuid,
  JsonFlow4D.FormatValidators.Ipv4,
  JsonFlow4D.FormatValidators.Ipv6;

// Registra todos os validadores built-in
procedure RegisterAllFormatValidators;
begin
  RegisterBuiltInEmailValidator;
  RegisterBuiltInUriValidator;
  RegisterBuiltInDateValidator;
  RegisterBuiltInTimeValidator;
  RegisterBuiltInDateTimeValidator;
  RegisterBuiltInUuidValidator;
  RegisterBuiltInIpv4Validator;
  RegisterBuiltInIpv6Validator;
end;

// Procedimentos individuais para registro seletivo
procedure RegisterBuiltInEmailValidator;
begin
  JsonFlow4D.FormatValidators.Email.RegisterEmailValidator;
end;

procedure RegisterBuiltInUriValidator;
begin
  JsonFlow4D.FormatValidators.Uri.RegisterUriValidator;
end;

procedure RegisterBuiltInDateValidator;
begin
  JsonFlow4D.FormatValidators.Date.RegisterDateValidator;
end;

procedure RegisterBuiltInTimeValidator;
begin
  JsonFlow4D.FormatValidators.Time.RegisterTimeValidator;
end;

procedure RegisterBuiltInDateTimeValidator;
begin
  JsonFlow4D.FormatValidators.DateTime.RegisterDateTimeValidator;
end;

procedure RegisterBuiltInUuidValidator;
begin
  JsonFlow4D.FormatValidators.Uuid.RegisterUuidValidator;
end;

procedure RegisterBuiltInIpv4Validator;
begin
  JsonFlow4D.FormatValidators.Ipv4.RegisterIpv4Validator;
end;

procedure RegisterBuiltInIpv6Validator;
begin
  JsonFlow4D.FormatValidators.Ipv6.RegisterIpv6Validator;
end;

end.