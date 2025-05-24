import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
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

  Uint8List? _imagenAuto;
  String? _nombreArchivo;
  String? _fotoUrlEditada;

  @override
  void initState() {
    super.initState();
    marcaController = TextEditingController(text: widget.auto.marca);
    modeloController = TextEditingController(text: widget.auto.modelo);
    anioController = TextEditingController(text: widget.auto.anio);
    vinController = TextEditingController(text: widget.auto.vin);
    _fotoUrlEditada = widget.auto.fotoUrl;
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
                    const Text(
                      'Editar Auto',
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
                      )
                    else if (_fotoUrlEditada != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Image.network(_fotoUrlEditada!, height: 120),
                      ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Cambiar Foto'),
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
                              String? urlFoto = _fotoUrlEditada;

                              // Si se cambió la imagen, sube nueva y borra la anterior
                              if (_imagenAuto != null &&
                                  _nombreArchivo != null) {
                                // Borra anterior si existe
                                if (_fotoUrlEditada != null &&
                                    _fotoUrlEditada!.isNotEmpty) {
                                  try {
                                    final ref = FirebaseStorage.instance
                                        .refFromURL(_fotoUrlEditada!);
                                    await ref.delete();
                                  } catch (_) {}
                                }
                                String contentType =
                                    _nombreArchivo != null &&
                                            _nombreArchivo!.endsWith('.png')
                                        ? 'image/png'
                                        : 'image/jpeg';
                                final ref = FirebaseStorage.instance
                                    .ref()
                                    .child('autos')
                                    .child(_nombreArchivo!);
                                await ref.putData(
                                  _imagenAuto!,
                                  SettableMetadata(contentType: contentType),
                                );
                                urlFoto = await ref.getDownloadURL();
                              }

                              await FirebaseFirestore.instance
                                  .collection('autos')
                                  .doc(widget.auto.id)
                                  .update({
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
