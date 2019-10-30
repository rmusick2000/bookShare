import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:bookShare/utils.dart';

class BookShareHomePage extends StatefulWidget {
  BookShareHomePage({Key key}) : super(key: key);

  @override
  _BookShareHomeState createState() => _BookShareHomeState();
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
   final String Title;
   final String Author;
   final String MagicCookie;
   final String User;

   Post({this.bookId, this.Title, this.Author, this.MagicCookie, this.User});

   
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      bookId: json['bookId'],
      Title: json['Title'],
      Author: json['Author'],
      MagicCookie: json['MagicCookie'],
      User: json['User'],
    );
  }
}




class _BookShareHomeState extends State<BookShareHomePage> {

   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   String bookState;
   var returnValue;
   UserState userState;
   double progress;
   
   // XXX Split this to auth.dart
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

      // XXX _

     final logoutButton = makeActionButton( context, 'Logout', onPressWrapper((){
              Cognito.signOut();
              setState(() {
                    bookState = "illiterate";
                    // XXX conf code, email
                    // XXX usernameController.clear();
                    // XXX passwordController.clear();
                 });
           }));

     Post post;
     final tryMeButton = RaisedButton(
        onPressed: () async
        {
           print( userState.toString() );
           String data = '{ "Title": "The Last Ship" }';
           //String data = '{ "Title": "Digital Fortress" }';

           // XXX crappy return value here.. 
           //Map authToken = json.decode( tokenString ).acessToken();
           List tokenString = (await Cognito.getTokens()).toString().split(" ");
           // accessToken
           // String authToken = tokenString[3].split(",")[0];
           // idToken
           String authToken = tokenString[5].split(",")[0];

           post = await fetchPost( context, "/find", authToken, data );
           print("MAGIC COOKIES! " + post.MagicCookie.toString());
           setState(() { bookState = post.Title + " written by " + post.Author; });
        },
        child: Text( 'Try me!'));
                        
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
                     logoutButton,
                     SizedBox(height: 5.0),
                     tryMeButton,
                     SizedBox(height: 5.0),
                     Text( userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic)),
                     Text( bookState?.toString() ?? "illiterate", style: TextStyle(fontStyle: FontStyle.italic)),
                     ])))
         
            )));
   }
}
