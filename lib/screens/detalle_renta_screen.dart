import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rentas/database/detalle_renta_database.dart';
import 'package:rentas/database/mobiliario_database.dart';
import 'package:rentas/database/renta_database.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _showLoading();
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
    _detallesRenta = await DetalleRentaDatabase().getDetallesRentaByRentaId(rentaId!);
    _mobiliarios = [];
    for (var detalle in _detallesRenta!) {
      var mobiliario = await MobiliarioDatabase().getMobiliario(detalle.mobiliario_id!);
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

    if (rentaId != null) {
      if (_renta == null || _detallesRenta == null || _detallesRenta!.isEmpty) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Detalle de Renta'),
          ),
          body: Center(
            child: _isLoading ? CircularProgressIndicator() : Text("No se encontraron detalles"),
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text('Detalle de Renta'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Color.fromARGB(82, 146, 159, 190),
                  borderRadius: BorderRadius.circular(30), // Bordes redondeados
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // Centra el contenido horizontalmente
                  children: [
                    Text(
                      'Información de la Renta',
                      style: TextStyle(fontSize: 24, color: Colors.black), // Tamaño y color de la fuente
                    ),
                    SizedBox(height: 10), // Espacio entre elementos
                    Text(
                      'Folio: ${_renta!.renta_id}',
                      style: TextStyle(fontSize: 14, color: Colors.black), // Tamaño y color de la fuente
                    ),
                    Text(
                      'Fecha inicio: ${_renta!.fecha_inicio}',
                      style: TextStyle(fontSize: 14, color: Colors.black), // Tamaño y color de la fuente
                    ),
                    Text(
                      'Fecha fin: ${_renta!.fecha_fin}',
                      style: TextStyle(fontSize: 14, color: Colors.black), // Tamaño y color de la fuente
                    ),
                    Text(
                      'Estatus: ${_renta!.estatus}',
                      style: TextStyle(fontSize: 14, color: Colors.black), // Tamaño y color de la fuente
                    ),
                     // Espacio entre elementos
                  ],
                ),
              ),
              Expanded(
                
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ 
                    
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _detallesRenta!.length,
                        itemBuilder: (context, index) {
                          final detalle = _detallesRenta![index];
                          final mobiliario = _mobiliarios![index];
                          return ListTile(
                            
                            title: Text('Detalle #${detalle.detalle_id}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mobiliario ID: ${detalle.mobiliario_id}'),
                                Text('Nombre Mobiliario: ${mobiliario.nombre_mobiliario}'),
                                Text('Cantidad: ${detalle.cantidad}'),
                              ],
                            ),
                          );
                        },
                      ),
                      _buildLottieAnimation(_renta!.estatus!),
                    ],
                  ),
                ),
              ),
            ],
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
        animationAsset = 'https://lottie.host/fed494d7-a6c9-4cbe-9ad5-9b1ea45ea035/TlzyFQpBUU.json';
        break;
      case 'Proceso':
        animationAsset = 'https://lottie.host/3408748e-0b87-41bb-8bde-74caf790065d/azr7fI7jgV.json';
        break;
      case 'Cancelada':
        animationAsset = 'https://lottie.host/3d83dfa8-37b0-4b90-81c1-933546b3ed80/xLM87KOQ5V.json';
        break;
      default:
        animationAsset = ''; // Definir una animación predeterminada o un mensaje de error
    }

    if (animationAsset.isNotEmpty) {
      return Transform.scale(
        scale: .5,
        child: Lottie.network(animationAsset),
      );
    } else {
      return Text('No se encontró la animación correspondiente');
    }
  }

}
