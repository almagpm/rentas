import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rentas/database/cliente_database.dart';
import 'package:rentas/database/detalle_renta_database.dart';
import 'package:rentas/database/mobiliario_database.dart';
import 'package:rentas/database/renta_database.dart';
import 'package:rentas/model/cliente_model.dart';
import 'package:rentas/model/detalle_renta_model.dart';
import 'package:rentas/model/mobiliario_model.dart';
import 'package:rentas/model/renta_model.dart';

class DetalleRentaScreen extends StatefulWidget {
  const DetalleRentaScreen({Key? key});

  @override
  State<DetalleRentaScreen> createState() => _DetalleRentaScreenState();
}

class _DetalleRentaScreenState extends State<DetalleRentaScreen> {
  int? rentaId;
  RentaModel? _renta;
  List<DetalleRentaModel>? _detallesRenta;
  List<MobiliarioModel>? _mobiliarios;
  ClienteDatabase? clienteDB;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _showLoading();
    clienteDB = ClienteDatabase();
  }

  void _showLoading() async {
    await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    rentaId = ModalRoute.of(context)?.settings.arguments as int?;
    if (rentaId != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    _renta = await RentaDatabase().getRenta(rentaId!);
    _detallesRenta =
        await DetalleRentaDatabase().getDetallesRentaByRentaId(rentaId!);
    _mobiliarios = [];
    for (var detalle in _detallesRenta!) {
      var mobiliario =
          await MobiliarioDatabase().getMobiliario(detalle.mobiliario_id!);
      if (mobiliario != null) {
        _mobiliarios!.add(mobiliario);
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final space = SizedBox(
      height: 15,
    );
    if (rentaId != null) {
      if (_renta == null || _detallesRenta == null || _detallesRenta!.isEmpty) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Detalle de Renta'),
          ),
          body: Center(
            child: _isLoading
                ? CircularProgressIndicator()
                : Text("No se encontraron detalles"),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            title: Text(
              'Detalle de Renta',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.blue[900],
          ),
          body: Stack(
            children: [
              Container(
                color: Colors.blue[900],
              ),
              Positioned(
                top: 100,
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(70),
                        topRight: Radius.circular(70)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                        ),
                        Center(
                          child: Text(
                            'Información de la Renta',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                color: Colors
                                    .black), // Tamaño y color de la fuente
                          ),
                        ),
                        space,
                        _buildTagStatus(_renta!.estatus!),
                        space,
                        Row(
                          children: [
                            Icon(Icons.timer_outlined),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Fecha inicio: ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                                '${_renta!.fecha_inicio.toString().split(' ')[0]}'),
                          ],
                        ),
                        space,
                        Row(
                          children: [
                            Icon(Icons.timer_outlined),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Fecha fin: ',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            Text(
                                '${_renta!.fecha_fin.toString().split(' ')[0]}'),
                          ],
                        ),
                        space,
                        FutureBuilder(
                            future: clienteDB!.getCliente(_renta!.cliente_id!),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Row(
                                  children: [
                                    Icon(Icons.person),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      'Cliente: ',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Text('${snapshot.data!.nombre}'),
                                  ],
                                );
                              } else {
                                return Text('');
                              }
                            }),
                        SizedBox(height: 20),
                        Text(
                          'Mobiliario rentado',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600]),
                        ),
                        space,
                        Expanded(
                          child: ListView.separated(
                            itemCount: _detallesRenta!.length,
                            separatorBuilder: (context, index) => Divider(),
                            itemBuilder: (context, index) {
                              final detalle = _detallesRenta![index];
                              final mobiliario = _mobiliarios![index];
                              return Container(
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey[50],
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.indeterminate_check_box,
                                        size: 30,
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mobiliario.nombre_mobiliario!,
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text('Cantidad: ${detalle.cantidad}')
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 1),
                  child: AspectRatio(
                    aspectRatio: 2,
                    child: _buildLottieAnimation(_renta!.estatus!),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 1, // índice seleccionado en el BottomNavigationBar
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.event),
                label: 'Eventos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: 'Historial',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacementNamed(context, '/nav');
              }
            },
          ),
        );
      }
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalle de Renta'),
        ),
        body: Center(
          child: Text(
            'ID de renta no válido',
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    }
  }

  Widget _buildLottieAnimation(String status) {
    String animationAsset;
    switch (status) {
      case 'Cumplida':
        animationAsset =
            'https://lottie.host/fed494d7-a6c9-4cbe-9ad5-9b1ea45ea035/TlzyFQpBUU.json';
        break;
      case 'Proceso':
        animationAsset =
            'https://lottie.host/19e8ddbc-31af-4a98-8295-b0ec81f1c1e3/eI7PSPfuCF.json';
        break;
      case 'Cancelada':
        animationAsset =
            'https://lottie.host/3d83dfa8-37b0-4b90-81c1-933546b3ed80/xLM87KOQ5V.json';
        break;
      default:
        animationAsset =
            ''; // Definir una animación predeterminada o un mensaje de error
    }

    if (animationAsset.isNotEmpty) {
      return Transform.scale(
        scale: 1,
        child: Lottie.network(animationAsset),
      );
    } else {
      return Text('No se encontró la animación correspondiente');
    }
  }

  Widget _buildTagStatus(String status) {
    late final Color _statusColor;
    late final Color _backgroundcolorStatus;
    switch (status) {
      case 'Cumplida':
        _statusColor = Colors.green[700]!;
        _backgroundcolorStatus = Colors.green[50]!;
        break;
      case 'Proceso':
        _statusColor = Colors.orange[600]!;
        _backgroundcolorStatus = Colors.orange[50]!;
        break;
      case 'Cancelada':
        _statusColor = Colors.red[700]!;
        _backgroundcolorStatus = Colors.red[50]!;
        break;
    }

    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: _backgroundcolorStatus,
            borderRadius: BorderRadius.circular(50)),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8, bottom: 8, left: 20, right: 20),
          child: Text(
            status,
            style: TextStyle(color: _statusColor),
          ),
        ),
      ),
    );
  }
}
