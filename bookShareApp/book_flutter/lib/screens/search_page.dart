import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:bookShare/utils.dart';
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/models/app_state.dart';

  

// This returns a promise to a Post class, created by parsing the json response.  a future.
Future<Post> fetchPost( context, gatewayURL, authToken, postData ) async {
   print( "fetchPost " + postData );

   final response =
      await http.post(
         gatewayURL,
         headers: {HttpHeaders.authorizationHeader: authToken},
         body: postData
         );

  if (response.statusCode == 201) {
    return Post.fromJson(json.decode(response.body));
  } else if( response.statusCode == 500 ) {
     print( "RESPONSE: " + response.statusCode.toString() + " " + json.decode(response.body).toString());
     throw Exception('Endpoint failure');
  } else {
     print( "RESPONSE: " + response.statusCode.toString() + " " + json.decode(response.body).toString());
     throw Exception('Server failure');
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




class BookShareSearchPage extends StatefulWidget {
  BookShareSearchPage({Key key}) : super(key: key);

  @override
  _BookShareSearchState createState() => _BookShareSearchState();
}


class _BookShareSearchState extends State<BookShareSearchPage> {

   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   String bookState;
   AppState appState;

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
     appState = container.state;
     // Post post;

     final tryMeButton = RaisedButton(
        onPressed: () async
        {
           notYetImplemented( context );
           /*
           String data = '{ "Endpoint": "FindBook", "Title": "Digital Fortress" }';
           String lambdaAddr = appState.apiBasePath + "/find";
           try{ 
              post = await fetchPost( context, lambdaAddr, appState.idToken, data );
              print( "Got Book: " + post.Title + " " + post.Author);
              setState(() { bookState = post.Title + " written by " + post.Author; });
           } catch( error, trace ) {
              showToast( context, error.toString() );
           }
           */

        },
        child: Text( 'Try me!'));
                        
     return Scaffold(
        appBar: makeTopAppBar( context, "Search" ),
        bottomNavigationBar: makeBotAppBar( context, "Search" ),
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
                          SizedBox(height: 5.0),
                          tryMeButton,
                          SizedBox(height: 5.0),
                          Text( appState.userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic)),
                          Text( bookState?.toString() ?? "illiterate", style: TextStyle(fontStyle: FontStyle.italic))
                          ])))
              
              )));
   }
}
