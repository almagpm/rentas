import 'package:rentas/database/database_provider.dart';
import 'package:rentas/model/mobiliario_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MobiliarioDatabase {
  Future<int> insertMobiliario(MobiliarioModel mobiliario) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('Mobiliario', {
      'mobiliario_id': mobiliario.mobiliario_id,
      'categoria_id': mobiliario.categoria_id,
      'nombre_mobiliario': mobiliario.nombre_mobiliario,
    });
    return id;
  }

  Future<MobiliarioModel?> getMobiliario(int mobiliarioId) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'Mobiliario',
      where: 'mobiliario_id = ?',
      whereArgs: [mobiliarioId],
    );
    if (results.isNotEmpty) {
      return MobiliarioModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<MobiliarioModel>> getMobiliarioByCategoria(int idCategoria) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'Mobiliario',
      where: 'categoria_id = ?',
      whereArgs: [idCategoria],
    );
    return results.map((mobiliario) => MobiliarioModel.fromMap(mobiliario)).toList();
  }
  

  Future<List<MobiliarioModel>> getMobiliarios() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('Mobiliario');
    return results.map((mobiliario) => MobiliarioModel.fromMap(mobiliario)).toList();
  }

  Future<int> updateMobiliario(MobiliarioModel mobiliario) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'Mobiliario',
      {
        'mobiliario_id': mobiliario.mobiliario_id,
        'categoria_id': mobiliario.categoria_id,
        'nombre_mobiliario': mobiliario.nombre_mobiliario,
      },
      where: 'mobiliario_id = ?',
      whereArgs: [mobiliario.mobiliario_id],
    );
  }

  Future<int> deleteMobiliario(int mobiliarioId) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'Mobiliario',
      where: 'mobiliario_id = ?',
      whereArgs: [mobiliarioId],
    );
  }
}
