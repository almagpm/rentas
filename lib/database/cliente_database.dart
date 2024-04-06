import 'package:rentas/database/database_provider.dart';
import 'package:rentas/model/cliente_model.dart';
import 'package:sqflite/sqflite.dart';

class ClienteDatabase {
  Future<int> insertCliente(ClienteModel cliente) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('Clientes', {
      'cliente_id': cliente.cliente_id,
      'nombre': cliente.nombre,
      'correo': cliente.correo,
      'telefono': cliente.telefono,
    });
    return id;
  }

  Future<ClienteModel?> getCliente(int clienteId) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'Clientes',
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
    );
    if (results.isNotEmpty) {
      return ClienteModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<ClienteModel>> getClientes() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('Clientes');
    return results.map((cliente) => ClienteModel.fromMap(cliente)).toList();
  }

  Future<int> updateCliente(ClienteModel cliente) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'Clientes',
      {
        'cliente_id': cliente.cliente_id,
        'nombre': cliente.nombre,
        'correo': cliente.correo,
        'telefono': cliente.telefono,
      },
      where: 'cliente_id = ?',
      whereArgs: [cliente.cliente_id],
    );
  }

  Future<int> deleteCliente(int clienteId) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'Clientes',
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
    );
  }
}
