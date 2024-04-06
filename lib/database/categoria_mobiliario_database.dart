import 'package:rentas/database/database_provider.dart';
import 'package:rentas/model/categoria_mobiliario_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CategoriaMobiliarioDatabase {
  Future<int> insertCategoria(CategoriaMobiliarioModel categoria) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('CategoriasMobiliario', {
      'categoria_id': categoria.categoria_id,
      'nombre_categoria': categoria.nombre_categoria,
    });
    return id;
  }

  Future<CategoriaMobiliarioModel?> getCategoria(int categoriaId) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'CategoriasMobiliario',
      where: 'categoria_id = ?',
      whereArgs: [categoriaId],
    );
    if (results.isNotEmpty) {
      return CategoriaMobiliarioModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<CategoriaMobiliarioModel>> getCategorias() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('CategoriasMobiliario');
    return results.map((categoria) => CategoriaMobiliarioModel.fromMap(categoria)).toList();
  }

  Future<int> updateCategoria(CategoriaMobiliarioModel categoria) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'CategoriasMobiliario',
      {
        'categoria_id': categoria.categoria_id,
        'nombre_categoria': categoria.nombre_categoria,
      },
      where: 'categoria_id = ?',
      whereArgs: [categoria.categoria_id],
    );
  }

  Future<int> deleteCategoria(int categoriaId) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'CategoriasMobiliario',
      where: 'categoria_id = ?',
      whereArgs: [categoriaId],
    );
  }
}
