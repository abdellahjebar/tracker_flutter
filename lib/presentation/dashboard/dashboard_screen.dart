import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_flutter/domain/models/vehicle.dart';
import 'package:tracker_flutter/providers/dashboard_provider.dart';
import 'package:tracker_flutter/providers/maintenance_provider.dart';

const _monthNames = [
  'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
  'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
];

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Vehicle? _maintenanceVehicle;
  DateTime? _maintenanceFrom;
  DateTime? _maintenanceTo;

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _prevMonth() => ref.read(selectedMonthProvider.notifier).previous();

  void _nextMonth() => ref.read(selectedMonthProvider.notifier).next();

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _maintenanceFrom ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _maintenanceFrom = picked);
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _maintenanceTo ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _maintenanceTo = picked);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedMonthProvider);
    final stats = ref.watch(dashboardStatsProvider);
    final maintenanceAsync = ref.watch(maintenanceProvider);
    final rateAsync = ref.watch(exchangeRateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Sélecteur de mois ---
          _SectionCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                Text(
                  '${_monthNames[selectedDate.month - 1]} ${selectedDate.year}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),
          ),

          // --- Taux de change via Dio ---
          rateAsync.when(
            data: (rate) => rate != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.currency_exchange, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(rate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (err, st) => const SizedBox.shrink(),
          ),

          // --- Section 1 : Liste des voitures ---
          _SectionTitle(title: 'Véhicules (${stats.vehicles.length})'),
          if (stats.vehicles.isEmpty)
            const _EmptyHint(text: 'Aucun véhicule enregistré')
          else
            ...stats.vehicles.map(
              (v) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.directions_car)),
                  title: Text('${v.marque} ${v.modele}'),
                  subtitle: Text('${v.immatriculation} • ${v.annee}'),
                ),
              ),
            ),

          const SizedBox(height: 8),

          // --- Section 2 : Dépenses du mois ---
          _SectionTitle(title: 'Dépenses — ${_monthNames[selectedDate.month - 1]}'),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatRow(
                  label: 'Total',
                  value: '${stats.totalExpenses.toStringAsFixed(2)} MAD',
                  bold: true,
                ),
                const Divider(height: 20),
                _StatRow(
                  label: 'Gasoil',
                  value: '${stats.totalFuel.toStringAsFixed(2)} MAD  (${stats.fuelPercent.toStringAsFixed(1)}%)',
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: stats.totalExpenses == 0 ? 0 : stats.totalFuel / stats.totalExpenses,
                  backgroundColor: Colors.orange.shade100,
                  color: Colors.blue,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 12),
                _StatRow(
                  label: 'Maintenance',
                  value: '${stats.totalMaintenance.toStringAsFixed(2)} MAD  (${stats.maintenancePercent.toStringAsFixed(1)}%)',
                  color: Colors.orange,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: stats.totalExpenses == 0 ? 0 : stats.totalMaintenance / stats.totalExpenses,
                  backgroundColor: Colors.blue.shade100,
                  color: Colors.orange,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // --- Section 3 : Consommation gasoil par vehicle ---
          _SectionTitle(title: 'Consommation gasoil par véhicule'),
          if (stats.fuelByVehicle.isEmpty)
            const _EmptyHint(text: 'Aucune entrée gasoil ce mois')
          else
            _SectionCard(
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(2),
                },
                children: [
                  const TableRow(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
                    children: [
                      Padding(padding: EdgeInsets.only(bottom: 6), child: Text('Véhicule', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.only(bottom: 6), child: Text('Litres', style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(padding: EdgeInsets.only(bottom: 6), child: Text('Montant', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  ...stats.fuelByVehicle.entries.map((entry) {
                    final vehicle = stats.vehicles.where((v) => v.id == entry.key).firstOrNull;
                    final label = vehicle != null ? '${vehicle.marque} ${vehicle.modele}' : entry.key.substring(0, 6);
                    return TableRow(children: [
                      Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(label)),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('${entry.value.litres.toStringAsFixed(1)} L')),
                      Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text('${entry.value.montant.toStringAsFixed(2)} MAD')),
                    ]);
                  }),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // --- Section 4 : Historique maintenance par vehicle ---
          const _SectionTitle(title: 'Historique maintenance'),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownMenu<Vehicle?>(
                  label: const Text('Véhicule'),
                  expandedInsets: EdgeInsets.zero,
                  dropdownMenuEntries: [
                    const DropdownMenuEntry(value: null, label: 'Tous les véhicules'),
                    ...stats.vehicles.map((v) => DropdownMenuEntry(
                          value: v,
                          label: '${v.marque} ${v.modele} — ${v.immatriculation}',
                        )),
                  ],
                  onSelected: (v) => setState(() => _maintenanceVehicle = v),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFrom,
                        icon: const Icon(Icons.calendar_today, size: 14),
                        label: Text(_maintenanceFrom == null ? 'Du' : _formatDate(_maintenanceFrom!)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickTo,
                        icon: const Icon(Icons.calendar_today, size: 14),
                        label: Text(_maintenanceTo == null ? 'Au' : _formatDate(_maintenanceTo!)),
                      ),
                    ),
                    if (_maintenanceVehicle != null || _maintenanceFrom != null || _maintenanceTo != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() {
                          _maintenanceVehicle = null;
                          _maintenanceFrom = null;
                          _maintenanceTo = null;
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
          maintenanceAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Erreur: $e'),
            data: (all) {
              final filtered = all.where((m) {
                if (_maintenanceVehicle != null && m.vehicleId != _maintenanceVehicle!.id) return false;
                if (_maintenanceFrom != null && m.date.isBefore(_maintenanceFrom!)) return false;
                if (_maintenanceTo != null && m.date.isAfter(_maintenanceTo!.add(const Duration(days: 1)))) return false;
                return true;
              }).toList();

              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: _EmptyHint(text: 'Aucune maintenance'),
                );
              }
              return Column(
                children: filtered.map((m) {
                  final vehicle = stats.vehicles.where((v) => v.id == m.vehicleId).firstOrNull;
                  return Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.build)),
                      title: Text(m.description),
                      subtitle: Text(
                        '${vehicle != null ? '${vehicle.marque} ${vehicle.modele} • ' : ''}${_formatDate(m.date)} • ${m.montant} MAD',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// --- Helpers ---

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value, this.bold = false, this.color});
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: bold ? const TextStyle(fontWeight: FontWeight.bold) : null),
        Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color)),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(child: Text(text, style: const TextStyle(color: Colors.grey))),
    );
  }
}
