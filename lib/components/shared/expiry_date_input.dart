import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpiryDateInput extends StatelessWidget {
  final TextEditingController monthController;
  final TextEditingController yearController;
  final String? Function(String?)? monthValidator;
  final String? Function(String?)? yearValidator;

  const ExpiryDateInput({
    super.key,
    required this.monthController,
    required this.yearController,
    this.monthValidator,
    this.yearValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: monthController,
            decoration: const InputDecoration(
              labelText: 'MM',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            validator: monthValidator,
          ),
        ),
        const SizedBox(width: 8),
        const Text('/', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: yearController,
            decoration: const InputDecoration(
              labelText: 'YYYY',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            validator: yearValidator,
          ),
        ),
      ],
    );
  }
}