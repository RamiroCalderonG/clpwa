import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AutoFormView extends StatefulWidget {
  const AutoFormView({super.key});

  @override
  State<AutoFormView> createState() => _AutoFormViewState();
}

class _AutoFormViewState extends State<AutoFormView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController marcaController = TextEditingController();
  final TextEditingController modeloController = TextEditingController();
  final TextEditingController anioController = TextEditingController();
  final TextEditingController vinController = TextEditingController();
  final TextEditingController placaController = TextEditingController();

  String? fotoUrl;
  String tipoMantenimiento = 'plan1';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Nuevo Vehículo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: marcaController,
                decoration: const InputDecoration(labelText: 'Marca'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: modeloController,
                decoration: const InputDecoration(labelText: 'Modelo'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: anioController,
                decoration: const InputDecoration(labelText: 'Año'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: vinController,
                decoration: const InputDecoration(labelText: 'VIN'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: placaController,
                decoration: const InputDecoration(labelText: 'Placa'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: tipoMantenimiento,
                decoration: const InputDecoration(
                  labelText: 'Tipo de mantenimiento',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'plan1',
                    child: Text('Plan 1 (6000/12000 km)'),
                  ),
                  DropdownMenuItem(
                    value: 'plan2',
                    child: Text('Plan 2 (7500/15000 km)'),
                  ),
                ],
                onChanged:
                    (value) => setState(() => tipoMantenimiento = value!),
                validator:
                    (value) => value == null ? 'Selecciona un tipo' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  await FirebaseFirestore.instance.collection('autos').add({
                    'marca': marcaController.text,
                    'modelo': modeloController.text,
                    'anio': anioController.text,
                    'vin': vinController.text,
                    'placa': placaController.text,
                    'fotoUrl': fotoUrl,
                    'tipoMantenimiento': tipoMantenimiento,
                  });
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
