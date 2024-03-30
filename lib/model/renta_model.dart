class RentaModel {
  int? renta_id;
  DateTime? fecha_inicio;
  DateTime? fecha_fin;
  String? estatus;
  int? cliente_id;

  RentaModel({
    this.renta_id,
    this.fecha_inicio,
    this.fecha_fin,
    this.estatus,
    this.cliente_id,
  });

  factory RentaModel.fromMap(Map<String, dynamic> renta) {
    return RentaModel(
      renta_id: renta['renta_id'],
      fecha_inicio: DateTime.parse(renta['fecha_inicio']),
      fecha_fin: DateTime.parse(renta['fecha_fin']),
      estatus: renta['estatus'],
      cliente_id: renta['cliente_id'],
    );
  }
}
