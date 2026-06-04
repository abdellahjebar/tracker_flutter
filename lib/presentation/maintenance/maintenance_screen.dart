import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_flutter/domain/models/vehicle.dart';
import 'package:tracker_flutter/providers/maintenance_provider.dart';
import 'package:tracker_flutter/providers/vehicle_provider.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  DateTime? _from;
  DateTime? _to;
  Vehicle? _selectedVehicle;

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _from = picked);
  }

  Future<void> _pickTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _to ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _to = picked);
  }

  @override
  Widget build(BuildContext context) {
    final maintenanceAsync = ref.watch(maintenanceProvider);
    final vehiclesAsync = ref.watch(vehicleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Maintenance')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: vehiclesAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (err, st) => const SizedBox.shrink(),
              data: (vehicles) => DropdownMenu<Vehicle?>(
                label: const Text('Véhicule'),
                expandedInsets: EdgeInsets.zero,
                initialSelection: _selectedVehicle,
                dropdownMenuEntries: [
                  const DropdownMenuEntry(value: null, label: 'Tous les véhicules'),
                  ...vehicles.map((v) => DropdownMenuEntry(
                        value: v,
                        label: '${v.marque} ${v.modele} — ${v.immatriculation}',
                      )),
                ],
                onSelected: (v) => setState(() => _selectedVehicle = v),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFrom,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_from == null ? 'Du' : _formatDate(_from!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTo,
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(_to == null ? 'Au' : _formatDate(_to!)),
                  ),
                ),
                if (_from != null || _to != null || _selectedVehicle != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() {
                      _from = null;
                      _to = null;
                      _selectedVehicle = null;
                    }),
                  ),
              ],
            ),
          ),
          Expanded(
            child: maintenanceAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
              data: (all) {
                final entries = all.where((m) {
                  if (_selectedVehicle != null && m.vehicleId != _selectedVehicle!.id) return false;
                  if (_from != null && m.date.isBefore(_from!)) return false;
                  if (_to != null && m.date.isAfter(_to!.add(const Duration(days: 1)))) return false;
                  return true;
                }).toList();

                if (entries.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.build_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('Aucune maintenance', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final m = entries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.build)),
                        title: Text(m.description),
                        subtitle: Text('${_formatDate(m.date)} • ${m.montant} MAD'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            await ref.read(maintenanceProvider.notifier).delete(m.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/maintenance/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
