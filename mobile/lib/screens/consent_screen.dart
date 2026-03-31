import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../widgets/primary_button.dart';

class ConsentResult {
  final Map<String, dynamic> consentJson;
  ConsentResult(this.consentJson);
}

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  final signer = TextEditingController();
  String language = 'fr';
  bool agreed = false;
  String? err;

  final SignatureController sig = SignatureController(
    penStrokeWidth: 3,
  );

  @override
  void dispose() {
    signer.dispose();
    sig.dispose();
    super.dispose();
  }

  String _consentText(String lang) {
    if (lang == 'ha') {
      return "Na amince a yi amfani da bayanaina don kula da lafiyar ciki da haihuwa. Ana kiyaye sirri kuma ba a sayar da bayanai.";
    }
    if (lang == 'en') {
      return "I consent to the use of my data for maternal care. Privacy is protected and data is not sold.";
    }
    return "Je consens à l’utilisation de mes données pour le suivi maternel. La confidentialité est protégée et les données ne sont pas commercialisées.";
  }

  @override
  Widget build(BuildContext context) {
    final ts = DateTime.now().toIso8601String();

    return Scaffold(
      appBar: AppBar(title: const Text('Consentement / Consent')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Langue', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField(
              value: language,
              items: const [
                DropdownMenuItem(value: 'fr', child: Text('Français')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ha', child: Text('Hausa (demo)')),
              ],
              onChanged: (v) => setState(() => language = v.toString()),
            ),
            const SizedBox(height: 16),

            Text(_consentText(language)),
            const SizedBox(height: 8),
            Text('Timestamp: $ts', style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 12),

            TextField(controller: signer, decoration: const InputDecoration(labelText: 'Signed by (name)')),
            const SizedBox(height: 12),

            const Text('Signature', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Signature(
                controller: sig,
                backgroundColor: Colors.white,
              ),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => sig.clear(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: agreed,
              onChanged: (v) => setState(() => agreed = v ?? false),
              title: const Text('I agree / J’accepte'),
            ),

            if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Continue',
                onPressed: () async {
                  setState(() => err = null);

                  if (!agreed) {
                    setState(() => err = 'Consent is required.');
                    return;
                  }
                  if (signer.text.trim().isEmpty) {
                    setState(() => err = 'Signer name is required.');
                    return;
                  }
                  if (sig.isEmpty) {
                    setState(() => err = 'Signature is required.');
                    return;
                  }

                  final pngBytes = await sig.toPngBytes();
                  final sigB64 = base64Encode(pngBytes!);

                  final consentJson = {
                    "language": language,
                    "timestamp": ts,
                    "signedBy": signer.text.trim(),
                    "signaturePngBase64": sigB64,
                    "text": _consentText(language),
                  };

                  if (!mounted) return;
                  Navigator.pop(context, ConsentResult(consentJson));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
