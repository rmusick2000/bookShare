import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

// bookShare package name from pubspec.yaml
import 'package:bookShare/screens/launch_page.dart';
import 'package:bookShare/screens/home_page.dart';

import 'package:bookShare/models/app_state.dart';

import 'package:bookShare/app_state_container.dart';


void main() => runApp(
   new AppStateContainer( child: new BSApp() )
   );


class BSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( primarySwatch: Colors.green ),
      home:  BSSplashPage( title: 'BookShare'),
    );
  }
}


class BSSplashPage extends StatefulWidget {
   BSSplashPage({Key key, this.title}) : super(key: key);

   final String title;
   
  @override
  _BSSplashPageState createState() => _BSSplashPageState();
}


class _BSSplashPageState extends State<BSSplashPage> {

   AppState appState;    // Declaration.  Definition is in build, can be used below
   
   @override
   void initState() {
      print( "... Main init state" );
      super.initState();
      startTimer();
   }

  @override
  void dispose() {
     super.dispose();
  }

  void startTimer() {
     Timer(Duration(seconds: 3), () {
           navigateUser();
        });
  }

  void navigateUser() async{
     if( appState.userState == UserState.SIGNED_IN ) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BookShareHomePage()));
     } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BSLaunchPage()));
     }
  }

  
  @override
  Widget build(BuildContext context) {

     var container = AppStateContainer.of(context);
     appState = container.state;
     
     Color color     = Theme.of(context).primaryColor;
     final devWidth  = MediaQuery.of(context).size.width;
     final devHeight = MediaQuery.of(context).size.height;

       return Scaffold(
          body: Center(
             child: Stack(
                children: <Widget>[
                   Container( child: Image.asset( 'images/bookShare.jpeg', width: devWidth - 50, fit: BoxFit.fitWidth)), 
                   Positioned( bottom: 60 , left: 10, child: Text("BookShare", style: new TextStyle( fontFamily: 'Mansalva', fontSize: 54.0))),
                   ]))
          /*
          body: Container(
             decoration: BoxDecoration(
                image: DecorationImage(
                   image: AssetImage("images/bookShare.jpeg"),
                   fit: BoxFit.cover)
                ))
          );
          */
          );}
}



