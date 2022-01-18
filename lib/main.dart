import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mapa.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Direcciones'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    TextEditingController origenController = new TextEditingController();
    TextEditingController destinoController = new TextEditingController();

    Container textSection(){
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        //margin: EdgeInsets.only(top: 30.0),
        child: Column (
          children: <Widget>[
            TextFormField(
              controller: origenController,
              cursorColor: Colors.black,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  hintText: "Origen",
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                  hintStyle: TextStyle(color: Colors.deepOrange),
                  icon: Icon(Icons.location_on, color: Colors.red)
              ),
            ),
            SizedBox(height: 30.0),
            TextFormField(
              controller: destinoController,
              obscureText: false,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                  hintText: "Destino",
                  hintStyle: TextStyle(color: Colors.deepOrange),
                  icon: Icon(Icons.flag, color: Colors.red),
                  border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black))
              ),
            ),
          ],
        ),
      );
    }


    GuardarDatos() async{
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      setState(() {
        sharedPreferences.setString("origen", origenController.text);
        sharedPreferences.setString("destino", destinoController.text);
      });



    }



    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            textSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GuardarDatos();
          Navigator.push(context, MaterialPageRoute(builder: (context) => Mapa()));
        },
        tooltip: 'Increment',
        child: Icon(Icons.arrow_forward),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );





  }
}
