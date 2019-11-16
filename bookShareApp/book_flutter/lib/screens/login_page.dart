import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:bookShare/utils.dart';
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/screens/home_page.dart';
import 'package:bookShare/models/app_state.dart';

// new
class BookShareLoginPage extends StatefulWidget {
  BookShareLoginPage({Key key}) : super(key: key);

  @override
  _BookShareLoginState createState() => _BookShareLoginState();
}


class _BookShareLoginState extends State<BookShareLoginPage> {

   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   
   @override
   void initState() {
      super.initState();
   }
   
  @override
  void dispose() {
    super.dispose();
  }


  
  @override
  Widget build(BuildContext context) {

     final container = AppStateContainer.of(context);
     final appState = container.state;

     final usernameField = makeInputField( context, "username", false, appState.usernameController );
     final passwordField = makeInputField( context, "password", true, appState.passwordController );
     final loginButton = makeActionButton( context, 'Login', container.onPressWrapper(() async {
              try{ 
                 await Cognito.signIn( appState.usernameController.text, appState.passwordController.text );
                 MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareHomePage());
                 Navigator.push( context, newPage );
              } catch(e) {
                 if( e.toString().contains("User does not exist") ) {
                    showToast( context, "Username or password is incorrect." );
                 } else if( e.toString().contains( "NotAuthorizedExcept" ) ) {
                    showToast( context, "Username or password is incorrect." );                    
                 } else {
                    showToast( context, e.toString() );
                 }
              }
           }));

     return Scaffold(
      body: Center(

         child: SingleChildScrollView( 
         child: Container(
            color: Colors.white,
            child: Padding(
               padding: const EdgeInsets.all(36.0),
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                     Container( child: Image.asset( 'images/bookShare.jpeg', height: 40.0,  fit: BoxFit.contain)),
                     SizedBox(height: 5.0),
                     usernameField,
                     SizedBox(height: 5.0),
                     passwordField,
                     SizedBox( height: 5.0),
                     loginButton,
                     SizedBox(height: 5.0),
                     Text( appState.userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic)),
                     ])))
         
            )));
   }
}
