import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_flutter/providers/fuel_provider.dart';

class FuelScreen extends ConsumerWidget {
  const FuelScreen({super.key});

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelAsync = ref.watch(fuelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Entrées Gasoil')),
      body: fuelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_gas_station_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Aucune entrée gasoil', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.local_gas_station)),
                  title: Text('${e.litres} L — ${e.montant} MAD'),
                  subtitle: Text('${_formatDate(e.date)} • ${e.kilometrage} km'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      await ref.read(fuelProvider.notifier).delete(e.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/fuel/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
