import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auto.dart';

class GasAutosView extends StatelessWidget {
  const GasAutosView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'Selecciona un auto',
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
                                  radius: 30,
                                )
                                : const CircleAvatar(
                                  child: Icon(Icons.directions_car, size: 32),
                                  radius: 30,
                                ),
                        title: Text(
                          '${auto.marca} ${auto.modelo} (${auto.placa})',
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/gas/auto/dashboard',
                            arguments: auto,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
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
