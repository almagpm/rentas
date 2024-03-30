class MobiliarioModel {
  int? mobiliario_id;
  int? categoria_id;
  String? nombre_mobiliario;

  MobiliarioModel({this.mobiliario_id, this.categoria_id, this.nombre_mobiliario});

  factory MobiliarioModel.fromMap(Map<String, dynamic> mobiliario) {
    return MobiliarioModel(
      mobiliario_id: mobiliario['mobiliario_id'],
      categoria_id: mobiliario['categoria_id'],
      nombre_mobiliario: mobiliario['nombre_mobiliario'],
    );
  }
}
