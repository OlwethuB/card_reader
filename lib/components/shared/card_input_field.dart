import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final IconData prefixIcon;
  final bool readOnly;
  final bool enabled;
  final String? initialValue;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final void Function(String)? onChanged;
  final bool obscureText;

  const CardInputField({
    super.key,
    this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.readOnly = false,
    this.enabled = true,
    this.initialValue,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      readOnly: readOnly,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        border: const OutlineInputBorder(),
        counterText: maxLength != null ? '' : null,
      ),
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      onChanged: onChanged,
      obscureText: obscureText,
    );
  }
}