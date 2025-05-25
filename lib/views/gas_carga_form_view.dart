import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auto.dart';

class GasCargaFormView extends StatefulWidget {
  final Auto auto;
  const GasCargaFormView({Key? key, required this.auto}) : super(key: key);

  @override
  State<GasCargaFormView> createState() => _GasCargaFormViewState();
}

class _GasCargaFormViewState extends State<GasCargaFormView> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _fecha;
  double? _km;
  double? _litros;
  String _tipo = 'Verde';
  double? _costoPorLitro;
  double? _total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva carga')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Fecha
              ListTile(
                leading: const Icon(Icons.date_range),
                title: Text(
                  _fecha == null
                      ? 'Selecciona la fecha'
                      : _fecha.toString().split(' ')[0],
                ),
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: now,
                    firstDate: DateTime(now.year - 2),
                    lastDate: now,
                  );
                  if (picked != null) {
                    setState(() => _fecha = picked);
                  }
                },
              ),
              const SizedBox(height: 8),
              // Kilometraje
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Kilometraje actual',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _km = double.tryParse(v)),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),
              // Litros
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Litros cargados',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _litros = double.tryParse(v)),
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),
              // Tipo gasolina
              DropdownButtonFormField<String>(
                value: _tipo,
                items: const [
                  DropdownMenuItem(value: 'Verde', child: Text('Verde')),
                  DropdownMenuItem(value: 'Roja', child: Text('Roja')),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? 'Verde'),
                decoration: const InputDecoration(
                  labelText: 'Tipo de gasolina',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              // Costo por litro
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Costo por litro',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  _costoPorLitro = double.tryParse(v);
                  setState(() {
                    if (_litros != null && _costoPorLitro != null) {
                      _total = _litros! * _costoPorLitro!;
                    }
                  });
                },
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 8),
              // Total
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Total (se calcula automáticamente)',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: _total != null ? _total!.toStringAsFixed(2) : '',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar carga'),
                onPressed: () async {
                  if (!_formKey.currentState!.validate() || _fecha == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completa todos los campos'),
                      ),
                    );
                    return;
                  }
                  final data = {
                    'fecha': _fecha,
                    'km': _km,
                    'litros': _litros,
                    'tipo': _tipo,
                    'costoPorLitro': _costoPorLitro,
                    'total': _total,
                    'createdAt': FieldValue.serverTimestamp(),
                  };
                  await FirebaseFirestore.instance
                      .collection('autos')
                      .doc(widget.auto.id)
                      .collection('gas')
                      .add(data);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
