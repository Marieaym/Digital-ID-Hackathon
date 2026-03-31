import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final u = TextEditingController(text: 'agent1');
  final p = TextEditingController(text: 'pass123');
  String? err;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('HealthID Mama — Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: u, decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 12),
          TextField(controller: p, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 12),
          if (err != null) Text(err!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Login',
              busy: auth.loading,
              onPressed: () async {
                setState(() => err = null);
                try {
                  await context.read<AuthProvider>().login(u.text.trim(), p.text);
                } catch (_) {
                  setState(() => err = 'Login failed. Check credentials.');
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          const Text('Demo accounts: agent1/pass123 • admin1/pass123', style: TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }
}
