class DetalleRentaModel {
  int? detalle_id;
  int? renta_id;
  int? mobiliario_id;
  int? cantidad;

  DetalleRentaModel({
    this.detalle_id,
    this.renta_id,
    this.mobiliario_id,
    this.cantidad,
  });

  factory DetalleRentaModel.fromMap(Map<String, dynamic> detalleRenta) {
    return DetalleRentaModel(
      detalle_id: detalleRenta['detalle_id'],
      renta_id: detalleRenta['renta_id'],
      mobiliario_id: detalleRenta['mobiliario_id'],
      cantidad: detalleRenta['cantidad'],
    );
  }
}
