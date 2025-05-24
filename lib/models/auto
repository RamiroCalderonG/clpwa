class Auto {
  final String id;
  final String marca;
  final String modelo;
  final String anio;
  final String vin;
  final String? fotoUrl;

  Auto({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.vin,
    this.fotoUrl,
  });

  factory Auto.fromMap(String id, Map<String, dynamic> map) {
    return Auto(
      id: id,
      marca: map['marca'] ?? '',
      modelo: map['modelo'] ?? '',
      anio: map['anio'] ?? '',
      vin: map['vin'] ?? '',
      fotoUrl: map['fotoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'vin': vin,
      'fotoUrl': fotoUrl,
    };
  }
}
