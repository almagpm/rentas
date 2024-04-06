import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  static final String dbName = 'RentasDB';
  static final int dbVersion = 1;
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    return _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    Directory folder = await getApplicationDocumentsDirectory();
    String pathDB = join(folder.path, dbName);
    return openDatabase(
      pathDB,
      version: dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Clientes (
            cliente_id INTEGER PRIMARY KEY,
            nombre TEXT,
            correo TEXT,
            telefono TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE CategoriasMobiliario(
            categoria_id INTEGER PRIMARY KEY,
            nombre_categoria TEXT
          )
        ''');
        
        await db.execute('''
          CREATE TABLE Rentas(
            renta_id INTEGER PRIMARY KEY,
            fecha_inicio TEXT,
            fecha_fin TEXT,
            estatus TEXT,
            cliente_id INTEGER,
            FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id)
          )
        ''');

        await db.execute('''
          CREATE TABLE DetalleRentas(
            detalle_id INTEGER PRIMARY KEY,
            renta_id INTEGER,
            mobiliario_id INTEGER,
            cantidad INTEGER,
            FOREIGN KEY (renta_id) REFERENCES Rentas(renta_id),
            FOREIGN KEY (mobiliario_id) REFERENCES Mobiliario(mobiliario_id)
          )
        ''');

        await db.execute('''
          CREATE TABLE Eventos(
            evento_id INTEGER PRIMARY KEY,
            renta_id INTEGER,
            nombre TEXT,
            fecha_evento TEXT,
            detalles_evento TEXT,
            FOREIGN KEY (renta_id) REFERENCES Rentas(renta_id)
          )
        ''');

        await db.execute('''
          CREATE TABLE Mobiliario(
            mobiliario_id INTEGER PRIMARY KEY,
            categoria_id INTEGER,
            nombre_mobiliario TEXT,
            FOREIGN KEY (categoria_id) REFERENCES CategoriasMobiliario(categoria_id)
          )
        ''');

        await db.execute('''
          CREATE TABLE Alarmas(
            alarma_id INTEGER PRIMARY KEY,
            renta_id INTEGER,
            fecha_alarma TEXT,
            descripcion TEXT,
            FOREIGN KEY (renta_id) REFERENCES Rentas(renta_id)
          )
        ''');

        //INSERCIONES 
        // Insertar datos en la tabla Clientes
        await db.execute('''
          INSERT INTO Clientes (nombre, correo, telefono) VALUES
          ('Cliente 1', 'cliente1@example.com', '1234567890'),
          ('Cliente 2', 'cliente2@example.com', '0987654321'),
          ('Cliente 3', 'cliente3@example.com', '5555555555'),
          ('Cliente 4', 'cliente4@example.com', '9876543210'),
          ('Cliente 5', 'cliente5@example.com', '1231231234')
        ''');

        // Insertar datos en la tabla CategoriasMobiliario
        await db.execute('''
          INSERT INTO CategoriasMobiliario (nombre_categoria) VALUES
          ('Categoria 1'),
          ('Categoria 2'),
          ('Categoria 3'),
          ('Categoria 4'),
          ('Categoria 5')
        ''');

        // Insertar datos en la tabla Rentas
        await db.execute('''
          INSERT INTO Rentas (fecha_inicio, fecha_fin, estatus, cliente_id) VALUES
          ('2024-03-01', '2024-03-05', 'Cumplida', 1),
          ('2024-03-02', '2024-03-06', 'Cumplida', 2),
          ('2024-03-03', '2024-03-07', 'Cancelada', 3),
          ('2024-03-04', '2024-03-08', 'Proceso', 4),
          ('2024-03-04', '2024-03-08', 'Cancelada', 5),
          ('2024-03-05', '2024-03-09', 'Cumplida', 6)
        ''');

        // Insertar datos en la tabla DetalleRentas
        await db.execute('''
          INSERT INTO DetalleRentas (renta_id, mobiliario_id, cantidad) VALUES
          (1, 1, 2),
          (2, 2, 3),
          (3, 3, 1),
          (4, 4, 4),
          (4, 5, 4),
          (5, 5, 2)
        ''');

        // Insertar datos en la tabla Eventos
        await db.execute('''
          INSERT INTO Eventos (renta_id, nombre,fecha_evento, detalles_evento) VALUES
          (1, 'Fiesta de Cumpleaños', '2024-03-30 15:00:00', 'Celebración del cumpleaños de Ana en su casa.'),
          (2, 'Reunión de Trabajo', '2024-04-01 17:00:00', ' Reunión para discutir los planes de proyecto para el próximo trimestre.'),
          (3, 'Concierto', '2024-03-05 20:00:00', 'Asistir al concierto de la banda favorita en el estadio local'),
          (4, 'Entrega de Proyecto', '2024-04-10 10:00:00', 'Fecha límite para entregar el proyecto de desarrollo de software.'),
          (5, 'Cena Familiar', '2024-04-10 12:00:00', 'Cena especial con la familia para celebrar el aniversario de bodas.'),
          (1, 'Notificacion programada', '2024-04-02 12:00:00', 'Para saber si si llegan las notificaciones.')
        ''');

        // Insertar datos en la tabla Mobiliario
        await db.execute('''
          INSERT INTO Mobiliario (categoria_id, nombre_mobiliario) VALUES
          (1, 'Mobiliario 1'),
          (2, 'Mobiliario 2'),
          (3, 'Mobiliario 3'),
          (4, 'Mobiliario 4'),
          (5, 'Mobiliario 5'),
          (1, 'Mobiliario 6'),
          (1, 'Mobiliario 7'),
          (1, 'Mobiliario 8'),
          (2, 'Mobiliario 9'),
          (2, 'Mobiliario 10')
        ''');

        // Insertar datos en la tabla Alarmas
        await db.execute('''
          INSERT INTO Alarmas (renta_id, fecha_alarma, descripcion) VALUES
          (1, '2024-03-02', 'Alarma 1 Descripcion'),
          (2, '2024-03-03', 'Alarma 2 Descripcion'),
          (3, '2024-03-04', 'Alarma 3 Descripcion'),
          (4, '2024-03-05', 'Alarma 4 Descripcion'),
          (5, '2024-03-06', 'Alarma 5 Descripcion')
        ''');

      },
    );
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}


