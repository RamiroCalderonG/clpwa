import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auto.dart';

class GasCargaFormView extends StatefulWidget {
  final Auto auto;
  const GasCargaFormView({super.key, required this.auto});

  @override
  State<GasCargaFormView> createState() => _GasCargaFormViewState();
}

class _GasCargaFormViewState extends State<GasCargaFormView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _litrosController = TextEditingController();
  final TextEditingController _costoLitroController = TextEditingController();

  String _tipoGas = 'Verde'; // O 'Roja'
  double _total = 0.0;

  @override
  void dispose() {
    _fechaController.dispose();
    _kmController.dispose();
    _litrosController.dispose();
    _costoLitroController.dispose();
    super.dispose();
  }

  void _actualizaTotal() {
    final litros = double.tryParse(_litrosController.text) ?? 0;
    final costo = double.tryParse(_costoLitroController.text) ?? 0;
    setState(() {
      _total = litros * costo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 6,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Carga de gasolina para ${widget.auto.modelo}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _fechaController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2022, 1),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          _fechaController.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _kmController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kilometraje',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.speed),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _litrosController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Litros cargados',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_gas_station),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                      onChanged: (_) => _actualizaTotal(),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _tipoGas,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de gasolina',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_gas_station_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Verde', child: Text('Verde')),
                        DropdownMenuItem(value: 'Roja', child: Text('Roja')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _tipoGas = value ?? 'Verde';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _costoLitroController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Costo por litro',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                      onChanged: (_) => _actualizaTotal(),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Total: \$${_total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await FirebaseFirestore.instance
                                  .collection('autos')
                                  .doc(widget.auto.id)
                                  .collection('gas')
                                  .add({
                                    'fecha': _fechaController.text,
                                    'km': int.tryParse(_kmController.text) ?? 0,
                                    'litros':
                                        double.tryParse(
                                          _litrosController.text,
                                        ) ??
                                        0.0,
                                    'tipo': _tipoGas,
                                    'costoPorLitro':
                                        double.tryParse(
                                          _costoLitroController.text,
                                        ) ??
                                        0.0,
                                    'total': _total,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          child: const Text('Guardar'),
                        ),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
