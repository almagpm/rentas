class AlarmaModel {
  int? alarma_id;
  int? renta_id;
  DateTime? fecha_alarma;
  String? descripcion;

  AlarmaModel({
    this.alarma_id,
    this.renta_id,
    this.fecha_alarma,
    this.descripcion,
  });

  factory AlarmaModel.fromMap(Map<String, dynamic> alarma) {
    return AlarmaModel(
      alarma_id: alarma['alarma_id'],
      renta_id: alarma['renta_id'],
      fecha_alarma: DateTime.parse(alarma['fecha_alarma']),
      descripcion: alarma['descripcion'],
    );
  }
}
