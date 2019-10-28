import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


// android/app/src/main/res/raw/awsconfiguration.json
class BookShareLoginPage extends StatefulWidget {
  BookShareLoginPage({Key key}) : super(key: key);

  @override
  _BookShareLoginState createState() => _BookShareLoginState();
}

Future<String> loadAsset(BuildContext context) async {
   return await DefaultAssetBundle.of(context).loadString('files/api_base_path.txt');
}
  

// This returns a promise to a Post class, created by parsing the json response.  a future.
Future<Post> fetchPost( context, postFunc, authToken, postData ) async {
   print( "fetchPost " + authToken );
   final gatewayURL = (await loadAsset( context )).trim() + postFunc;

   final response =
      await http.post(
         gatewayURL,
         headers: {HttpHeaders.authorizationHeader: authToken},
         body: postData
         );

  if (response.statusCode == 201) {
    // If the call to the server was successful, parse the JSON.
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
     print( "RESPONSE: " + response.statusCode.toString() + " " + json.decode(response.body).toString());
     throw Exception('Failed to load post');
  }
}

class Post {
   final int bookId;
   final String BookTitle;
   final String Author;
   final int MagicCookie;
   final String User;

   Post({this.bookId, this.BookTitle, this.Author, this.MagicCookie, this.User});

   
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      bookId: json['bookId'],
      BookTitle: json['BookTitle'],
      Author: json['Author'],
      //MagicCookie: int.parse( json['MagicCookie'] ),
      MagicCookie: json['MagicCookie'],
      User: json['User'],
    );
  }
}




class _BookShareLoginState extends State<BookShareLoginPage> {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   var returnValue;
   UserState userState;
   double progress;
   String bookState;
   final usernameController = TextEditingController();
   final passwordController = TextEditingController();
   final attributeController = TextEditingController();
   final confirmationCodeController = TextEditingController();

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
    attributeController.dispose();
    confirmationCodeController.dispose();
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
     final emailField = TextField(
        obscureText: false,
        style: style,
        decoration: InputDecoration(
           contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
           hintText: "email address",
           border:
           OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        controller: attributeController,
        );
     final confirmationCodeField = TextField(
        obscureText: false,
        style: style,
        decoration: InputDecoration(
           contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
           hintText: "confirmation code",
           border:
           OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
        controller: confirmationCodeController,
        );
     final loginButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
           // minWidth: MediaQuery.of(context).size.width,
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
     final logoutButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
           //minWidth: MediaQuery.of(context).size.width,
           padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
           onPressed: onPressWrapper(() {
                 Cognito.signOut();
                 setState(() {
                       bookState = "illiterate";
                       usernameController.clear();
                       passwordController.clear();
                       attributeController.clear();
                       confirmationCodeController.clear();
                    });
              }),
           child: Text("Logout",
                       textAlign: TextAlign.center,
                       style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
           ),
        );
     // XXX Very easy to break ATM.  no email provided?  no confirmation possible.
     // XXX Need good error checking in here.
     final signupButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
           //minWidth: MediaQuery.of(context).size.width,
           padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
           onPressed: onPressWrapper(() {
                 final email = {'email' : attributeController.text };
                 Cognito.signUp( usernameController.text, passwordController.text, email );
                 // XXX inform user to look for email
              }),
           child: Text("Signup",
                       textAlign: TextAlign.center,
                       style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
           ),
        );
     final confirmSignupButton = Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff01A0C7),
        child: MaterialButton(
           //minWidth: MediaQuery.of(context).size.width,
           padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
           // onPressed: onPressWrapper(() => Cognito.signOut()),
           onPressed: onPressWrapper(() {
                 Cognito.confirmSignUp( usernameController.text, confirmationCodeController.text );
              }),
           child: Text("Confirm Signup",
                       textAlign: TextAlign.center,
                       style: style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
           ),
        );


     // Future<Post> post;
     Post post;
     final backButton = RaisedButton(
        // onPressed: () { Navigator.pop( context ); },
        // child: Text( 'Go Back!'));
        onPressed: () async
        {
           print( userState.toString() );
           String data = '{ "BookTitle": "The Last Ship" }';
           //String data = '{ "BookTitle": "Digital Fortress" }';

           // XXX crappy return value here.. 
           //Map authToken = json.decode( tokenString ).acessToken();
           List tokenString = (await Cognito.getTokens()).toString().split(" ");
           // accessToken
           // String authToken = tokenString[3].split(",")[0];
           // idToken
           String authToken = tokenString[5].split(",")[0];

           post = await fetchPost( context, "/find", authToken, data );
           print("MAGIC COOKIES! " + post.MagicCookie.toString());
           setState(() { bookState = post.BookTitle + " written by " + post.Author; });
        },
        child: Text( 'Try me!'));
                        

     // XXX convert backButton to return with userState
     return Scaffold(
      appBar: AppBar( title: Text( "Login page" )),
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
                     Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [ loginButton, logoutButton ] ),
                     Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [ signupButton, confirmSignupButton ] ),
                     SizedBox(height: 5.0),
                     backButton,
                     Text( userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic)),
                     Text( bookState?.toString() ?? "illiterate", style: TextStyle(fontStyle: FontStyle.italic)),
                     ])))
         
            )));
   }
}
