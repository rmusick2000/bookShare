import 'package:flutter/material.dart';

// bookShare package name from pubspec.yaml
import 'package:bookShare/screens/login_page.dart';
import 'package:bookShare/screens/signup_page.dart';
import 'package:bookShare/screens/home_page.dart';

import 'package:bookShare/models/app_state.dart';

import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/utils.dart';  // XXX combine
import 'package:bookShare/auth.dart';



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
      home:  BSMainPage( title: 'BookShare'),
    );
  }
}


class BSMainPage extends StatefulWidget {
   BSMainPage({Key key, this.title}) : super(key: key);

   final String title;
   
  @override
  _BSMainPageState createState() => _BSMainPageState();
}


class _BSMainPageState extends State<BSMainPage> {

   final auth = new BookShareAuth();

   AppState appState;    // Declaration.  Definition is in build, can be used below
   
   @override
   void initState() {
      print( "... Main init state" );
      super.initState();
   }

  @override
  void dispose() {
     super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

     var container = AppStateContainer.of(context);
     appState = container.state;
     print( "State check, aname is.. " + appState.aname?.toString() ?? "NULL ANAME" );
     
    Color color = Theme.of(context).primaryColor;

    Widget _loginButton = makeActionButton( context, 'Login', (() {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookShareLoginPage()));
          }));
       
    Widget _signupButton = makeActionButton( context, 'Create New Account', (() {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookShareSignupPage()));
          }));

    // XXX 'How does it work?' option
    // XXX General public login
    Widget _nurb = Container(
       padding: const EdgeInsets.all(4),
       child: Text(
         'Share books with people you know.\n'
         'Browse, borrow and loan the books you love!',
         softWrap: true,
         style: new TextStyle( fontFamily: 'Montserrat', fontSize: 15.0, fontWeight: FontWeight.bold, color: Colors.pink[300] )
          ));

    final devWidth = MediaQuery.of(context).size.width;
    final devHeight = MediaQuery.of(context).size.height;
 
    return Scaffold(

       // appBar: AppBar( title: Text( widget.title, style: new TextStyle( fontFamily: 'Mansalva', fontSize: 16 ))),
      body: Center(

         child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
               SizedBox( height: devHeight / 8.0),
               Stack(
                  children: <Widget>[
                     Container( child: Image.asset( 'images/bookShare.jpeg', width: devWidth - 50, fit: BoxFit.fitWidth)), 
                     Positioned( bottom: 60 , left: 10, child: Text("BookShare", style: new TextStyle( fontFamily: 'Mansalva', fontSize: 54.0))),
                     Positioned( bottom: 20, left: 10, child: _nurb )
                     ]),
               SizedBox( height: devHeight / 10.0 ),
               _signupButton,
               SizedBox( height: 20.0),
               _loginButton,
               ]),
         
          )
      );

  }
}



