import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:bookShare/screens/my_library_page.dart';
import 'package:bookShare/screens/loan_page.dart';
import 'package:bookShare/screens/search_page.dart';
import 'package:bookShare/screens/home_page.dart';
import 'package:bookShare/screens/add_book_page.dart';
import 'package:bookShare/screens/profile_page.dart';

import 'package:bookShare/utils.dart';
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/models/libraries.dart';


// XXX Hmm... push to models?    go MVC?
class LibraryParts {

   final apiBasePath;
   final authToken;

   LibraryParts(this.apiBasePath, this.authToken);

   // When populating libraryBar, do not need list of members.
   Future<List<Library>> _fetchLibrary( gatewayURL, authToken, postData ) async {
      print( "fetchLibrary " + postData );
      
      final response =
         await http.post(
            gatewayURL,
            headers: {HttpHeaders.authorizationHeader: authToken},
            body: postData
            );

      if (response.statusCode == 201) {
         print( response.body.toString() );         

         Iterable l = json.decode(response.body);
         List<Library> libs = l.map((sketch)=> Library.fromJson(sketch)).toList();
         return libs;
      } else {
         print( "RESPONSE: " + response.statusCode.toString() + " " + json.decode(response.body).toString());
         throw Exception('Failed to load librarySketch');
      }
   }

   GestureDetector _makeLibraryChunk( libraryName ) {
      return GestureDetector(
         onTap: () { print(libraryName + " clicked"); },
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
               Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0, 0.0),
                  child: ClipRRect(
                     borderRadius: new BorderRadius.circular(12.0),
                     child: Image.asset( 'images/kiteLibrary.jpg', height: 60.0, width: 60.0, fit: BoxFit.fill))),
               Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 4.0, 0, 0.0),
                  child: Text(libraryName, style: TextStyle(fontSize: 12)))])
         );
   }

   // XXX listViewBuilder?
   Widget makeLibraryRow( authToken) {
      String gatewayURL = apiBasePath + "/find";
      String data = '{ "Endpoint": "GetLibs" }';
      List<Widget> libChunks = [];

      return FutureBuilder(
         future: _fetchLibrary( gatewayURL, authToken, data ),
         builder: (context, snapshotData)
         {
            // print( "in Builder" );
            if (snapshotData.connectionState == ConnectionState.done ) {
               //print( snapshotData.data );
               snapshotData.data.forEach((lib) => libChunks.add( _makeLibraryChunk( lib.name )));

               return
                  SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: Row (
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: libChunks
                        ));
            }
            else {
               // CircularProgressIndicator
               return Container();
            }
         });
   }
}



class BookShareHomePage extends StatefulWidget {
  BookShareHomePage({Key key}) : super(key: key);

  @override
  _BookShareHomeState createState() => _BookShareHomeState();
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

      final container = AppStateContainer.of(context);
      final appState = container.state;
      final libraryBar = LibraryParts( appState.apiBasePath, appState.idToken );
         
      return Scaffold(
         appBar: makeTopAppBar( context, "Home" ),
         bottomNavigationBar: makeBotAppBar( context, "Home" ),
         body: Center(
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.start,
               children: <Widget>[
                  libraryBar.makeLibraryRow( appState.idToken ),
                  Divider( color: Colors.grey[200], thickness: 3.0 ),
                  
                  SingleChildScrollView( 
                     child: Container(
                        color: Colors.white,
                        child: Padding(
                           padding: const EdgeInsets.all(36.0),
                           child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                 SizedBox(height: 5.0),
                                 Text( "Home", style: TextStyle(fontWeight: FontWeight.bold)),
                                 SizedBox(height: 5.0),
                                 Text( appState.userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic)),
                                 ]))))
                  ])));
   }
}
