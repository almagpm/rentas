import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rentas/database/evento_database.dart';
import 'package:rentas/model/evento_model.dart';
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
      body: Scaffold(
        appBar: AppBar(
          title: Text(
            'Eventos',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue[900],
        ),
        body: Container(
          color: Colors.blue[900],
          child: Column(children: [
            TableCalendar(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              daysOfWeekHeight: 20,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              locale: 'es_ES',
              headerStyle: HeaderStyle(
                formatButtonVisible:
                    false, // Oculta el botón de cambio de formato
                titleCentered:
                    true, // Centra el título (día de la semana y fecha)
                formatButtonTextStyle: TextStyle().copyWith(
                    color: Colors.white,
                    fontSize: 15.0), // Estilo del botón de cambio de formato
                formatButtonShowsNext:
                    false, // No muestra el botón de cambio de formato siguiente
                titleTextStyle: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white), // Estilo del texto del título

                titleTextFormatter: (date, _) =>
                    '${DateFormat('MMMM').format(date)}', // Formato del texto del título (día de la semana y fecha)
                // Otros estilos...
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white),
                  weekendStyle: TextStyle(color: Colors.white)),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.white),
                selectedDecoration:
                    BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              ),
              selectedDayPredicate: (day) {
                // Use `selectedDayPredicate` to determine which day is currently selected.
                // If this returns true, then `day` will be marked as selected.

                // Using `isSameDay` is recommended to disregard
                // the time-part of compared DateTime objects.
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  // Call `setState()` when updating the selected day
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                // No need to call `setState()` here
                _focusedDay = focusedDay;
              },
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50)),
                    color: Colors.white),
                child: FutureBuilder(
                  future:
                  //eventosDB!.getEventos(),
                  eventosDB!.getEventosByFecha(_selectedDay.toString().split(' ')[0]),
                  builder:
                      (context, AsyncSnapshot<List<EventoModel>> snapshot) {
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
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                      //color: Colors.grey[100],
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(20),
                                          topLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10))),
                                  child: Column(children: [
                                    Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot
                                                .data![index].nombre!,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.timer_sharp),
                                              Text(snapshot
                                                  .data![index].fecha_evento!.split(' ')[1])
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
                                            bottomRight: Radius.circular(20)),
                                      ),
                                    )
                                  ]));
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
            )
          ]),
        ),
      ),
      //bottomNavigationBar: NavigationBarApp(),
    );
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256), // Valor aleatorio para el componente rojo (0-255)
      random.nextInt(256), // Valor aleatorio para el componente verde (0-255)
      random.nextInt(256), // Valor aleatorio para el componente azul (0-255)
      1.0, // Opacidad (0.0 - 1.0)
    );
  }
}
