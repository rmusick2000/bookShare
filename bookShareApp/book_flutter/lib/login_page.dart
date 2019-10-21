// import 'dart:convert';

import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

import 'package:flutter/material.dart';

// XXX state HAS to reside in main app, else when switch between pages, rebuild
//     wipes it out each time.

// android/app/src/main/res/raw/awsconfiguration.json
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
   final usernameController = TextEditingController();
   final passwordController = TextEditingController();

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

     final usernameField = TextField(
        obscureText: false,
        style: style,
        decoration: InputDecoration(
           contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
           hintText: "Username",
           border:
           OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        controller: usernameController,
        );
     final passwordField = TextField(
        obscureText: true,
        style: style,
        decoration: InputDecoration(
           contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
           hintText: "Password",
           border:
           OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        controller: passwordController,
        );
     final loginButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
           minWidth: MediaQuery.of(context).size.width,
           padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
           onPressed:
             onPressWrapper(() {
                   return Cognito.signIn( usernameController.text, passwordController.text );
                }),
           child: Text("Login",
                       textAlign: TextAlign.center,
                       style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
           ),
        );

     final backButton = RaisedButton(
        onPressed: () { Navigator.pop( context ); },
        child: Text( 'Go Back!'));
                        

     // XXX convert backButton to return with userState
     return Scaffold(
      appBar: AppBar( title: Text( "Login page" )),
      body: Center(

         child: Container(
            color: Colors.white,
            child: Padding(
               padding: const EdgeInsets.all(36.0),
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[

                     Container( child: Image.asset( 'images/bookShare.jpeg', height: 100.0,  fit: BoxFit.contain)),
                     SizedBox(height: 40.0),
                     usernameField,
                     SizedBox(height: 15.0),
                     passwordField,
                     SizedBox( height: 20.0),
                     loginButton,
                     SizedBox(height: 15.0),
                     backButton,
                     Text( userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic)),
                     ])))
         
         ));
   }
}