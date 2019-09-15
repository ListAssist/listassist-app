import 'package:flutter/widgets.dart';

FormFieldValidator<String> UsernameValidator() => (value) => value.isEmpty ? "Bitte einen Usernamen eingeben." : null;