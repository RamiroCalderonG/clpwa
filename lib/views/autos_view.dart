import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auto.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AutosView extends StatelessWidget {
  const AutosView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Mis Autos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('autos').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Aún no hay autos registrados.'),
                    );
                  }
                  final autos =
                      snapshot.data!.docs
                          .map(
                            (doc) => Auto.fromMap(
                              doc.id,
                              doc.data() as Map<String, dynamic>,
                            ),
                          )
                          .toList();
                  return ListView.builder(
                    itemCount: autos.length,
                    itemBuilder: (context, index) {
                      final auto = autos[index];
                      return Card(
                        child: ListTile(
                          leading:
                              auto.fotoUrl != null
                                  ? Image.network(
                                    auto.fotoUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                  : const Icon(Icons.directions_car, size: 48),
                          title: Text(
                            '${auto.marca} ${auto.modelo} (${auto.anio})',
                          ),
                          subtitle: Text('VIN: ${auto.vin}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/autos/edit',
                                    arguments: auto,
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: const Text('¿Eliminar auto?'),
                                          content: const Text(
                                            '¿Seguro que deseas eliminar este auto? Esta acción es irreversible.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    false,
                                                  ),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(
                                                    context,
                                                    true,
                                                  ),
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirm != true) return;
                                  // Borra foto de Storage si existe
                                  if (auto.fotoUrl != null &&
                                      auto.fotoUrl!.isNotEmpty) {
                                    try {
                                      final ref = FirebaseStorage.instance
                                          .refFromURL(auto.fotoUrl!);
                                      await ref.delete();
                                    } catch (_) {}
                                  }
                                  // Borra documento de Firestore
                                  await FirebaseFirestore.instance
                                      .collection('autos')
                                      .doc(auto.id)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/autos/form');
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Auto'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('← Volver a Configuración'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
