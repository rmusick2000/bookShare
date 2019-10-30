import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

import 'package:bookShare/utils.dart';
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/models/app_state.dart';

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


      final logoutButton = makeActionButton( context, 'Logout', container.onPressWrapper((){
               Cognito.signOut();
               setState(() {
                     bookState = "illiterate";
                     // XXX conf code, email
                     appState.usernameController.clear();
                     appState.passwordController.clear();
                  });
            }));
      
     Post post;
     final tryMeButton = RaisedButton(
        onPressed: () async
        {
           print( appState.userState.toString() );
           //String data = '{ "Title": "The Last Ship" }';
           String data = '{ "Title": "Digital Fortress" }';

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
                     Text( appState.userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic)),
                     Text( bookState?.toString() ?? "illiterate", style: TextStyle(fontStyle: FontStyle.italic)),
                     ])))
         
            )));
   }
}