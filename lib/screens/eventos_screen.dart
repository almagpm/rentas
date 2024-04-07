import 'dart:async';
import 'dart:math';

import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:intl/intl.dart';
import 'package:rentas/database/detalle_renta_database.dart';
import 'package:rentas/database/evento_database.dart';
import 'package:rentas/database/mobiliario_database.dart';
import 'package:rentas/database/renta_database.dart';
import 'package:rentas/model/detalle_renta_model.dart';
import 'package:rentas/model/evento_model.dart';
import 'package:rentas/model/mobiliario_model.dart';
import 'package:rentas/model/renta_model.dart';
import 'package:rentas/screens/utils.dart';
import 'package:rentas/settings/notification_helper.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:rentas/settings/app_value_notifier.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({Key? key}) : super(key: key);

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  EventoDatabase? eventosDB;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel platform =
      MethodChannel('com.example.app/timezone');

  late tz.Location
      _local; // Variable para almacenar la ubicación de la zona horaria

  @override
  void initState() {
    initializeNotifications();
    configureLocalTimeZone(); // Inicializar la zona horaria
    eventosDB = EventoDatabase();
    cargarEventos();
    _selectedDay = _focusedDay;

    super.initState();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return kEvents[day] ?? [];
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    // Establecer la zona horaria de México (América/Mexico_City)
    _local = tz.getLocation(
        'America/Mexico_City'); // Obtener la ubicación de la zona horaria de México
    tz.setLocalLocation(
        _local); // Establecer la ubicación local en la zona horaria de México
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
      body: ValueListenableBuilder(
        valueListenable: AppValueNotifier.banEvents,
        builder: (context, value, _) {
          return Container(
            color: Colors.blue[900],
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  daysOfWeekHeight: 20,
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  eventLoader: _getEventsForDay,
                  locale: 'es_ES',
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    formatButtonTextStyle: const TextStyle().copyWith(
                      color: Colors.white,
                      fontSize: 15.0,
                    ),
                    formatButtonShowsNext: false,
                    titleTextStyle: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                    titleTextFormatter: (date, _) =>
                        '${DateFormat('MMMM').format(date)}',
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: Colors.white),
                    weekendStyle: TextStyle(color: Colors.white),
                  ),
                  calendarStyle: const CalendarStyle(
                    defaultTextStyle: TextStyle(color: Colors.white),
                    weekendTextStyle: TextStyle(color: Colors.white),
                    markerDecoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
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
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(20),
                                        topLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                            PopupMenuButton<String>(
                                              elevation: 0,
                                              shadowColor: Colors.black,
                                              onSelected:
                                                  (String result) async {
                                                if (result == "Ver") {
                                                  _mostrarModalEvento(
                                                      snapshot.data![index]);
                                                }
                                                if (result == "Editar") {
                                                  modalEvento(context,
                                                      snapshot.data![index]);
                                                }
                                                if (result == "Eliminar") {
                                                  ArtDialogResponse response =
                                                      await ArtSweetAlert.show(
                                                          barrierDismissible:
                                                              false,
                                                          context: context,
                                                          artDialogArgs: ArtDialogArgs(
                                                              denyButtonText:
                                                                  "Cancelar",
                                                              title:
                                                                  "¿Estás seguro?",
                                                              text:
                                                                  "¡No podrás revertir esta acción!",
                                                              confirmButtonText:
                                                                  "Si, borralo",
                                                              type:
                                                                  ArtSweetAlertType
                                                                      .warning));

                                                  if (response == null) {
                                                    return;
                                                  }

                                                  if (response
                                                      .isTapConfirmButton) {
                                                    kEvents[DateTime.parse(
                                                            snapshot
                                                                .data![index]
                                                                .fecha_evento!)]!
                                                        .removeWhere(
                                                            (element) =>
                                                                element.title ==
                                                                snapshot
                                                                    .data![
                                                                        index]
                                                                    .nombre);
                                                    eventosDB!
                                                        .deleteEvento(snapshot
                                                            .data![index]
                                                            .evento_id!)
                                                        .then((value) {
                                                      if (value > 0) {
                                                        ArtSweetAlert.show(
                                                            context: context,
                                                            artDialogArgs: ArtDialogArgs(
                                                                type:
                                                                    ArtSweetAlertType
                                                                        .success,
                                                                title:
                                                                    "¡Borrado!"));
                                                      }
                                                      AppValueNotifier
                                                              .banEvents.value =
                                                          !AppValueNotifier
                                                              .banEvents.value;
                                                    });
                                                    return;
                                                  }
                                                }
                                              },
                                              itemBuilder:
                                                  (BuildContext context) =>
                                                      <PopupMenuEntry<String>>[
                                                const PopupMenuItem<String>(
                                                  value: "Ver",
                                                  child: Text("Ver"),
                                                ),
                                                const PopupMenuItem<String>(
                                                  value: "Editar",
                                                  child: Text("Editar"),
                                                ),
                                                const PopupMenuItem<String>(
                                                  value: "Eliminar",
                                                  child: Text("Eliminar"),
                                                ),
                                              ],
                                            ),
                                          ],
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn1',
        onPressed: () {
          modalEvento(context, null);
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue[900],
        shape: CircleBorder(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  void modalEvento(context, EventoModel? evento) async {
    final conNombre = TextEditingController();
    final conNombre2 = TextEditingController();
    final conDetalles = TextEditingController();
    final conFecha = TextEditingController();
    final conFecha2 = TextEditingController();
    final conHora = TextEditingController();
    final conRenta = TextEditingController();
    final _keyForm = GlobalKey<FormState>();

    conFecha.text = _selectedDay.toString().split(' ')[0];

    if (evento != null) {
      conNombre.text = evento.nombre!;
      conNombre2.text = evento.nombre!;
      conDetalles.text = evento.detalles_evento!;
      conFecha.text = evento.fecha_evento!.split(' ')[0];
      conFecha2.text = evento.fecha_evento!;
      conHora.text = evento.fecha_evento!.split(' ')[1];
      conRenta.text = evento.renta_id!.toString();
    }

    final txtNombre = TextFormField(
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Necesitas ingresar un nombre del evento';
        }
        return null;
      },
      controller: conNombre,
      decoration: const InputDecoration(
        labelText: 'Nombre',
        prefixIcon: Icon(Icons.event),
        border: UnderlineInputBorder(),
      ),
    );

    final txtDetalles = TextFormField(
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Necesitas una descripción';
        }
        return null;
      },
      controller: conDetalles,
      decoration: const InputDecoration(
        labelText: 'Detalles',
        prefixIcon: Icon(Icons.event_note_outlined),
        border: UnderlineInputBorder(),
      ),
    );

    RentaDatabase rentaDB = RentaDatabase();
    List<RentaModel> rentas = await rentaDB.getRentas();

    final txtRenta = DropdownButtonFormField<String>(
        validator: (value) {
          if (value == null) {
            return 'Necesitas seleccionar una renta';
          }
          return null;
        },
        value: (conRenta.text.isEmpty) ? null : conRenta.text,
        hint: Text('Seleccione una renta'),
        items: rentas.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.renta_id.toString(),
            child: Text(value.renta_id.toString()),
          );
        }).toList(),
        onChanged: (String? value) {
          conRenta.text = value!;
        });

    final txtFecha = TextFormField(
        keyboardType: TextInputType.none,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Necesitas ingresar una fecha';
          }
          return null;
        },
        controller: conFecha,
        decoration: const InputDecoration(
          labelText: 'Fecha',
          prefixIcon: Icon(Icons.date_range_outlined),
          border: UnderlineInputBorder(),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), //get today's date
              firstDate: DateTime(
                  2000), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime(2101));

          if (pickedDate != null) {
            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
            setState(() {
              conFecha.text = formattedDate;
            });
          } else {}
        });

    final txtHora = TextFormField(
        keyboardType: TextInputType.none,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Necesitas ingresar una hora';
          }
          return null;
        },
        controller: conHora,
        decoration: const InputDecoration(
          labelText: 'Hora',
          prefixIcon: Icon(Icons.timer_outlined),
          border: UnderlineInputBorder(),
        ),
        onTap: () async {
          TimeOfDay selectedTime = TimeOfDay.now();
          final pickedTime = await showSpinnerTimePicker(
            context,
            initTime: selectedTime,
          );

          if (pickedTime != null) {
            setState(() {
              selectedTime = pickedTime;
              conHora.text = pickedTime.format(context);
            });
          }
        });

    final space = SizedBox(
      height: 10,
    );

    final btnAgregar = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
        onPressed: () {
          if (_keyForm.currentState!.validate()) {
          final DateTime scheduledDate = DateTime(int.parse(conFecha.text.split('-')[0]),int.parse(conFecha.text.split('-')[1]),int.parse(conFecha.text.split('-')[2])-2,int.parse(conHora.text.split(':')[0]),int.parse(conHora.text.split(':')[1]));
          print(scheduledDate);
          if(DateTime.now().isBefore(scheduledDate)){
            NotificationService().scheduleNotification(
            title: 'Evento próximo',
            body: 'Faltan 2 días para el evento ${conNombre.text}',
            scheduledNotificationDateTime: scheduledDate);
          }
            if (evento == null) {
              EventoModel event = EventoModel(
                  nombre: conNombre.text,
                  detalles_evento: conDetalles.text,
                  fecha_evento: conFecha.text + ' ' + conHora.text,
                  renta_id: int.parse(conRenta.text));
              if (kEvents[DateTime.parse(conFecha.text)] == null) {
                kEvents[DateTime.parse(conFecha.text)] = [];
              }
              kEvents[DateTime.parse(conFecha.text)]!
                  .add(Event(conNombre.text));

              eventosDB!.insertEvento(event).then((value) {
                Navigator.pop(context);
                String msj = "";
                var snackbar;
                if (value > 0) {
                  AppValueNotifier.banEvents.value =
                      !AppValueNotifier.banEvents.value;
                  msj = "Evento insertado";
                  snackbar = SnackBar(
                    content: Text(msj),
                    backgroundColor: Colors.green,
                  );
                } else {
                  msj = "ocurrio un error";
                  snackbar = SnackBar(
                    content: Text(msj),
                    backgroundColor: Colors.red,
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              });
            } else {
              EventoModel event = EventoModel(
                  evento_id: evento.evento_id,
                  nombre: conNombre.text,
                  detalles_evento: conDetalles.text,
                  fecha_evento: conFecha.text + ' ' + conHora.text,
                  renta_id: int.parse(conRenta.text));
              kEvents[DateTime.parse(conFecha2.text)]!
                  .removeWhere((element) => element.title == conNombre2.text);
              if (kEvents[DateTime.parse(conFecha.text)] == null) {
                kEvents[DateTime.parse(conFecha.text)] = [];
              }
              kEvents[DateTime.parse(conFecha.text)]!
                  .add(Event(conNombre.text));
              eventosDB!.updateEvento(event).then((value) {
                Navigator.pop(context);
                String msj = "";
                var snackbar;
                if (value > 0) {
                  AppValueNotifier.banEvents.value =
                      !AppValueNotifier.banEvents.value;
                  msj = "Evento actualizado";
                  snackbar = SnackBar(
                    content: Text(msj),
                    backgroundColor: Colors.green,
                  );
                } else {
                  msj = "ocurrio un error";
                  snackbar = SnackBar(
                    content: Text(msj),
                    backgroundColor: Colors.red,
                  );
                }
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              });
            }
          }
        },
        icon: const Icon(Icons.save),
        label: const Text('Guardar'));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Colors.white,
          content: Form(
            key: _keyForm,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evento',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  //padding: EdgeInsets.all(5),
                  child: txtNombre,
                ),
                space,
                Container(
                  //padding: EdgeInsets.all(5),
                  child: txtDetalles,
                ),
                space,
                space,
                Text(
                  'Renta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  //padding: EdgeInsets.all(5),
                  child: txtRenta,
                ),
                space,
                space,
                Text(
                  'Horario',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        //padding: EdgeInsets.all(5),
                        child: txtFecha,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        //padding: EdgeInsets.all(5),
                        child: txtHora,
                      ),
                    ),
                  ],
                ),
                space,
                Row(
                  children: [
                    Expanded(
                      child: btnAgregar,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarModalEvento(EventoModel evento) async {
    // Obtener la fecha dos días antes del evento
    DateTime fechaEvento = DateTime.parse(evento.fecha_evento!);
    DateTime twoDaysBeforeEvent = fechaEvento.subtract(Duration(days: 2));

    // Almacenar una referencia al contexto
    BuildContext modalContext = context;

    // Obtener detalles del evento
    DetalleRentaDatabase detalleRentaDB = DetalleRentaDatabase();
    List<DetalleRentaModel> detallesRenta =
        await detalleRentaDB.getDetallesRentaByRentaId(evento.renta_id!);

    // Enviar notificación instantánea

    showModalBottomSheet(
      context: modalContext,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          // SingleChildScrollView para permitir scroll
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications),
                      onPressed: () {
                        _enviarNotificacionInstantanea(twoDaysBeforeEvent);
                      },
                    ),
                  ],
                ),
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
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: detallesRenta.length,
                  itemBuilder: (context, index) {
                    int? mobiliarioId = detallesRenta[index].mobiliario_id;
                    return FutureBuilder(
                      future: MobiliarioDatabase().getMobiliario(mobiliarioId!),
                      builder:
                          (context, AsyncSnapshot<MobiliarioModel?> snapshot) {
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

  Future<void> _enviarNotificacionInstantanea(
      DateTime fechaNotificacion) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'instant_notification_channel_id',
      'Instant Notification',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Notificación Instantánea',
      'Notificación programada para el día: ${DateFormat('dd-MM-yyyy').format(fechaNotificacion)}',
      platformChannelSpecifics,
    );
  }
}
