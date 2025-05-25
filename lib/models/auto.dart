class Auto {
  final String id;
  final String marca;
  final String modelo;
  final String anio;
  final String vin;
  final String placa;
  final String? fotoUrl;
  final String tipoMantenimiento; // <-- Nuevo campo

  Auto({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.vin,
    required this.placa,
    this.fotoUrl,
    required this.tipoMantenimiento, // <-- Nuevo campo
  });

  // Métodos fromMap y toMap...
  factory Auto.fromMap(String id, Map<String, dynamic> map) {
    return Auto(
      id: id,
      marca: map['marca'] ?? '',
      modelo: map['modelo'] ?? '',
      anio: map['anio'] ?? '',
      vin: map['vin'] ?? '',
      placa: map['placa'] ?? '',
      fotoUrl: map['fotoUrl'],
      tipoMantenimiento:
          map['tipoMantenimiento'] ?? 'plan1', // por defecto plan1
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'vin': vin,
      'placa': placa,
      'fotoUrl': fotoUrl,
      'tipoMantenimiento': tipoMantenimiento,
    };
  }
}
