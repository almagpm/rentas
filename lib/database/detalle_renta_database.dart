import 'package:rentas/database/database_provider.dart';
import 'package:rentas/model/detalle_renta_model.dart';
import 'package:sqflite/sqflite.dart';

class DetalleRentaDatabase {
  Future<int> insertDetalleRenta(DetalleRentaModel detalleRenta) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('DetalleRentas', {
      'renta_id': detalleRenta.renta_id,
      'mobiliario_id': detalleRenta.mobiliario_id,
      'cantidad': detalleRenta.cantidad,
    });
    return id;
  }

  Future<DetalleRentaModel?> getDetalleRenta(int detalleId) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'Detalle_Rentas',
      where: 'detalle_id = ?',
      whereArgs: [detalleId],
    );
    if (results.isNotEmpty) {
      return DetalleRentaModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<DetalleRentaModel>> getDetallesRenta() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('Detalle_Rentas');
    return results.map((detalleRenta) => DetalleRentaModel.fromMap(detalleRenta)).toList();
  }

  Future<int> updateDetalleRenta(DetalleRentaModel detalleRenta) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'Detalle_Rentas',
      {
        'detalle_id': detalleRenta.detalle_id,
        'renta_id': detalleRenta.renta_id,
        'mobiliario_id': detalleRenta.mobiliario_id,
        'cantidad': detalleRenta.cantidad,
      },
      where: 'detalle_id = ?',
      whereArgs: [detalleRenta.detalle_id],
    );
  }

  Future<int> deleteDetalleRenta(int detalleId) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'Detalle_Rentas',
      where: 'detalle_id = ?',
      whereArgs: [detalleId],
    );
  }

  Future<int> deleteDetalleRentaByIdRenta(int rentaId) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'DetalleRentas',
      where: 'renta_id = ?',
      whereArgs: [rentaId],
    );
  }

  Future<List<DetalleRentaModel>> getDetallesRentaByRentaId(int rentaId) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'DetalleRentas',
      where: 'renta_id = ?',
      whereArgs: [rentaId],
    );
    return results.map((detalleRenta) => DetalleRentaModel.fromMap(detalleRenta)).toList();
  }
}
