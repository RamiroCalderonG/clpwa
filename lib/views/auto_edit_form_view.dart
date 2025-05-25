import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auto.dart';

class AutoEditFormView extends StatefulWidget {
  final Auto auto;
  const AutoEditFormView({super.key, required this.auto});

  @override
  State<AutoEditFormView> createState() => _AutoEditFormViewState();
}

class _AutoEditFormViewState extends State<AutoEditFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController marcaController;
  late TextEditingController modeloController;
  late TextEditingController anioController;
  late TextEditingController vinController;
  late TextEditingController placaController;

  String? fotoUrl;
  String tipoMantenimiento = 'plan1';

  @override
  void initState() {
    super.initState();
    marcaController = TextEditingController(text: widget.auto.marca);
    modeloController = TextEditingController(text: widget.auto.modelo);
    anioController = TextEditingController(text: widget.auto.anio);
    vinController = TextEditingController(text: widget.auto.vin);
    placaController = TextEditingController(text: widget.auto.placa ?? '');
    fotoUrl = widget.auto.fotoUrl;
    tipoMantenimiento = widget.auto.tipoMantenimiento ?? 'plan1';
  }

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
                'Editar Vehículo',
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
                  await FirebaseFirestore.instance
                      .collection('autos')
                      .doc(widget.auto.id)
                      .update({
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
                child: const Text('Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
