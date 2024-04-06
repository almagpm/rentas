import 'package:flutter/material.dart';
import 'package:rentas/model/mobiliario_model.dart';

class MobiliarioWidget extends StatefulWidget {
  final MobiliarioModel mobiliario;
  final Function(int, int) actualizarContador;

  MobiliarioWidget({
    required this.mobiliario,
    required this.actualizarContador,
  });

  @override
  _MobiliarioWidgetState createState() => _MobiliarioWidgetState();
}

class _MobiliarioWidgetState extends State<MobiliarioWidget> {
  int _counter =0;

  final space = SizedBox(width: 10,);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 1))),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.indeterminate_check_box, size: 40,),
                SizedBox(width: 10,),
                Text(widget.mobiliario.nombre_mobiliario!),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 40,
                  child: TextButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900],foregroundColor: Colors.white),
                    onPressed: () {
                      if(_counter>0){
                        setState(() {
                          _counter--;
                        });
                        widget.actualizarContador(widget.mobiliario.mobiliario_id!, _counter);
                      }
                    },
                    child: Text('-',style: TextStyle(fontSize: 20),),
                  ),
                ),
                space,
                Text(_counter.toString()),
                space,
                Container(
                  width: 50,
                  height: 40,
                  child: TextButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900],foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() {
                        _counter++;
                      });
                      widget.actualizarContador(widget.mobiliario.mobiliario_id!, _counter);
                    },
                    child: Text('+'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
