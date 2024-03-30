import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rentas/database/detalle_renta_database.dart';
import 'package:rentas/database/evento_database.dart';
import 'package:rentas/database/mobiliario_database.dart';
import 'package:rentas/model/detalle_renta_model.dart';
import 'package:rentas/model/evento_model.dart';
import 'package:rentas/model/mobiliario_model.dart';
import 'package:rentas/screens/navigation_bar.dart';
import 'package:table_calendar/table_calendar.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  EventoDatabase? eventosDB;

  @override
  void initState() {
    super.initState();
    eventosDB = new EventoDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Eventos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        color: Colors.blue[900],
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              daysOfWeekHeight: 20,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              locale: 'es_ES',
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                formatButtonTextStyle: TextStyle().copyWith(
                  color: Colors.white,
                  fontSize: 15.0,
                ),
                formatButtonShowsNext: false,
                titleTextStyle: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
                titleTextFormatter: (date, _) =>
                    '${DateFormat('MMMM').format(date)}',
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white),
                weekendStyle: TextStyle(color: Colors.white),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.white),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                  color: Colors.white,
                ),
                child: FutureBuilder(
                  future: eventosDB!.getEventosByFecha(
                      _selectedDay.toString().split(' ')[0]),
                  builder: (context, AsyncSnapshot<List<EventoModel>> snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      if (snapshot.hasData) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 50, right: 50, top: 40, bottom: 20),
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _mostrarModalEvento(snapshot.data![index]);
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      topLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(15),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              snapshot.data![index].nombre!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Icon(Icons.timer_sharp),
                                                Text(
                                                  snapshot.data![index]
                                                      .fecha_evento!
                                                      .split(' ')[1],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: getRandomColor(),
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  void _mostrarModalEvento(EventoModel evento) async {
  // Almacenar una referencia al contexto
  BuildContext modalContext = context;

  // Obtener detalles del evento
  DetalleRentaDatabase detalleRentaDB = DetalleRentaDatabase();
  List<DetalleRentaModel> detallesRenta =
      await detalleRentaDB.getDetallesRentaByRentaId(evento.renta_id!);

  showModalBottomSheet(
    context: modalContext,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                evento.nombre!,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Fecha: ${evento.fecha_evento!.split(' ')[0]}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Detalles del evento: ${evento.detalles_evento}',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Detalles de la renta:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              // Mostrar detalles de la renta
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // Evitar el desplazamiento de la lista dentro de ListView
                itemCount: detallesRenta.length,
                itemBuilder: (context, index) {
                  int? mobiliarioId = detallesRenta[index].mobiliario_id; // Cambiar el tipo de mobiliarioId a int?
                  return FutureBuilder(
                    future: MobiliarioDatabase().getMobiliario(mobiliarioId!),
                    builder: (context, AsyncSnapshot<MobiliarioModel?> snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Divider(),
                            Text(
                              'Mobiliario ID: $mobiliarioId',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Cantidad: ${detallesRenta[index].cantidad}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Nombre: ${snapshot.data!.nombre_mobiliario}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Divider(),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(modalContext).pop();
                },
                child: Text('Regresar a la lista de eventos'),
              ),
            ],
          ),
        ),
      );
    },
  );
}






}
