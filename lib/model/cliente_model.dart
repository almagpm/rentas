class ClienteModel {
  int? cliente_id;
  String? nombre;
  String? correo;
  String? telefono;

  ClienteModel({this.cliente_id, this.nombre, this.correo, this.telefono});

  factory ClienteModel.fromMap(Map<String, dynamic> cliente) {
    return ClienteModel(
      cliente_id: cliente['cliente_id'],
      nombre: cliente['nombre'],
      correo: cliente['correo'],
      telefono: cliente['telefono'],
    );
  }
}
