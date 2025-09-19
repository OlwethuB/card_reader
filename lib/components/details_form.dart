import 'package:flutter/material.dart';

class DetailsForm extends StatefulWidget {
  const DetailsForm({super.key});

  @override
  State<DetailsForm> createState() => _DetailsFormState();
}

class _DetailsFormState extends State<DetailsForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 18.0,
          children: [
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Enter the Card Number'),
              validator: (cardNumber) {
                if (cardNumber == null || cardNumber.isEmpty) {
                  return 'Please enter a valid card number.';
                }
                return null;
              },
            ),
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Enter the Card Type'),
              validator: (cardType) {
                if (cardType == null || cardType.isEmpty) {
                  return 'Please enter a valid card type.';
                }
                return null;
              },
            ),
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(labelText: 'Enter the Card CVV'),
              validator: (cardCVV) {
                if (cardCVV == null || cardCVV.isEmpty) {
                  return 'Please enter a valid card CVV.';
                }
                return null;
              },
            ),
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter the Issuing Country',
              ),
              validator: (issueCountry) {
                if (issueCountry == null || issueCountry.isEmpty) {
                  return 'Please enter the Issuing Country.';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 16.0,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process data
                    }
                  },
                  child: Text('Submit'),
                ),

                ElevatedButton(
                  onPressed: () {
                    _formKey.currentState!.reset();
                  },
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
