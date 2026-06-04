import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_flutter/data/services/fuel_service.dart';
import 'package:tracker_flutter/domain/models/fuel_entry.dart';
import 'package:tracker_flutter/providers/auth_provider.dart';

final fuelServiceProvider = Provider<FuelService>((ref) => FuelService());

final fuelProvider =
    AsyncNotifierProvider<FuelNotifier, List<FuelEntry>>(FuelNotifier.new);

class FuelNotifier extends AsyncNotifier<List<FuelEntry>> {
  @override
  Future<List<FuelEntry>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];
    return ref.read(fuelServiceProvider).fetchAll(user.uid);
  }

  Future<void> add(FuelEntry entry) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(fuelServiceProvider).add(user.uid, entry);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String entryId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(fuelServiceProvider).delete(user.uid, entryId);
    ref.invalidateSelf();
    await future;
  }
}
