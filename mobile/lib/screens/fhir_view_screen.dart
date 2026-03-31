import 'dart:convert';
import 'package:flutter/material.dart';

class FhirViewScreen extends StatelessWidget {
  final Map<String, dynamic> bundle;
  const FhirViewScreen({super.key, required this.bundle});

  @override
  Widget build(BuildContext context) {
    final pretty = const JsonEncoder.withIndent('  ').convert(bundle);

    return Scaffold(
      appBar: AppBar(title: const Text('FHIR Export (Bundle)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectableText(pretty),
      ),
    );
  }
}
