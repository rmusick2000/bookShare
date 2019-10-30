import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

import 'package:bookShare/utils.dart';
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/models/app_state.dart';

// XXX new
class BookShareSignupPage extends StatefulWidget {
  BookShareSignupPage({Key key}) : super(key: key);

  @override
  _BookShareSignupState createState() => _BookShareSignupState();
}


class _BookShareSignupState extends State<BookShareSignupPage> {
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

      // XXX _
      
      final container = AppStateContainer.of(context);
      final appState = container.state;
      
      // XXX utils
      final usernameField = TextField(
         obscureText: false,
         style: style,
         decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Username",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
         controller: appState.usernameController,
         );
      final passwordField = TextField(
         obscureText: true,
         style: style,
         decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Password",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
         controller: appState.passwordController,
         );
      final emailField = TextField(
         obscureText: false,
         style: style,
         decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "email address",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
         controller: appState.attributeController,
         );
      final confirmationCodeField = TextField(
         obscureText: false,
         style: style,
         decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "confirmation code",
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
         controller: appState.confirmationCodeController,
         );
      // XXX inform user to look for email
      final signupButton = makeActionButton( context, "Signup", container.onPressWrapper((){
               final email = {'email' : appState.attributeController.text };
               Cognito.signUp( appState.usernameController.text, appState.passwordController.text, email );
            }));
      final confirmSignupButton = makeActionButton( context, "Confirm signup", container.onPressWrapper((){
                  Cognito.confirmSignUp( appState.usernameController.text, appState.confirmationCodeController.text );
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
                           emailField,
                           SizedBox( height: 5.0),
                           confirmationCodeField,
                           SizedBox( height: 5.0),
                           signupButton,
                           SizedBox( height: 5.0),
                           confirmSignupButton,
                           SizedBox( height: 5.0),
                           Text( appState.userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic))
                           ])))
               
               )));
   }
}
