import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mother_provider.dart';
import '../widgets/risk_card.dart';
import 'add_visit_screen.dart';
import 'fhir_view_screen.dart';

class MotherProfileScreen extends StatefulWidget {
  final String motherId;
  const MotherProfileScreen({super.key, required this.motherId});

  @override
  State<MotherProfileScreen> createState() => _MotherProfileScreenState();
}

class _MotherProfileScreenState extends State<MotherProfileScreen> {
  Map<String, dynamic>? data;
  List<Map<String, dynamic>> pendingVisits = [];
  String? err;

  Future<void> load() async {
    setState(() { err = null; data = null; });
    try {
      final mp = context.read<MotherProvider>();
      final m = await mp.getMother(widget.motherId);
      final pv = await mp.offline.getPendingVisitsForMother(widget.motherId);
      setState(() { data = m; pendingVisits = pv; });
    } catch (_) {
      setState(() => err = 'Failed to load profile');
    }
  }

  @override
  void initState() { super.initState(); Future.microtask(load); }

  @override
  Widget build(BuildContext context) {
    final d = data;

    return Scaffold(
      appBar: AppBar(
        title: Text(d?['maternalToken'] ?? 'Mother Profile'),
        actions: [
          IconButton(
            tooltip: 'Export FHIR',
            icon: const Icon(Icons.data_object),
            onPressed: d == null ? null : () async {
              final bundle = await context.read<MotherProvider>().fetchFhir(widget.motherId);
              if (!context.mounted) return;
              Navigator.push(context, MaterialPageRoute(builder: (_) => FhirViewScreen(bundle: bundle)));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => AddVisitScreen(motherId: widget.motherId)));
          await load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add visit'),
      ),
      body: err != null
          ? Center(child: Text(err!))
          : d == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(d['fullName'] ?? '', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('Age: ${d["age"]} • Region: ${d["region"]}'),
                    const SizedBox(height: 12),

                    if ((d['visits'] as List).isNotEmpty)
                      RiskCard(risk: ((d['visits'] as List).last as Map<String, dynamic>)['risk']),

                    if (pendingVisits.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        const Text('Pending (Offline)', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                          child: Text('${pendingVisits.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      ...pendingVisits.map((pv) {
                        final payload = Map<String, dynamic>.from(pv["payload"] as Map);
                        return Card(
                          child: ListTile(
                            title: Text('BP ${payload["bpSystolic"]} • Hb ${payload["hb"]} • GW ${payload["gestWeek"]}'),
                            subtitle: Text('Saved offline • ${pv["createdAt"] ?? ""}'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(14)),
                              child: const Text('PENDING', style: TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                          ),
                        );
                      }),
                      const Divider(height: 24),
                    ],

                    const Text('Visits', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Expanded(
                      child: ListView(
                        children: (d['visits'] as List).reversed.map((v) {
                          final vv = v as Map<String, dynamic>;
                          final risk = vv["risk"] as Map<String, dynamic>?;
                          return Card(
                            child: ListTile(
                              title: Text('BP ${vv["bpSystolic"]} • Hb ${vv["hb"]} • GW ${vv["gestWeek"]}'),
                              subtitle: Text('Risk: ${risk?["level"]} (${risk?["score"]})'),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ]),
                ),
    );
  }
}
