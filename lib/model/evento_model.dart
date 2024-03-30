class EventoModel {
  int? evento_id;
  int? renta_id;
  String? nombre;
  String? fecha_evento;
  String? detalles_evento;

  EventoModel({
    this.evento_id,
    this.renta_id,
    this.nombre,
    this.fecha_evento,
    this.detalles_evento,
  });

  factory EventoModel.fromMap(Map<String, dynamic> evento) {
  return EventoModel(
    evento_id: evento['evento_id'],
    renta_id: evento['renta_id'],
    nombre: evento['nombre'],
    fecha_evento: evento['fecha_evento'] != null
        ? evento['fecha_evento']!
        : '',
    detalles_evento: evento['detalles_evento'],
  );
}


}
