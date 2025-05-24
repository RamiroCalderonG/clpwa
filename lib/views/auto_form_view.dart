import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class AutoFormView extends StatefulWidget {
  const AutoFormView({super.key});

  @override
  State<AutoFormView> createState() => _AutoFormViewState();
}

class _AutoFormViewState extends State<AutoFormView> {
  final _formKey = GlobalKey<FormState>();
  final marcaController = TextEditingController();
  final modeloController = TextEditingController();
  final anioController = TextEditingController();
  final vinController = TextEditingController();

  Uint8List? _imagenAuto; // Para la imagen seleccionada
  String? _nombreArchivo; // Nombre de la imagen

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
                    const Text(
                      'Agregar Auto',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_imagenAuto != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Image.memory(_imagenAuto!, height: 120),
                      ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Seleccionar Foto (opcional)'),
                      onPressed: () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(type: FileType.image, withData: true);
                        if (result != null &&
                            result.files.single.bytes != null) {
                          setState(() {
                            _imagenAuto = result.files.single.bytes!;
                            _nombreArchivo = result.files.single.name;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: marcaController,
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: modeloController,
                      decoration: const InputDecoration(
                        labelText: 'Modelo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: anioController,
                      decoration: const InputDecoration(
                        labelText: 'Año',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: vinController,
                      decoration: const InputDecoration(
                        labelText: 'VIN',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              String? urlFoto;

                              if (_imagenAuto != null &&
                                  _nombreArchivo != null) {
                                final ref = FirebaseStorage.instance
                                    .ref()
                                    .child('autos')
                                    .child(_nombreArchivo!);
                                await ref.putData(
                                  _imagenAuto!,
                                  SettableMetadata(
                                    contentType: 'image/jpeg',
                                  ), // O 'image/png' según la extensión
                                );

                                urlFoto = await ref.getDownloadURL();
                              }

                              await FirebaseFirestore.instance
                                  .collection('autos')
                                  .add({
                                    'marca': marcaController.text,
                                    'modelo': modeloController.text,
                                    'anio': anioController.text,
                                    'vin': vinController.text,
                                    'fotoUrl': urlFoto,
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
