import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_flutter/domain/models/fuel_entry.dart';
import 'package:tracker_flutter/domain/models/vehicle.dart';
import 'package:tracker_flutter/providers/fuel_provider.dart';
import 'package:tracker_flutter/providers/vehicle_provider.dart';

class AddFuelScreen extends ConsumerStatefulWidget {
  const AddFuelScreen({super.key});

  @override
  ConsumerState<AddFuelScreen> createState() => _AddFuelScreenState();
}

class _AddFuelScreenState extends ConsumerState<AddFuelScreen> {
  final _litresController = TextEditingController();
  final _montantController = TextEditingController();
  final _kilometrageController = TextEditingController();
  Vehicle? _selectedVehicle;
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _litresController.dispose();
    _montantController.dispose();
    _kilometrageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _submit() async {
    final litres = double.tryParse(_litresController.text.trim());
    final montant = double.tryParse(_montantController.text.trim());
    final kilometrage = int.tryParse(_kilometrageController.text.trim());

    if (_selectedVehicle == null || litres == null || montant == null || kilometrage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs correctement.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(fuelProvider.notifier).add(
            FuelEntry(
              id: '',
              vehicleId: _selectedVehicle!.id,
              date: _selectedDate,
              litres: litres,
              montant: montant,
              kilometrage: kilometrage,
            ),
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehicleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter entrée gasoil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            vehiclesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur véhicules: $e'),
              data: (vehicles) => DropdownMenu<Vehicle>(
                label: const Text('Véhicule'),
                expandedInsets: EdgeInsets.zero,
                dropdownMenuEntries: vehicles
                    .map((v) => DropdownMenuEntry(
                          value: v,
                          label: '${v.marque} ${v.modele} — ${v.immatriculation}',
                        ))
                    .toList(),
                onSelected: (v) => setState(() => _selectedVehicle = v),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text('Date : ${_formatDate(_selectedDate)}'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _litresController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Litres',
                border: OutlineInputBorder(),
                suffixText: 'L',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _montantController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Montant',
                border: OutlineInputBorder(),
                suffixText: 'MAD',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kilometrageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kilométrage',
                border: OutlineInputBorder(),
                suffixText: 'km',
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
