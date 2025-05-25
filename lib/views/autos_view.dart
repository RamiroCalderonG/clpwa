import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auto.dart';

class AutosView extends StatelessWidget {
  const AutosView({super.key});

  void _borrarAuto(BuildContext context, Auto auto) async {
    // Borra el auto de Firestore (y su imagen si deseas)
    await FirebaseFirestore.instance.collection('autos').doc(auto.id).delete();
    // Aquí puedes agregar la lógica para borrar la foto del storage si quieres
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Auto eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Mis Autos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading:
                            auto.fotoUrl != null
                                ? CircleAvatar(
                                  backgroundImage: NetworkImage(auto.fotoUrl!),
                                  radius: 28,
                                )
                                : const CircleAvatar(
                                  child: Icon(Icons.directions_car, size: 28),
                                  radius: 28,
                                ),
                        title: Text('${auto.modelo} (${auto.anio})'),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/autos/edit',
                                  arguments: auto,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: const Text('Eliminar auto'),
                                        content: const Text(
                                          '¿Estás seguro de eliminar este auto?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, false),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(ctx, true),
                                            child: const Text(
                                              'Eliminar',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true) {
                                  _borrarAuto(context, auto);
                                }
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
          const SizedBox(height: 10),
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
            child: const Text('← Volver al Menú Principal'),
          ),
        ],
      ),
    );
  }
}
