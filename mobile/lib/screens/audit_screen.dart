import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mother_provider.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});
  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  List<dynamic>? logs;
  String? err;

  Future<void> load() async {
    setState(() { logs = null; err = null; });
    try {
      logs = await context.read<MotherProvider>().fetchAudit();
      setState(() {});
    } catch (_) {
      setState(() => err = 'Failed to load audit logs');
    }
  }

  @override
  void initState() { super.initState(); Future.microtask(load); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Logs')),
      body: err != null
          ? Center(child: Text(err!))
          : logs == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: logs!.map((l) {
                    final m = l as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text('${m["action"]} • ${m["entity_type"]}'),
                        subtitle: Text(m["timestamp"]?.toString() ?? ''),
                      ),
                    );
                  }).toList(),
                ),
    );
  }
}
