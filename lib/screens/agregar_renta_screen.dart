import 'package:art_sweetalert/art_sweetalert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rentas/database/categoria_mobiliario_database.dart';
import 'package:rentas/database/cliente_database.dart';
import 'package:rentas/database/detalle_renta_database.dart';
import 'package:rentas/database/mobiliario_database.dart';
import 'package:rentas/database/renta_database.dart';
import 'package:rentas/model/categoria_mobiliario_model.dart';
import 'package:rentas/model/cliente_model.dart';
import 'package:rentas/model/detalle_renta_model.dart';
import 'package:rentas/model/mobiliario_model.dart';
import 'package:rentas/model/renta_model.dart';
import 'package:rentas/settings/app_value_notifier.dart';
import 'package:rentas/widget/mobiliario.dart';
import 'package:badges/badges.dart' as badges;

class AgregarRentaScreen extends StatefulWidget {
  const AgregarRentaScreen({super.key});

  @override
  State<AgregarRentaScreen> createState() => _AgregarRentaScreenState();
}

class _AgregarRentaScreenState extends State<AgregarRentaScreen> {
  final conFechaInicio = TextEditingController();
  final conFechaFin = TextEditingController();
  final conEstatus = TextEditingController();
  final conCliente = TextEditingController();
  final conCategoria = TextEditingController();
  var idCategoria = -1;
  final _keyForm = GlobalKey<FormState>();

  late List<ClienteModel> clientes = [];

  late List<CategoriaMobiliarioModel> categorias = [];
  //List<int> contadores = [];
  Map<int, int> contadores = {};

  MobiliarioDatabase? mobiliarioDB;
  RentaDatabase? rentaDB;
  DetalleRentaDatabase? detalleDB;

  @override
  void initState() {
    super.initState();
    cargarClientes();
    cargarCategorias();
    mobiliarioDB = new MobiliarioDatabase();
    rentaDB = new RentaDatabase();
    detalleDB = new DetalleRentaDatabase();
  }

  void cargarClientes() async {
    ClienteDatabase clienteDB = ClienteDatabase();
    List<ClienteModel> listaClientes = await clienteDB.getClientes();

    setState(() {
      clientes = listaClientes;
    });
  }

  void cargarCategorias() async {
    CategoriaMobiliarioDatabase categoriaDB = CategoriaMobiliarioDatabase();
    List<CategoriaMobiliarioModel> listCategorias =
        await categoriaDB.getCategorias();
    setState(() {
      categorias = listCategorias;
    });
  }

  var cantidadMobiliario = 0;

  @override
  Widget build(BuildContext context) {
    final txtFechaInicio = TextFormField(
        keyboardType: TextInputType.none,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Ingresa una fecha';
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
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), //get today's date
              firstDate: DateTime(
                  2000), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime(2101));

