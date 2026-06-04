import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_flutter/data/services/maintenance_service.dart';
import 'package:tracker_flutter/domain/models/category_maintenance.dart';
import 'package:tracker_flutter/domain/models/maintenance.dart';
import 'package:tracker_flutter/providers/auth_provider.dart';

final maintenanceServiceProvider =
    Provider<MaintenanceService>((ref) => MaintenanceService());

// --- Maintenance ---

final maintenanceProvider =
    AsyncNotifierProvider<MaintenanceNotifier, List<Maintenance>>(MaintenanceNotifier.new);

class MaintenanceNotifier extends AsyncNotifier<List<Maintenance>> {
  @override
  Future<List<Maintenance>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];
    return ref.read(maintenanceServiceProvider).fetchAll(user.uid);
  }

  Future<void> add(Maintenance m) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(maintenanceServiceProvider).add(user.uid, m);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String maintenanceId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(maintenanceServiceProvider).delete(user.uid, maintenanceId);
    ref.invalidateSelf();
    await future;
  }
}

// --- Categories ---

final categoryProvider =
    AsyncNotifierProvider<CategoryNotifier, List<CategoryMaintenance>>(CategoryNotifier.new);

class CategoryNotifier extends AsyncNotifier<List<CategoryMaintenance>> {
  @override
  Future<List<CategoryMaintenance>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];
    return ref.read(maintenanceServiceProvider).fetchCategories(user.uid);
  }

  Future<void> add(String nom) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(maintenanceServiceProvider).addCategory(user.uid, nom);
    ref.invalidateSelf();
    await future;
  }
}
