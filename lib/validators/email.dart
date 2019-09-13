import 'package:flutter/widgets.dart';

FormFieldValidator<String> EmailValidator() {
  final RegExp emailValidatorRegExp = RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");

  return (value) {
    if (value.isEmpty) {
      return "Bitte eine E-Mail eingeben.";
    } else if (!emailValidatorRegExp.hasMatch(value)) {
      return "Bitte gültige E-Mail eingeben.";
    } else {
      return null;
    }
  };
}
