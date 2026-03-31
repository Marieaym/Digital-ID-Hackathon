import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/offline_queue.dart';

class MotherProvider extends ChangeNotifier {
  final ApiClient api;
  final OfflineQueue offline = OfflineQueue();

  bool loading = false;
  List<dynamic> mothers = [];
  int pendingCount = 0;

  MotherProvider(this.api);

  Future<void> refreshPendingCount() async {
    pendingCount = await offline.countPending();
    notifyListeners();
  }

  Future<void> fetchMothers({String search = ''}) async {
    loading = true; notifyListeners();
    try {
      mothers = await api.getList('/mothers?search=$search');
      await refreshPendingCount();
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createMother(Map<String, dynamic> payload) async {
    final m = await api.post('/mothers', payload);
    await fetchMothers();
    return m;
  }

  Future<Map<String, dynamic>> getMother(String id) async => api.getMap('/mothers/$id');
  Future<Map<String, dynamic>> addVisit(String motherId, Map<String, dynamic> payload) async => api.post('/mothers/$motherId/visits', payload);
  Future<List<dynamic>> fetchAudit() async => api.getList('/audit');
  Future<Map<String, dynamic>> fetchFhir(String motherId) async => api.getMap('/mothers/$motherId/fhir');

  Future<int> syncPendingVisits() async {
    final pending = await offline.getPendingVisits();
    int synced = 0;

    for (final item in pending) {
      if (item["type"] != "VISIT") continue;
      final motherId = item["motherId"] as String;
      final payload = Map<String, dynamic>.from(item["payload"] as Map);
      try {
        await api.post('/mothers/$motherId/visits', payload);
        await offline.removeFirstPendingVisitForMother(motherId);
        synced++;
      } catch (_) {
        break;
      }
    }

    await refreshPendingCount();
    await fetchMothers();
    return synced;
  }
}
