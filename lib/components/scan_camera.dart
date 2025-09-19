import 'package:flutter/material.dart';

class ScanCamera extends StatefulWidget {
  const ScanCamera({super.key});

  @override
  State<ScanCamera> createState() => _ScanCameraState();
}

class _ScanCameraState extends State<ScanCamera> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //IconButton
        IconButton(
          icon: const Icon(Icons.camera),
          tooltip: 'Setting Icon',
          onPressed: () {},
        ), 
      ],
    );
  }
}