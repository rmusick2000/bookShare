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
import 'package:bookShare/models/books.dart';

// XXX REFACTOR!! 

class LibraryParts {

   final apiBasePath;
   final authToken;
   final updateFn;
   
   LibraryParts(this.apiBasePath, this.authToken, this.updateFn);

   Future<List<Library>> fetchLibraries( postData ) async {
      print( "fetchLibrary " + postData );
      final gatewayURL = apiBasePath + "/find"; 
         
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
         throw Exception('Failed to load library');
      }
   }

   // XXX 1 func for all here?  
   Future<List<Book>> fetchBooks( postData ) async {
      print( "fetchBook " + postData );
      final gatewayURL = apiBasePath + "/find"; 
         
      final response =
         await http.post(
            gatewayURL,
            headers: {HttpHeaders.authorizationHeader: authToken},
            body: postData
            );

      if (response.statusCode == 201) {
         print( response.body.toString() );         

         Iterable l = json.decode(response.body);
         List<Book> books = l.map((sketch)=> Book.fromJson(sketch)).toList();
         return books;
      } else {
         print( "RESPONSE: " + response.statusCode.toString() + " " + json.decode(response.body).toString());
         throw Exception('Failed to load books');
      }
   }

   GestureDetector makeLibraryChunk( libraryName, libraryId ) {
      return GestureDetector(
         onTap: () { updateFn( libraryId ); },
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

   // XXX mediaquery to appstate
   GestureDetector makeBookChunk( context, title, author, isbn ) {
      return GestureDetector(
         onTap: () { print( "Giggle!" ); },
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
               Container(
                  color: Colors.lightGreen[100],
                  height:100,
                  constraints: BoxConstraints(
                         maxHeight: 100.0,
                         minWidth: MediaQuery.of(context).size.width
                     ),
                  child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: <Widget>[
                        Text(title, style: TextStyle(fontSize: 12)),
                        Text("By: " + author, style: TextStyle(fontSize: 12)),
                        Text("ISBN: " + isbn, style: TextStyle(fontSize: 12)),
                        ])),
               Container( color: Colors.lightBlue, height:20 ),
               ]));
   }
   
}



class BookShareHomePage extends StatefulWidget {
   BookShareHomePage({Key key}) : super(key: key);

  @override
  _BookShareHomeState createState() => _BookShareHomeState();
}

class _BookShareHomeState extends State<BookShareHomePage> {

   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   LibraryParts libraryBar;
   List<Library> myLibraries = null;
   Map<String, List<Book>> booksInLib = new Map<String, List<Book>>();
   int selectedLibrary = -1;

   AppState appState;
   
   @override
   void initState() {
      super.initState();
      print( "InitHomepage" );
      // async call delegates the call until after initialization, then use context 
      // Future.delayed with 0 completes no sooner than in the next event-loop iteration, after all microtasks have run.
      if( selectedLibrary == -1 ) {
         print( "Init Libs" );
         // duration.zero fails when uninstall/reinstall app for existing user.  100ms works.. 200 to be safe
         Future.delayed( Duration(milliseconds: 200 ),() { initMyLibraries( context );  });
      }
   }

   @override
   void dispose() {
      super.dispose();
   }

   initMyLibraries( context ) async {
      libraryBar  = LibraryParts( appState.apiBasePath, appState.idToken, updateSelectedLibrary );   
      myLibraries = await libraryBar.fetchLibraries( '{ "Endpoint": "GetLibs" }' );
      initSelectedLibrary();
   }

   initSelectedLibrary() {
      print( "InitSelectedLib" );
      assert( myLibraries.length >= 1 );
      updateSelectedLibrary( myLibraries[0].id );   // XXX XXX XXX
      initLibBooks();
   }

   initLibBooks() async {
      print( "InitLIBBOOKS" );
      booksInLib["lib"+selectedLibrary.toString()] = await libraryBar.fetchBooks( '{ "Endpoint": "GetBooks", "SelectedLib": $selectedLibrary }' );  
   }
     
   
   updateSelectedLibrary( selectedLib ) {
      print( "UpdateSelectedLib " + selectedLib.toString() );
      setState(() { selectedLibrary = selectedLib; } );
   }
   
