import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/mother_provider.dart';
import 'register_mother_screen.dart';
import 'mother_profile_screen.dart';
import 'audit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MotherProvider>().fetchMothers());
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MotherProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthID Mama'),
        actions: [
          IconButton(
            tooltip: 'Sync now',
            icon: Stack(
              children: [
                const Icon(Icons.sync),
                if (mp.pendingCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                      child: Text('${mp.pendingCount}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  )
              ],
            ),
            onPressed: () async {
              final synced = await context.read<MotherProvider>().syncPendingVisits();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Synced $synced pending visits')));
            },
          ),
          IconButton(
            tooltip: 'Audit Logs',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AuditScreen())),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterMotherScreen())),
        icon: const Icon(Icons.person_add),
        label: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: search,
            decoration: InputDecoration(
              labelText: 'Search (name or token)',
              suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: () => mp.fetchMothers(search: search.text.trim())),
            ),
            onSubmitted: (_) => mp.fetchMothers(search: search.text.trim()),
          ),
          if (mp.pendingCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                const Icon(Icons.offline_bolt, size: 16),
                const SizedBox(width: 6),
                Text('Offline pending: ${mp.pendingCount} visits'),
              ]),
            ),
          const SizedBox(height: 12),
          if (mp.loading) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: mp.mothers.length,
              itemBuilder: (_, i) {
                final m = mp.mothers[i] as Map<String, dynamic>;
                return Card(
                  child: ListTile(
                    title: Text(m['fullName'] ?? ''),
                    subtitle: Text('${m['maternalToken'] ?? ''} • Region: ${m['region'] ?? ''}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MotherProfileScreen(motherId: m['id']))),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
