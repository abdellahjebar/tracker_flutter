import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_flutter/data/services/vehicle_service.dart';
import 'package:tracker_flutter/domain/models/vehicle.dart';
import 'package:tracker_flutter/providers/auth_provider.dart';

final vehicleServiceProvider = Provider<VehicleService>((ref) => VehicleService());

final vehicleProvider =
    AsyncNotifierProvider<VehicleNotifier, List<Vehicle>>(VehicleNotifier.new);

class VehicleNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return [];
    return ref.read(vehicleServiceProvider).fetchAll(user.uid);
  }

  Future<void> add(Vehicle vehicle) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(vehicleServiceProvider).add(user.uid, vehicle);
    ref.invalidateSelf();
    await future;
  }

  Future<void> delete(String vehicleId) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    await ref.read(vehicleServiceProvider).delete(user.uid, vehicleId);
    ref.invalidateSelf();
    await future;
  }
}
