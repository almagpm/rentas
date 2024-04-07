import 'package:flutter/material.dart';
import 'package:rentas/screens/agregar_renta_screen.dart';
import 'package:rentas/screens/eventos_screen.dart';
import 'package:rentas/screens/historial_rentas_screen.dart'; // Importar la pantalla HistorialRentasScreen
import 'package:rentas/screens/detalle_renta_screen.dart';
import 'package:rentas/screens/navigation_bar.dart'; // Importar la pantalla DetalleRentaScreen
import 'package:intl/date_symbol_data_local.dart';
import 'package:rentas/settings/notification_helper.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  initializeDateFormatting('es_ES', null).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}); // Elimina const aquí

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: NavigationBarApp(),
      //initialRoute: '/eventos', // Ruta inicial
      routes: {
        '/nav': (context) => NavigationBarApp(),
        '/eventos': (context) => EventosScreen(),
        '/historial': (context) => HistorialRentasScreen(), // Ruta para la pantalla de historial de rentas
        '/detalleR': (context) => DetalleRentaScreen(), // Ruta para la pantalla de detalle de renta
        '/agregarRenta': (context)=> AgregarRentaScreen(),
      },
    );
  }
}
