import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'coordenadas.dart';

class Mapa extends StatefulWidget {
  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {

  bool _isLoading = true;

  late String origen;

  late String destino;

  late List<Coordenadas> datos;

  late double distancia;

  late double consumo;

  String key = 'insertar key';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    obtenerDatos();

  }

  Future<List<Coordenadas>> direcciones() async{

    String stringUrl = 'https://www.mapquestapi.com/directions/v2/route?key='+key+'&from='+origen+'&to='+destino;

    http.Response response = await http.get(Uri.parse(stringUrl));

    dynamic responseBody = jsonDecode(response.body);
    dynamic statusCode = response.statusCode;

    dynamic coordenadas = responseBody["route"]["legs"][0]['maneuvers'];

    print(coordenadas[0]['startPoint']);

    print(coordenadas.length);

    distancia = responseBody["route"]["distance"];

    consumo = responseBody["route"]["fuelUsed"];

    List<Coordenadas> aux = [];

    late Coordenadas auxiliar;

    for (var coordenada in coordenadas){
      auxiliar = new Coordenadas(coordX: coordenada['startPoint']['lat'], coordY: coordenada['startPoint']['lng']);
      aux.add(auxiliar);
    }

    print(aux.length);

    return aux;
  }

  obtenerDatos() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      origen = sharedPreferences.getString("origen")!;
      destino = sharedPreferences.getString("destino")!;

    });
    datos = await direcciones();

    setState(() {
      _isLoading = false;
    });


  }

  late GoogleMapController _mapController;

  @override
  Widget build(BuildContext context) {
    return _isLoading ? new Center(
      child: new CircularProgressIndicator(),
    ):Scaffold(

      appBar: AppBar(
        title: Text('De: '+origen+' A: '+destino),
        backgroundColor: Colors.red,
      ),
      body: Scaffold(
        appBar: AppBar(
          title: Text('Distancia: '+distancia.toString()+" Millas", style: TextStyle(
            color: Colors.black,
            fontSize: 17,
          ),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          toolbarHeight: 30,
        ),
        body: Scaffold(
          appBar: AppBar(
            title: Text('Consumo: '+consumo.toString()+" Galones", style: TextStyle(
                color: Colors.black,
              fontSize: 17,
            ),
            ),
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            toolbarHeight: 30,
          ),
          body: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(datos[0].coordX,datos[0].coordY),
              zoom: 10,
            ),
            markers: _createMarker(),
            onMapCreated: _onMapCreated,
            zoomControlsEnabled: false,

          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.zoom_out_map),
        onPressed: _centerView,
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Set<Marker> _createMarker(){
    var tmp = Set<Marker>();

    tmp.add(Marker(
        markerId: MarkerId("Dir: "+1.toString()),
        position: LatLng(datos[0].coordX,datos[0].coordY),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: "Dir: "+1.toString(),
        )
    ));

    for(var i = 1; i < datos.length-1; i++){
      tmp.add(Marker(
          markerId: MarkerId("Dir: "+i.toString()),
          position: LatLng(datos[i].coordX,datos[i].coordY),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
              title: "Dir: "+(i+1).toString(),
          )
      ));
    }

    tmp.add(Marker(
        markerId: MarkerId("Dir: "+(datos.length).toString()),
        position: LatLng(datos[datos.length-1].coordX,datos[datos.length-1].coordY),
        infoWindow: InfoWindow(
          title: "Dir: "+(datos.length).toString(),
        )
    ));

    return tmp;
  }




  void _onMapCreated(GoogleMapController controller) {

    _mapController = controller;

    _centerView();
  }

  _centerView() async{

    await _mapController.getVisibleRegion();

    var left = min(datos[0].coordX,datos[datos.length-1].coordX);
    var right = max(datos[0].coordX,datos[datos.length-1].coordX);
    var top = max(datos[0].coordY,datos[datos.length-1].coordY);
    var bottom = min(datos[0].coordY,datos[datos.length-1].coordY);

    var bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    _mapController.animateCamera(cameraUpdate);

  }

}
