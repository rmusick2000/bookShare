import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';
// Note - this requires state here: android/app/src/main/res/raw/awsconfiguration.json

import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:bookShare/utils.dart';
import 'package:bookShare/screens/home_page.dart';

class BookShareLoginPage extends StatefulWidget {
  BookShareLoginPage({Key key}) : super(key: key);

  @override
  _BookShareLoginState createState() => _BookShareLoginState();
}


class _BookShareLoginState extends State<BookShareLoginPage> {

   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   var returnValue;
   UserState userState;
   double progress;
   String bookState;
   final usernameController = TextEditingController();
   final passwordController = TextEditingController();

   // XXX user state is funky here.. back doesn't initState, but back back forward does.  logout has to initiate setstate
  // init Cognito
  Future<void> doLoad() async {
    var value;
    try {
      value = await Cognito.initialize();
    } catch (e, trace) {
      print(e);
      print(trace);

      if (!mounted) return;
      setState(() {
        returnValue = e;
        progress = -1;
      });

      return;
    }

    if (!mounted) return;
    setState(() {
      progress = -1;
      userState = value;
    });
  }

  @override
  void initState() {
    super.initState();
    doLoad();
    Cognito.registerCallback((value) {
      if (!mounted) return;
      setState(() {
        userState = value;
      });
    });
  }

  @override
  void dispose() {
    Cognito.registerCallback(null);
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // XXX _ 
  // wraps a function from the auth library with some scaffold code.
  onPressWrapper(fn) {
    wrapper() async {
      setState(() {
        progress = null;
      });

      String value;
      try {
        value = (await fn()).toString();
      } catch (e, stacktrace) {
        print(e);
        print(stacktrace);
        setState(() => value = e.toString());
      } finally {
        setState(() {
          progress = -1;
        });
      }

      setState(() => returnValue = value);
    }

    return wrapper;
  }

  
   @override
   Widget build(BuildContext context) {

      // XXX _

      final usernameField = TextField(
        obscureText: false,
        style: style,
        decoration: InputDecoration(
           contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
           hintText: "Username",
           border:
           OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
        controller: usernameController,
        );
     final passwordField = TextField(
        obscureText: true,
        style: style,
        decoration: InputDecoration(
           contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
           hintText: "Password",
           border:
           OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
        controller: passwordController,
        );
     final loginButton = makeActionButton( context, 'Login', onPressWrapper((){
                    return Cognito.signIn( usernameController.text, passwordController.text );
           }));

     // XXX Very easy to break ATM.  no email provided?  no confirmation possible.
     // XXX Need good error checking in here.

     final homeButton = RaisedButton(
        onPressed: ()
        {
           Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BookShareHomePage()));
        },
        child: Text( 'Home'));
     
     
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
                     SizedBox( height: 5.0),
                     homeButton,
                     SizedBox(height: 5.0),
                     Text( userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic)),
                     Text( bookState?.toString() ?? "illiterate", style: TextStyle(fontStyle: FontStyle.italic)),
                     ])))
         
            )));
   }
}
