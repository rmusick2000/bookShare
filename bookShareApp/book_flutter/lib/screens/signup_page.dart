import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:bookShare/utils.dart';
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/screens/home_page.dart';

class BookShareSignupPage extends StatefulWidget {
  BookShareSignupPage({Key key}) : super(key: key);

  @override
  _BookShareSignupState createState() => _BookShareSignupState();
}


class _BookShareSignupState extends State<BookShareSignupPage> {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

   // Always create with false.  When logout, all stacks pop, recreate is with false.
   bool showCC = false;
   
   @override
   void initState() {
      super.initState();
      showCC = false;
   }

   @override
   void dispose() {
      super.dispose();
   }

   void showToast(BuildContext context) {
      Fluttertoast.showToast(
         msg: "Code sent to your email.",
         toastLength: Toast.LENGTH_LONG,
         gravity: ToastGravity.CENTER,
         backgroundColor: Colors.pinkAccent,
         textColor: Colors.white,
         fontSize: 18.0
         );
   }
   
   @override
   Widget build(BuildContext context) {

      
      final container = AppStateContainer.of(context);
      final appState = container.state;
      
      final usernameField = makeInputField( context, "username", false, appState.usernameController );
      final passwordField = makeInputField( context, "password", true, appState.passwordController );
      final emailField    = makeInputField( context, "email address", false, appState.attributeController );
      final confirmationCodeField = makeInputField( context, "confirmation code", false, appState.confirmationCodeController );
      final signupButton = makeActionButton( context, "Send confirmation code", container.onPressWrapper(() async {
               final email = {'email' : appState.attributeController.text };
               await Cognito.signUp( appState.usernameController.text, appState.passwordController.text, email );
               showToast( context );
               setState(() { showCC = true; });
            }));
      final confirmSignupButton = makeActionButton( context, "Confirm signup, and Log in", container.onPressWrapper(() async {
               await Cognito.confirmSignUp( appState.usernameController.text, appState.confirmationCodeController.text );
               await Cognito.signIn( appState.usernameController.text, appState.passwordController.text );
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookShareHomePage()));
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
                           Visibility( visible: showCC, child: confirmationCodeField ),
                           SizedBox( height: 5.0),
                           Visibility( visible: !showCC, child: signupButton ),
                           SizedBox( height: 5.0),
                           Visibility( visible: showCC, child: confirmSignupButton ),
                           SizedBox( height: 5.0),
                           Text( appState.userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic))
                           ])))
               
               )));
   }
}
