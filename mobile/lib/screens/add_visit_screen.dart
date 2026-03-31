import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mother_provider.dart';
import '../widgets/primary_button.dart';

class AddVisitScreen extends StatefulWidget {
  final String motherId;
  const AddVisitScreen({super.key, required this.motherId});
  @override
  State<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends State<AddVisitScreen> {
  final gestWeek = TextEditingController();
  final bp = TextEditingController(text: '120');
  final hb = TextEditingController(text: '12');
  final weight = TextEditingController(text: '60');
  final interval = TextEditingController();
  bool complications = false;
  bool busy = false;
  String? err;

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MotherProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Visit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          TextField(controller: gestWeek, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Gestational week')),
          const SizedBox(height: 12),
          TextField(controller: bp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'BP systolic')),
          const SizedBox(height: 12),
          TextField(controller: hb, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hemoglobin')),
          const SizedBox(height: 12),
          TextField(controller: weight, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight')),
          const SizedBox(height: 12),
          TextField(controller: interval, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pregnancy interval (months)')),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: complications,
            onChanged: (v) => setState(() => complications = v),
            title: const Text('Complications history'),
          ),
          if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Save & Evaluate Risk',
              busy: busy,
              onPressed: () async {
                setState(() { err = null; busy = true; });
                final payload = {
                  "gestWeek": int.tryParse(gestWeek.text) ?? 0,
                  "bpSystolic": int.tryParse(bp.text) ?? 120,
                  "hb": double.tryParse(hb.text) ?? 12.0,
                  "weight": double.tryParse(weight.text) ?? 60.0,
                  "pregnancyIntervalMonths": int.tryParse(interval.text),
                  "complicationsHistory": complications,
                };

                try {
                  final visit = await mp.addVisit(widget.motherId, payload);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Risk: ${visit["risk"]["level"]} (${visit["risk"]["score"]})')));
                } catch (_) {
                  await mp.offline.enqueueVisit(motherId: widget.motherId, visitPayload: payload);
                  await mp.refreshPendingCount();
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No connection. Visit saved offline (pending sync).')));
                } finally {
                  setState(() => busy = false);
                }
              },
            ),
          ),
        ]),
      ),
    );
  }
}
