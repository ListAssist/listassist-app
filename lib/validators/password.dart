import 'package:flutter/widgets.dart';

FormFieldValidator<String> PasswordRegisterValidator() {
  return (value) {
    if (value.isEmpty) {
      return "Bitte ein Passwort eingeben.";
    } else if (value.length < 6) {
      return "Das Passwort muss mindestens 6 Stellen lang sein.";
    } else {
      return null;
    }
  };
}

FormFieldValidator<String> PasswordValidator() => (value) => value.isEmpty ? "Bitte Ihr Passwort eingeben." : null;