          if (pickedDate != null) {
            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
            setState(() {
              conFechaInicio.text = formattedDate;
            });
          } else {}
        });

    final txtFechaFin = TextFormField(
        keyboardType: TextInputType.none,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Ingresa una fecha';
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
          DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(), //get today's date
              firstDate: DateTime(
                  2000), //DateTime.now() - not to allow to choose before today.
              lastDate: DateTime(2101));

          if (pickedDate != null) {
            String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
            setState(() {
              conFechaFin.text = formattedDate;
            });
          } else {}
        });

    final txtEstatus = DropdownButtonFormField<String>(
        value: (conEstatus.text.isEmpty) ? null : conEstatus.text,
        validator: (value) {
          if (value == null) {
            return 'Selecciona un estatus.';
          }
          return null;
        },
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

    final txtCliente = DropdownButtonFormField<String>(
        value: (conCliente.text.isEmpty) ? null : conCliente.text,
        validator: (value) {
          if (value == null) {
            return 'Selecciona un cliente.';
          }
          return null;
        },
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

    final txtCategoria = DropdownButtonFormField<String>(
        value: (conCategoria.text.isEmpty) ? null : conCategoria.text,
        validator: (value) {
          if (value == null) {
            return 'Selecciona una categoria.';
          }
          return null;
        },
        hint: Text('Seleccione una categoria'),
        items: categorias.map<DropdownMenuItem<String>>((value) {
          return DropdownMenuItem<String>(
            value: value.categoria_id.toString(),
            child: Text(value.nombre_categoria.toString()),
          );
        }).toList(),
        onChanged: (String? value) {
          contadores.clear();
          setState(() {
            conCategoria.text = value!;
            cantidadMobiliario = 0;
          });
        });

    final space = SizedBox(
      height: 30,
    );

    void actualizarContador(int id, int nuevoValor) {
      setState(() {
        contadores[id] = nuevoValor;
      });
      setState(() {
        cantidadMobiliario = 0;
      });

      contadores.forEach((key, value) {
        setState(() {
          cantidadMobiliario += value;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Renta',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
            badges.Badge(
              badgeContent: Text(
                cantidadMobiliario.toString(),
                style: TextStyle(color: Colors.white),
              ),
              position: badges.BadgePosition.topEnd(top: 0, end: 5),
              child: IconButton(
                icon: Icon(Icons.indeterminate_check_box),
                onPressed: () {},
              ),
            )
          ],
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
          ),
          Positioned(
              top: -700,
              left: -50,
              right: -50,
              bottom: 0,
              child: Center(
                child: Container(
                  //width: MediaQuery.of(context).size.width * 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[900],
                  ),
                ),
              )),
          Positioned(
              left: 20,
              right: 20,
              top: MediaQuery.of(context).size.height * 0.02,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: _keyForm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Fechas',
                          style: TextStyle(fontSize: 20),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                //padding: EdgeInsets.all(5),
                                child: txtFechaInicio,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Container(
                                //padding: EdgeInsets.all(5),
                                child: txtFechaFin,
                              ),
                            ),
                          ],
                        ),
                        space,
                        Text(
                          'Estatus',
                          style: TextStyle(fontSize: 20),
                        ),
                        txtEstatus,
                        space,
                        Text(
                          'Cliente',
                          style: TextStyle(fontSize: 20),
                        ),
                        txtCliente,
                        space,
                        Text(
                          'Categorías mobiliario',
                          style: TextStyle(fontSize: 20),
                        ),
                        txtCategoria,
                        space,
                        Text(
                          'Mobiliario',
                          style: TextStyle(fontSize: 20),
                        ),
                        Builder(
                          builder: (context) {
                            if (conCategoria.text.isEmpty) {
                              return SizedBox(
                                height: 20,
                              );
                            } else {
                              return FutureBuilder(
                                  key: ValueKey(conCategoria.text.toString()),
                                  future: mobiliarioDB!
                                      .getMobiliarioByCategoria(
                                          int.parse(conCategoria.text)),
                                  builder: (context,
                                      AsyncSnapshot<List<MobiliarioModel>>
                                          snapshot) {
                                    if (snapshot.hasError) {
                                      return const Center(
                                        child: Text('Algo salio mal :('),
                                      );
                                    } else {
                                      if (snapshot.hasData) {
                                        return Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ListView.builder(
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (context, index) {
                                                return MobiliarioWidget(
                                                  mobiliario:
                                                      snapshot.data![index],
                                                  actualizarContador:
                                                      actualizarContador,
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    }
                                  });
                            }
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancelar'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[300],
                                  foregroundColor: Colors.black),
                            ),
                            TextButton(
                              onPressed: () {
                                if (_keyForm.currentState!.validate()) {
                                  guardar(context).then((value) {
                                    Navigator.pop(context);
                                  });
                                }
                              },
                              child: Text('Guardar'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[900],
                                  foregroundColor: Colors.white),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  Future guardar(context) async {
    try {
      RentaModel renta = new RentaModel(
          fecha_inicio: DateTime.parse(conFechaInicio.text),
          fecha_fin: DateTime.parse(conFechaFin.text),
          cliente_id: int.parse(conCliente.text),
          estatus: conEstatus.text);
      await rentaDB!.insertRenta(renta).then((int id) {
        contadores.forEach((key, value) {
          if (value != 0) {
            DetalleRentaModel detalle = new DetalleRentaModel(
                renta_id: id, mobiliario_id: key, cantidad: value);
            detalleDB!.insertDetalleRenta(detalle);
          }
        });
      });
      contadores.forEach((key, value) {
        print('id: ' + key.toString() + ' cantidad: ' + value.toString());
      });
      AppValueNotifier.banRentas.value = !AppValueNotifier.banRentas.value;
      return ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "¡Registro exitoso!",
              text: "La renta se ha registrado correctamente."));
    } catch (error) {
      return ArtSweetAlert.show(
          context: context,
          artDialogArgs: ArtDialogArgs(
              type: ArtSweetAlertType.success,
              title: "¡Oops!",
              text: "Ha ocurrido un error al registrar la renta."));
    }
  }
}
