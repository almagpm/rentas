import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/material.dart';
import 'package:rentas/database/cliente_database.dart';
import 'package:rentas/database/detalle_renta_database.dart';
import 'package:rentas/database/renta_database.dart';
import 'package:rentas/model/cliente_model.dart';
import 'package:rentas/model/renta_model.dart';
import 'package:intl/intl.dart';
import 'package:rentas/settings/app_value_notifier.dart';

class HistorialRentasScreen extends StatefulWidget {
  @override
  _HistorialRentasScreenState createState() => _HistorialRentasScreenState();
}

class _HistorialRentasScreenState extends State<HistorialRentasScreen> {
  late Future<List<RentaModel>> _allRentasFuture;
  RentaDatabase? rentaDB;
  DetalleRentaDatabase? detalleDB;

  @override
  void initState() {
    super.initState();
    _allRentasFuture = _getAllRentas();
    rentaDB = new RentaDatabase();
    detalleDB = new DetalleRentaDatabase();
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
        iconTheme: IconThemeData(
              color: Colors.white,
            ),
        title: Text(
          'Historial de rentas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: ValueListenableBuilder(
        valueListenable: AppValueNotifier.banRentas,
        builder: (context, value, child) {
          return Container(
            color: Colors.white, // Color de fondo del Container
            child: FutureBuilder<List<RentaModel>>(
              future: _getAllRentas(),
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
                            final fechaInicioFormatted =
                                dateFormatter.format(renta.fecha_inicio!);
                            final fechaFinFormatted =
                                dateFormatter.format(renta.fecha_fin!);
                            return InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/detalleR',
                                  arguments: renta.renta_id,
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                          0.1), // Color y opacidad de la sombra
                                      spreadRadius:
                                          1, // Radio de propagación de la sombra
                                      blurRadius:
                                          3, // Radio de desenfoque de la sombra
                                      offset: Offset(0,
                                          2), // Desplazamiento horizontal y vertical de la sombra
                                    )
                                  ],
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStatusIndicator(renta.estatus!),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Renta #${renta.renta_id}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 8),
                                        Text(
                                            'Fecha inicio: $fechaInicioFormatted'),
                                        Text(
                                            'Fecha término: $fechaFinFormatted'),
                                      ],
                                    ),
                                    PopupMenuButton<String>(
                                      elevation: 0,
                                      onSelected: (String result) async {
                                        if (result == "Editar") {
                                          modificarRenta(
                                              context, snapshot.data![index]);
                                        }
                                        if (result == "Eliminar") {
                                          ArtDialogResponse response =
                                              await ArtSweetAlert.show(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  artDialogArgs: ArtDialogArgs(
                                                      denyButtonText:
                                                          "Cancelar",
                                                      title: "¿Estás seguro?",
                                                      text:
                                                          "¡No podrás revertir esta acción!",
                                                      confirmButtonText:
                                                          "Si, borralo",
                                                      type: ArtSweetAlertType
                                                          .warning));

                                          if (response == null) {
                                            return;
                                          }

                                          if (response.isTapConfirmButton) {
                                            rentaDB!
                                                .deleteRenta(snapshot
                                                    .data![index].renta_id!)
                                                .then((value) {
                                              detalleDB!
                                                  .deleteDetalleRentaByIdRenta(
                                                      snapshot.data![index]
                                                          .renta_id!)
                                                  .then((value) {
                                                if (value > 0) {
                                                  ArtSweetAlert.show(
                                                      context: context,
                                                      artDialogArgs: ArtDialogArgs(
                                                          type:
                                                              ArtSweetAlertType
                                                                  .success,
                                                          title: "¡Borrado!"));
                                                }
                                                AppValueNotifier
                                                        .banRentas.value =
                                                    !AppValueNotifier
                                                        .banRentas.value;
                                              });
                                            });
                                            return;
                                          }
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
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
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn2',
        onPressed: () {
          Navigator.pushNamed(context, '/agregarRenta');
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

  void modificarRenta(context, RentaModel renta) async {
    final conFechaInicio = TextEditingController();
    final conFechaFin = TextEditingController();
    final conEstatus = TextEditingController();
    final conCliente = TextEditingController();
    final _keyForm = GlobalKey<FormState>();

    conFechaInicio.text = renta.fecha_inicio.toString().split(' ')[0];
    conFechaFin.text = renta.fecha_fin.toString().split(' ')[0];
    conEstatus.text = renta.estatus!;
    conCliente.text = renta.cliente_id.toString();

    final txtFechaInicio = TextFormField(
      keyboardType: TextInputType.none,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Necesitas ingresar una fecha';
        }
        return null;
      },
      controller: conFechaInicio,
      decoration: const InputDecoration(
        labelText: 'Fecha inicio',
        prefixIcon: Icon(Icons.date_range_outlined),
        border: UnderlineInputBorder(),
      ),
      onTap: () async {
        // Guarda una referencia al contexto actual
        BuildContext currentContext = context;

        DateTime? pickedDate = await showDatePicker(
          context: currentContext, // Utiliza la referencia guardada al contexto
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          // Utiliza la referencia guardada al contexto para llamar a setState
          Scaffold.of(currentContext).setState(() {
            conFechaInicio.text = formattedDate;
          });
        }
      },
    );

    final txtFechaFin = TextFormField(
      keyboardType: TextInputType.none,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Necesitas ingresar una fecha';
        }
        return null;
      },
      controller: conFechaFin,
      decoration: const InputDecoration(
        labelText: 'Fecha fin',
        prefixIcon: Icon(Icons.date_range_outlined),
        border: UnderlineInputBorder(),
      ),
      onTap: () async {
        // Guarda una referencia al contexto actual
        BuildContext currentContext = context;

        DateTime? pickedDate = await showDatePicker(
          context: currentContext, // Utiliza la referencia guardada al contexto
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
          // Utiliza la referencia guardada al contexto para llamar a setState
          Scaffold.of(currentContext).setState(() {
            conFechaFin.text = formattedDate;
          });
        }
      },
    );

    final txtEstatus = DropdownButtonFormField<String>(
        value: (conEstatus.text.isEmpty) ? null : conEstatus.text,
        hint: Text('Seleccione el estatus'),
        items: <String>['Cumplida', 'Proceso', 'Cancelada']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? value) {
          conEstatus.text = value!;
        });

