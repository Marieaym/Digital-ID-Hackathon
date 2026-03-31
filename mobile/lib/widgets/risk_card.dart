import 'package:flutter/material.dart';

class RiskCard extends StatelessWidget {
  final Map<String, dynamic> risk;
  const RiskCard({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final level = (risk['level'] ?? 'UNKNOWN').toString();
    final score = (risk['score'] ?? '-').toString();
    final reasons = (risk['reasons'] as List?)?.map((e) => e.toString()).toList() ?? const [];
    final recs = (risk['recommendations'] as List?)?.map((e) => e.toString()).toList() ?? const [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Risk: $level • Score: $score', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text('Reasons', style: TextStyle(fontWeight: FontWeight.w600)),
          ...reasons.map((r) => Text('• $r')),
          const SizedBox(height: 8),
          const Text('Recommendations', style: TextStyle(fontWeight: FontWeight.w600)),
          ...recs.map((r) => Text('• $r')),
        ]),
      ),
    );
  }
}
