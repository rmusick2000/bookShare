import 'package:flutter/material.dart';
import 'detail.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookShare',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}


// XXX Anticipating state..
// XXX NOTE image behaves irregularly when deployed..  interaction with 1200?
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    
    Color color = Theme.of(context).primaryColor;

    Widget raisedButton = RaisedButton(
       child: Text('Login or Signup'),
       onPressed: () {
         Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailPage()));
    });



    return Scaffold(
      body: Center(

         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             // Container( width: double.infinity, height: 100, child: Container( color: Colors.red)),
             Stack(
                children: <Widget>[
                   Container( child: Image.asset( 'images/bookShare.jpeg', width: 1200,  fit: BoxFit.fitWidth)), 
                   Positioned( bottom: 50, left: 30, child: Text("BookShare", style: new TextStyle( fontFamily: 'Mansalva', fontSize: 60.0)))
              ]),
             raisedButton
             ]),

         )
      );
  }
}



