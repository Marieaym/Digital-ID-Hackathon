import 'package:hive/hive.dart';

class OfflineQueue {
  static const String boxName = 'offline_queue';
  static const String keyVisits = 'pending_visits';

  Future<Box> _box() async => Hive.box(boxName);

  Future<List<Map<String, dynamic>>> getPendingVisits() async {
    final box = await _box();
    final raw = box.get(keyVisits, defaultValue: <dynamic>[]) as List;
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<int> countPending() async => (await getPendingVisits()).length;

  Future<void> enqueueVisit({required String motherId, required Map<String, dynamic> visitPayload}) async {
    final box = await _box();
    final list = await getPendingVisits();
    list.add({
      "type": "VISIT",
      "motherId": motherId,
      "payload": visitPayload,
      "createdAt": DateTime.now().toIso8601String(),
    });
    await box.put(keyVisits, list);
  }

  Future<List<Map<String, dynamic>>> getPendingVisitsForMother(String motherId) async {
    final all = await getPendingVisits();
    return all.where((e) => e["type"] == "VISIT" && e["motherId"] == motherId).toList();
  }

  Future<void> removeFirstPendingVisitForMother(String motherId) async {
    final box = await _box();
    final list = await getPendingVisits();
    final idx = list.indexWhere((e) => e["type"] == "VISIT" && e["motherId"] == motherId);
    if (idx >= 0) {
      list.removeAt(idx);
      await box.put(keyVisits, list);
    }
  }
}
