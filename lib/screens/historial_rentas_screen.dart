import 'package:flutter/material.dart';
import 'package:rentas/database/renta_database.dart';
import 'package:rentas/model/renta_model.dart';
import 'package:intl/intl.dart';
import 'package:rentas/screens/navigation_bar.dart';

class HistorialRentasScreen extends StatefulWidget {
  @override
  _HistorialRentasScreenState createState() => _HistorialRentasScreenState();
}

class _HistorialRentasScreenState extends State<HistorialRentasScreen> {
  late Future<List<RentaModel>> _allRentasFuture;

  @override
  void initState() {
    super.initState();
    _allRentasFuture = _getAllRentas();
  }

  Future<List<RentaModel>> _getAllRentas() async {
    List<RentaModel> allRentas = [];
    allRentas.addAll(await _getRentasByStatus('Cumplida'));
    allRentas.addAll(await _getRentasByStatus('Proceso'));
    allRentas.addAll(await _getRentasByStatus('Cancelada'));
    return allRentas;
  }

  Future<List<RentaModel>> _getRentasByStatus(String status) async {
    return await RentaDatabase().getRentasByStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Rentas'),
      ),
      body: FutureBuilder<List<RentaModel>>(
        future: _allRentasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final rentas = snapshot.data!;
            //Se acomodan aqui
            rentas.sort((a, b) => a.renta_id!.compareTo(b.renta_id!)); 
            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final renta = rentas[index];
                      final dateFormatter = DateFormat('yyyy-MM-dd');
                      final fechaInicioFormatted = dateFormatter.format(renta.fecha_inicio!);
                      final fechaFinFormatted = dateFormatter.format(renta.fecha_fin!);
                      return InkWell(
                      onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detalleR',
                            arguments: renta.renta_id, 
                          );
                      },
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            color: Colors.white, 
                            border: Border.all(color: Colors.grey), 
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatusIndicator(renta.estatus!),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Renta #${renta.renta_id}', style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(height: 8),
                                  Text('Fecha inicio: $fechaInicioFormatted'),
                                  Text('Fecha término: $fechaFinFormatted'),
                                ],
                              ),
                              PopupMenuButton<String>(
                                onSelected: (String result) {
                                  
                                  if (result == "Editar") {
                                    
                                  } else if (result == "Eliminar") {
                                    
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
                      ),
                      );
                    },
                    childCount: rentas.length,
                  ),
                ),
              ],
            );
          }
        },
      ),
      //bottomNavigationBar: NavigationBarApp(),
    );
  }

  Widget _buildStatusIndicator(String status) {
  Color color;
  switch (status) {
      case 'Cumplida':
        color = Colors.green;
        break;
      case 'Proceso':
        color = Colors.orange;
        break;
      case 'Cancelada':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
  }
  return CircleAvatar(
      radius: 30, 
      backgroundColor: color,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white, 
      ),
  );
  }
}

