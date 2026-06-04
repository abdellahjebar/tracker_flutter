import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_flutter/domain/models/maintenance.dart';
import 'package:tracker_flutter/domain/models/vehicle.dart';
import 'package:tracker_flutter/domain/models/category_maintenance.dart';
import 'package:tracker_flutter/providers/maintenance_provider.dart';
import 'package:tracker_flutter/providers/vehicle_provider.dart';

class AddMaintenanceScreen extends ConsumerStatefulWidget {
  const AddMaintenanceScreen({super.key});

  @override
  ConsumerState<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends ConsumerState<AddMaintenanceScreen> {
  final _descriptionController = TextEditingController();
  final _montantController = TextEditingController();
  final _newCategoryController = TextEditingController();
  Vehicle? _selectedVehicle;
  CategoryMaintenance? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _loading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _montantController.dispose();
    _newCategoryController.dispose();
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

  Future<void> _addCategory() async {
    final nom = _newCategoryController.text.trim();
    if (nom.isEmpty) return;
    await ref.read(categoryProvider.notifier).add(nom);
    _newCategoryController.clear();
    if (mounted) Navigator.of(context).pop();
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nouvelle catégorie'),
        content: TextField(
          controller: _newCategoryController,
          decoration: const InputDecoration(
            labelText: 'Nom',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
          FilledButton(onPressed: _addCategory, child: const Text('Ajouter')),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();
    final montant = double.tryParse(_montantController.text.trim());

    if (_selectedVehicle == null || _selectedCategory == null || description.isEmpty || montant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs correctement.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(maintenanceProvider.notifier).add(
            Maintenance(
              id: '',
              vehicleId: _selectedVehicle!.id,
              categoryId: _selectedCategory!.id,
              date: _selectedDate,
              description: description,
              montant: montant,
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
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter maintenance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            vehiclesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur: $e'),
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
            categoriesAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Erreur: $e'),
              data: (categories) => Row(
                children: [
                  Expanded(
                    child: DropdownMenu<CategoryMaintenance>(
                      label: const Text('Catégorie'),
                      expandedInsets: EdgeInsets.zero,
                      dropdownMenuEntries: categories
                          .map((c) => DropdownMenuEntry(value: c, label: c.nom))
                          .toList(),
                      onSelected: (c) => setState(() => _selectedCategory = c),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _showAddCategoryDialog,
                    icon: const Icon(Icons.add),
                    tooltip: 'Nouvelle catégorie',
                  ),
                ],
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
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
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
