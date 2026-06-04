import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_flutter/core/dio_client.dart';
import 'package:tracker_flutter/domain/models/vehicle.dart';
import 'package:tracker_flutter/providers/fuel_provider.dart';
import 'package:tracker_flutter/providers/maintenance_provider.dart';
import 'package:tracker_flutter/providers/vehicle_provider.dart';

// --- Data classes ---

class VehicleFuelStats {
  final double litres;
  final double montant;
  const VehicleFuelStats({required this.litres, required this.montant});
}

class DashboardStats {
  final List<Vehicle> vehicles;
  final double totalFuel;
  final double totalMaintenance;
  final Map<String, VehicleFuelStats> fuelByVehicle;

  const DashboardStats({
    required this.vehicles,
    required this.totalFuel,
    required this.totalMaintenance,
    required this.fuelByVehicle,
  });

  double get totalExpenses => totalFuel + totalMaintenance;
  double get fuelPercent =>
      totalExpenses == 0 ? 0 : (totalFuel / totalExpenses * 100);
  double get maintenancePercent =>
      totalExpenses == 0 ? 0 : (totalMaintenance / totalExpenses * 100);
}

// --- Selected month ---

class SelectedMonthNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void previous() {
    state = DateTime(state.year, state.month - 1);
  }

  void next() {
    final candidate = DateTime(state.year, state.month + 1);
    if (!candidate.isAfter(DateTime.now())) state = candidate;
  }
}

final selectedMonthProvider =
    NotifierProvider<SelectedMonthNotifier, DateTime>(SelectedMonthNotifier.new);

// --- Computed stats ---

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final selected = ref.watch(selectedMonthProvider);
  final vehicles = ref.watch(vehicleProvider).value ?? [];
  final fuelEntries = ref.watch(fuelProvider).value ?? [];
  final maintenanceList = ref.watch(maintenanceProvider).value ?? [];

  final m = selected.month;
  final y = selected.year;

  final monthFuel =
      fuelEntries.where((e) => e.date.month == m && e.date.year == y).toList();
  final monthMaint = maintenanceList
      .where((e) => e.date.month == m && e.date.year == y)
      .toList();

  final totalFuel = monthFuel.fold(0.0, (s, e) => s + e.montant);
  final totalMaint = monthMaint.fold(0.0, (s, e) => s + e.montant);

  final fuelByVehicle = <String, VehicleFuelStats>{};
  for (final e in monthFuel) {
    final prev = fuelByVehicle[e.vehicleId];
    fuelByVehicle[e.vehicleId] = VehicleFuelStats(
      litres: (prev?.litres ?? 0) + e.litres,
      montant: (prev?.montant ?? 0) + e.montant,
    );
  }

  return DashboardStats(
    vehicles: vehicles,
    totalFuel: totalFuel,
    totalMaintenance: totalMaint,
    fuelByVehicle: fuelByVehicle,
  );
});

// Dio — taux de change MAD → EUR via API externe
final exchangeRateProvider = FutureProvider<String?>((ref) async {
  try {
    final response =
        await DioClient.get('https://open.er-api.com/v6/latest/MAD');
    final rates = response.data['rates'] as Map<String, dynamic>;
    final eur = (rates['EUR'] as num).toDouble();
    return '1 MAD = ${eur.toStringAsFixed(4)} EUR';
  } catch (e) {
    return null;
  }
});
