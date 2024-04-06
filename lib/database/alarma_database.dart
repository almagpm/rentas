import 'package:rentas/database/database_provider.dart';
import 'package:rentas/model/alarma_model.dart';
import 'package:sqflite/sqflite.dart';

class AlarmaDatabase {
  Future<int> insertAlarma(AlarmaModel alarma) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('Alarmas', {
      'alarma_id': alarma.alarma_id,
      'renta_id': alarma.renta_id,
      'fecha_alarma': alarma.fecha_alarma?.toIso8601String(),
      'descripcion': alarma.descripcion,
    });
    return id;
  }

  Future<AlarmaModel?> getAlarma(int alarmaId) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'Alarmas',
      where: 'alarma_id = ?',
      whereArgs: [alarmaId],
    );
    if (results.isNotEmpty) {
      return AlarmaModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<AlarmaModel>> getAlarmas() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('Alarmas');
    return results.map((alarma) => AlarmaModel.fromMap(alarma)).toList();
  }

  Future<int> updateAlarma(AlarmaModel alarma) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'Alarmas',
      {
        'alarma_id': alarma.alarma_id,
        'renta_id': alarma.renta_id,
        'fecha_alarma': alarma.fecha_alarma?.toIso8601String(),
        'descripcion': alarma.descripcion,
      },
      where: 'alarma_id = ?',
      whereArgs: [alarma.alarma_id],
    );
  }

  Future<int> deleteAlarma(int alarmaId) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'Alarmas',
      where: 'alarma_id = ?',
      whereArgs: [alarmaId],
    );
  }
}
