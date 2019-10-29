import 'package:flutter/material.dart';

import 'login_page.dart';
import 'signup_page.dart';
import 'utils.dart';

void main() => runApp(BSApp());


class BSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookShare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData( primarySwatch: Colors.green ),
      home:  BSHomePage( title: 'BookShare'),
    );
  }
}


class BSHomePage extends StatefulWidget {
   BSHomePage({Key key, this.title}) : super(key: key);

   final String title;
   
  @override
  _BSHomePageState createState() => _BSHomePageState();
}


class _BSHomePageState extends State<BSHomePage> {


  
  @override
  Widget build(BuildContext context) {
    
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
         // style: new TextStyle( fontFamily: 'Montserrat', fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.green )
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



