class CategoriaMobiliarioModel {
  int? categoria_id;
  String? nombre_categoria;

  CategoriaMobiliarioModel({this.categoria_id, this.nombre_categoria});

  factory CategoriaMobiliarioModel.fromMap(Map<String, dynamic> categoria) {
    return CategoriaMobiliarioModel(
      categoria_id: categoria['categoria_id'],
      nombre_categoria: categoria['nombre_categoria'],
    );
  }
}