   Widget makeSelectedLib( libId ) {
      // Selected Lib can be uninitialized briefly
      if( myLibraries == null ) { return Container(); }
      print( "makeSelectedLib" );
      
      Library selectedLib;
      assert( myLibraries.length >= 1 );
      for( final lib in myLibraries ) {
         if( lib.id == libId ) { selectedLib = lib; break; }
      };

      assert( selectedLib != null );
      var name = selectedLib.name;
      var numM = selectedLib.members.length.toString();
      var numB = "99";

      numM += ( numM == "1" ? " member" : " members" );
      numB += ( numB == "1" ? " book" : " books" );
          
      return Padding(
         padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
         child: Row (
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget> [
               Text( name, style: TextStyle(fontSize: 14)),
               Text( numM, style: TextStyle(fontSize: 14)),
               Text( numB, style: TextStyle(fontSize: 14)) 
               ]
            ));
   }   

   Widget makeLibraryRow() {
      List<Widget> libChunks = [];
      // NOTE this will be null for a brief flash of time at init
      if( myLibraries == null ) { return CircularProgressIndicator(); }

      assert( myLibraries.length >= 1 );
      myLibraries.forEach((lib) => libChunks.add( libraryBar.makeLibraryChunk( lib.name, lib.id )));
      
      // XXX ListView me
      return SingleChildScrollView(
         scrollDirection: Axis.horizontal,
         child: Row (
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: libChunks
            ));
   }


   @override
   Widget build(BuildContext context) {

      final container   = AppStateContainer.of(context);
      appState          = container.state;
      // Keep this here.  Else, on first init after uninstall, initMyLibs may not yet have finished, leading to RSOD
      final libraryBar  = LibraryParts( appState.apiBasePath, appState.idToken, updateSelectedLibrary );

      print( "Build Homepage" );

      // XXX this won't update, not currently dependent on selectedLib
      // XXX NOTE!  Need a dict of selectedLib : books.  Else, no cache, slow on click
      Widget makeBooks( selectedLib ) {
         List<Widget> bookChunks = [];
         print( makeBooks );
         if( booksInLib == null ) { print( "Fak"); return Container(); }

         if( !booksInLib.containsKey( "lib"+selectedLib.toString() )) {
            print( "Re-init libBooks for selected: " + selectedLib.toString() );
            initLibBooks();
         }
         
         var bil = booksInLib["lib"+selectedLib.toString()];
         // XXXX why?
         // assert( bil != null );
         if( bil == null || bil.length == 0 ) { print( "Fik"); return Container(); }

         // XXX could save widgets if time-pressed
         bil.forEach((book) => bookChunks.add( libraryBar.makeBookChunk( context, book.title, book.author, book.ISBN )));
         
         return Expanded(
            child: SizedBox(
               child: ListView(
                  scrollDirection: Axis.vertical,
                  children: bookChunks
                  )));
      }   

      
      return Scaffold(
         appBar: makeTopAppBar( context, "Home" ),
         bottomNavigationBar: makeBotAppBar( context, "Home" ),
         body: Center(
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.start,
               mainAxisSize: MainAxisSize.min,    // required for listView child
               children: <Widget>[
                  makeLibraryRow(),
                  Divider( color: Colors.grey[200], thickness: 3.0 ),
                  makeSelectedLib( selectedLibrary ),
                  Divider( color: Colors.grey[200], thickness: 3.0 ),
                  makeBooks( selectedLibrary )
                  ])));
   }
}





   /*
   // This worked well, with 2 critical flaws.
   //  1. Build gets called often, which forces this to retrigger, often.  
   //  2. In order to handle initialization properly, would need to chain these - ugly.
   // XXX listViewBuilder?
   Widget makeLibraryRow() {
      String gatewayURL = apiBasePath + "/find";
      String data = '{ "Endpoint": "GetLibs" }';
      List<Widget> libChunks = [];

      return FutureBuilder(
         future: fetchLibraries( gatewayURL, authToken, data ),
         builder: (context, snapshotData)
         {
            // print( "in Builder" );
            if (snapshotData.connectionState == ConnectionState.done ) {
               //print( snapshotData.data );
               snapshotData.data.forEach((lib) => libChunks.add( _makeLibraryChunk( lib.name, lib.id )));

               // cant set state during build
               // updateFn( snapshotData.data[0].id );
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
   */

