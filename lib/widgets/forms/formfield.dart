
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Custom TextInput widget for easier "reactive" forms creation
class ReactiveTextInputFormField extends StatefulWidget {
  final FormFieldValidator<String> validator;
  final String hintText;
  final Icon icon;
  final FormFieldSetter<String> onSaved;

  final bool obscureText;
  final ValueChanged<String> onFieldSubmitted;
  final TextInputType keyboardType;
  final FocusNode focusNode;
  final TextEditingController controller;


  ReactiveTextInputFormField({
    Key key,
    @required this.validator,
    @required this.hintText,
    @required this.icon,
    @required this.onSaved,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.keyboardType,
    this.focusNode,
    this.controller,
  }): super(key: key);

  @override
  _ReactiveTextInputFormFieldState createState() => _ReactiveTextInputFormFieldState();
}

class _ReactiveTextInputFormFieldState extends State<ReactiveTextInputFormField> {
  final _fieldKey = GlobalKey<FormFieldState>();
  bool _interacted = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: _fieldKey,
      controller: widget.controller,
      autovalidate: _interacted,
      onFieldSubmitted: widget.onFieldSubmitted,
      maxLines: 1,
      obscureText: widget.obscureText,
      validator: widget.validator,
      onSaved: widget.onSaved,
      keyboardType: widget.keyboardType,
      onChanged: (str) => setState(() => _interacted = true),
      decoration: InputDecoration(
          hintText: widget.hintText,
          icon: widget.icon
      ),
      focusNode: widget.focusNode,
    );
  }
}
