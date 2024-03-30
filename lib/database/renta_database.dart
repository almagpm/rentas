import 'package:rentas/database/database_provider.dart';
import 'package:rentas/model/renta_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RentaDatabase {
  Future<int> insertRenta(RentaModel renta) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('Rentas', {
      'renta_id': renta.renta_id,
      'fecha_inicio': renta.fecha_inicio.toString(),
      'fecha_fin': renta.fecha_fin.toString(),
      'estatus': renta.estatus,
      'cliente_id': renta.cliente_id,
    });
    return id;
  }

  Future<RentaModel?> getRenta(int rentaId) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'Rentas',
      where: 'renta_id = ?',
      whereArgs: [rentaId],
    );
    if (results.isNotEmpty) {
      return RentaModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<RentaModel>> getRentas() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('Rentas');
    return results.map((renta) => RentaModel.fromMap(renta)).toList();
  }

  Future<int> updateRenta(RentaModel renta) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'Rentas',
      {
        'renta_id': renta.renta_id,
        'fecha_inicio': renta.fecha_inicio.toString(),
        'fecha_fin': renta.fecha_fin.toString(),
        'estatus': renta.estatus,
        'cliente_id': renta.cliente_id,
      },
      where: 'renta_id = ?',
      whereArgs: [renta.renta_id],
    );
  }

  Future<int> deleteRenta(int rentaId) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'Rentas',
      where: 'renta_id = ?',
      whereArgs: [rentaId],
    );
  }

  Future<List<RentaModel>> getRentasByCliente(int clienteId) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'Rentas',
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
    );
    return results.map((renta) => RentaModel.fromMap(renta)).toList();
  }

  Future<List<RentaModel>> getRentasByStatus(String status) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'Rentas',
      where: 'estatus = ?',
      whereArgs: [status],
    );
    return results.map((renta) => RentaModel.fromMap(renta)).toList();
  }

}
