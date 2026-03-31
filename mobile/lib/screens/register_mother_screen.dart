import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mother_provider.dart';
import '../widgets/primary_button.dart';
import 'consent_screen.dart';

class RegisterMotherScreen extends StatefulWidget {
  const RegisterMotherScreen({super.key});
  @override
  State<RegisterMotherScreen> createState() => _RegisterMotherScreenState();
}

class _RegisterMotherScreenState extends State<RegisterMotherScreen> {
  final name = TextEditingController();
  final age = TextEditingController();
  final phone = TextEditingController();
  final region = TextEditingController();
  final nationalId = TextEditingController();

  Map<String, dynamic>? consentJson;
  bool busy = false;
  String? err;

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MotherProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Register Mother')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Full name')),
          const SizedBox(height: 12),
          TextField(controller: age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age')),
          const SizedBox(height: 12),
          TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone')),
          const SizedBox(height: 12),
          TextField(controller: region, decoration: const InputDecoration(labelText: 'Region')),
          const SizedBox(height: 12),
          TextField(controller: nationalId, decoration: const InputDecoration(labelText: 'National ID (optional)')),
          const SizedBox(height: 12),

          Card(
            child: ListTile(
              title: const Text('Consent'),
              subtitle: Text(consentJson == null ? 'Not collected yet' : 'Collected (${consentJson!["language"]})'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsentScreen()));
                if (result is ConsentResult) {
                  setState(() => consentJson = result.consentJson);
                }
              },
            ),
          ),

          if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Create mother',
              busy: busy,
              onPressed: () async {
                setState(() { err = null; });
                if (consentJson == null) {
                  setState(() => err = 'Consent must be collected before registration.');
                  return;
                }

                setState(() => busy = true);
                try {
                  final created = await mp.createMother({
                    "fullName": name.text.trim(),
                    "age": int.tryParse(age.text) ?? 0,
                    "phone": phone.text.trim(),
                    "region": region.text.trim(),
                    "nationalId": nationalId.text.trim().isEmpty ? null : nationalId.text.trim(),
                    "consentJson": consentJson,
                  });
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Created ${created["maternalToken"] ?? created["maternal_token"] ?? "OK"}')));
                } catch (_) {
                  setState(() => err = 'Failed to create mother. Check backend / consentJson.');
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
