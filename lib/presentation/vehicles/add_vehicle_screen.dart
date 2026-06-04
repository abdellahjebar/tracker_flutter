import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_flutter/domain/models/vehicle.dart';
import 'package:tracker_flutter/providers/vehicle_provider.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _marqueController = TextEditingController();
  final _modeleController = TextEditingController();
  final _immatriculationController = TextEditingController();
  final _anneeController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _marqueController.dispose();
    _modeleController.dispose();
    _immatriculationController.dispose();
    _anneeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final marque = _marqueController.text.trim();
    final modele = _modeleController.text.trim();
    final immatriculation = _immatriculationController.text.trim();
    final anneeText = _anneeController.text.trim();

    if (marque.isEmpty || modele.isEmpty || immatriculation.isEmpty || anneeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    final annee = int.tryParse(anneeText);
    if (annee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Année invalide.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(vehicleProvider.notifier).add(
            Vehicle(id: '', marque: marque, modele: modele, immatriculation: immatriculation, annee: annee),
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un véhicule')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _marqueController,
              decoration: const InputDecoration(
                labelText: 'Marque',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _modeleController,
              decoration: const InputDecoration(
                labelText: 'Modèle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _immatriculationController,
              decoration: const InputDecoration(
                labelText: 'Immatriculation',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _anneeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Année',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