    ClienteDatabase clienteDB = ClienteDatabase();
    List<ClienteModel> clientes = await clienteDB.getClientes();

    final txtCliente = DropdownButtonFormField<String>(
        value: (conCliente.text.isEmpty) ? null : conCliente.text,
        hint: Text('Seleccione un cliente'),
        items: clientes.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.cliente_id.toString(),
            child: Text(value.nombre.toString()),
          );
        }).toList(),
        onChanged: (String? value) {
          conCliente.text = value!;
        });

    final btnAgregar = ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
        onPressed: () {
          if(_keyForm.currentState!.validate()){
            RentaModel renta2 = RentaModel(
              renta_id: renta.renta_id,
              fecha_fin: DateTime.parse(conFechaFin.text),
              fecha_inicio: DateTime.parse(conFechaInicio.text),
              cliente_id: int.parse(conCliente.text),
              estatus: conEstatus.text);
          rentaDB!.updateRenta(renta2).then((value) {
            Navigator.of(context).pop();
            String msj = "";
            var snackbar;
            if (value > 0) {
              AppValueNotifier.banRentas.value =
                  !AppValueNotifier.banRentas.value;
              msj = "Renta actualizada";
              snackbar = SnackBar(
                content: Text(msj),
                backgroundColor: Colors.green,
              );
            } else {
              msj = "Ocurrio un error";
              snackbar = SnackBar(
                content: Text(
                  msj,
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              );
            }
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          });
          }
        },
        icon: const Icon(Icons.save),
        label: const Text('Guardar'));

    final space = SizedBox(
      height: 10,
    );

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
                  'Fechas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  //padding: EdgeInsets.all(5),
                  child: txtFechaInicio,
                ),
                Container(
                  //padding: EdgeInsets.all(5),
                  child: txtFechaFin,
                ),
                space,
                space,
                Text(
                  'Estatus',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  //padding: EdgeInsets.all(5),
                  child: txtEstatus,
                ),
                space,
                space,
                Text(
                  'Cliente',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  //padding: EdgeInsets.all(5),
                  child: txtCliente,
                ),
                space,
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
