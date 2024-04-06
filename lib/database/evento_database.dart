import 'package:rentas/database/database_provider.dart';
import 'package:rentas/model/evento_model.dart';
import 'package:sqflite/sqflite.dart';

class EventoDatabase {
  Future<int> insertEvento(EventoModel evento) async {
    final db = await DatabaseProvider().database;
    int id = await db.insert('Eventos', {
      'renta_id': evento.renta_id,
      'nombre': evento.nombre,
      'fecha_evento': evento.fecha_evento,
      'detalles_evento': evento.detalles_evento,
    });
    return id;
  }

  Future<EventoModel?> getEvento(int eventoId) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query(
      'Eventos',
      where: 'evento_id = ?',
      whereArgs: [eventoId],
    );
    if (results.isNotEmpty) {
      return EventoModel.fromMap(results.first);
    } else {
      return null;
    }
  }

  Future<List<EventoModel>> getEventos() async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('Eventos');
    return results.map((evento) => EventoModel.fromMap(evento)).toList();
  }

  Future<List<EventoModel>> getEventosByFecha(String fecha) async {
    final db = await DatabaseProvider().database;
    List<Map<String, dynamic>> results = await db.query('Eventos',where:'SUBSTR(fecha_evento, 1, 10) LIKE ?',whereArgs: [fecha],orderBy: 'fecha_evento');
    return results.map((evento) => EventoModel.fromMap(evento)).toList();
  }

  Future<int> updateEvento(EventoModel evento) async {
    final db = await DatabaseProvider().database;
    return await db.update(
      'Eventos',
      {
        'evento_id': evento.evento_id,
        'renta_id': evento.renta_id,
        'nombre': evento.nombre,
        'fecha_evento': evento.fecha_evento,
        'detalles_evento': evento.detalles_evento,
      },
      where: 'evento_id = ?',
      whereArgs: [evento.evento_id],
    );
  }

  Future<int> deleteEvento(int eventoId) async {
    final db = await DatabaseProvider().database;
    return await db.delete(
      'Eventos',
      where: 'evento_id = ?',
      whereArgs: [eventoId],
    );
  }
}
