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
import 'package:bookShare/utils_load.dart';
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/models/libraries.dart';
import 'package:bookShare/models/books.dart';


class BookShareHomePage extends StatefulWidget {
   BookShareHomePage({Key key}) : super(key: key);

  @override
  _BookShareHomeState createState() => _BookShareHomeState();
}

class _BookShareHomeState extends State<BookShareHomePage> {

   // XXX make this consistent in appState, and use it
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   
   int currentBookCount;
   AppState appState;
   
   @override
   void initState() {
      print( "HOMEPAGE INIT" );
      super.initState();
      currentBookCount = -1;
   }

   @override
   void dispose() {
      super.dispose();
   }

   _updateSelectedLibrary( selectedLib ) async {
      print( "UpdateSelectedLib " + selectedLib );
      if( !appState.booksInLib.containsKey( selectedLib )) {
         setState(() {
               appState.selectedLibrary = selectedLib;
               appState.booksLoaded = false;
            });
      } else {
         setState(() {
               appState.selectedLibrary = selectedLib;
               currentBookCount = appState.booksInLib[selectedLib].length;
            });
      }

      if( !appState.booksLoaded ) {
         print( "Re-init libBooks for selected: " + selectedLib );
         await initLibBooks( appState, selectedLib );
         setState(() {
               appState.booksLoaded = true;
               currentBookCount = appState.booksInLib[selectedLib].length;
            });
      }
   }

   GestureDetector _makeLibraryChunk( libraryName, libraryId ) {
      final imageSize = appState.screenHeight * .1014;
      return GestureDetector(
         onTap: () { _updateSelectedLibrary( libraryId ); },
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
               Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0, 0.0),
                  child: ClipRRect(
                     borderRadius: new BorderRadius.circular(12.0),
                     child: Image.asset( 'images/kiteLibrary.jpg', height: imageSize, width: imageSize, fit: BoxFit.fill))),
               Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 4.0, 0, 0.0),
                  child: Text(libraryName, style: TextStyle(fontSize: 12)))])
         );
   }


   GestureDetector _joinText() {
      return  GestureDetector(
         onTap: ()  { notYetImplemented(context); },
         child: Text( "Join",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.lightBlue, fontWeight: FontWeight.bold)));

   }
   Widget _requestText() {
      Library currentLib = getCurrentLib( appState );
      if( currentLib == null || currentLib.members.indexOf(appState.userId) == -1 ) {
         return GestureDetector(
            onTap: () { notYetImplemented(context); },
            child: Text( "Request",
                         textAlign: TextAlign.center,
                         style: TextStyle(fontSize: 14, color: Colors.lightBlue, fontWeight: FontWeight.bold)));
      }
      else { return Container(); }
   }
   
   Widget _makeSelectedLib( libId ) {
      // Selected Lib can be uninitialized briefly
      if( appState.myLibraries == null ) { return Container(); }
      print( "makeSelectedLib" );
      
      Library selectedLib;
      assert( appState.myLibraries.length >= 1 );
      for( final lib in appState.myLibraries ) {
         if( lib.id == libId ) { selectedLib = lib; break; }
      };

      // picked exploreLib
      if( selectedLib == null ) {
         for( final lib in appState.exploreLibraries ) {
            if( lib.id == libId ) { selectedLib = lib; break; }
         };
      }
      
      assert( selectedLib != null );
      var name = selectedLib.name;
      var numM = selectedLib.members.length.toString();
      var numB = currentBookCount.toString();

      numM += ( numM == "1" ? " member" : " members" );
      numB += ( currentBookCount == "1" ? " book" : " books" );

      return Padding(
         padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
         child: Row (
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget> [
               Text( name, style: TextStyle(fontSize: 14)),
               Text( numM, style: TextStyle(fontSize: 14)),
               Text( numB, style: TextStyle(fontSize: 14)),
               _joinText()
               ]
            ));
   }   

  /// XXX How much overlap with add_book?
  // Title will wrap if need be, growing row height as needed
  GestureDetector makeBookChunkCol( appState, book ) {
     final imageHeight = appState.screenHeight * .46;
     final imageWidth  = appState.screenWidth * .42;
     const inset       = 20.0;
     
     var image;
     if( book.image != "" && book.image != "bla" ) { image = Image.network( book.image, height: imageHeight, width: imageWidth, fit: BoxFit.contain ); }
     else                                          { image = Image.asset( 'images/blankBook.jpeg', height: imageHeight, width: imageWidth, fit: BoxFit.contain); }
     
     return GestureDetector(
        onTap:  () { print( "I LOVE " + book.title + " .. *giggle*" ); },
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.center,
           mainAxisSize: MainAxisSize.min,
           children: <Widget>[
              Padding(
                 padding: const EdgeInsets.fromLTRB(6.0, 0, 6.0, 0),
                 child: ClipRRect(
                    borderRadius: new BorderRadius.circular(12.0),
                    child: image )),
              Padding(
                 padding: const EdgeInsets.fromLTRB(inset, 6, 6, 0),
                 child: Container( width: imageWidth-inset-6,
                                   child: Text(book.title, softWrap: true, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))),
              Padding(
                 padding: const EdgeInsets.fromLTRB(inset, 0, 6, 0),
                 child: Text("By: " + book.author, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic))),
              Padding(
                 padding: const EdgeInsets.fromLTRB(inset, 0, 6, 0),
                 child: _requestText())
              ]));
  }

   @override
   Widget build(BuildContext context) {

      final container   = AppStateContainer.of(context);
      appState          = container.state;

      Widget _makeLibraryRow() {
         List<Widget> libChunks = [];
         // NOTE this will be null for a brief flash of time at init
         if( appState.myLibraries == null ) { return Container(); }
         
         assert( appState.myLibraries.length >= 1 );
         appState.myLibraries.forEach((lib) => libChunks.add( _makeLibraryChunk( lib.name, lib.id )));

         if( appState.exploreLibraries != null && appState.exploreLibraries.length >= 1 )
         {
            appState.exploreLibraries.forEach((lib) => libChunks.add( _makeLibraryChunk( lib.name, lib.id )));
         }
         
         // XXX ListView me
         return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row (
               mainAxisSize: MainAxisSize.max,
               mainAxisAlignment: MainAxisAlignment.start,
               children: libChunks
               ));
      }

      Widget _makeBooks( ) {
         List<Widget> bookChunks = [];
         String libName = appState.selectedLibrary;
         print( "makeBooks" );

         var bil = appState.booksInLib[libName];

         // first time through, books have not yet been fetched
         if( appState.booksInLib == null || bil == null || !appState.booksLoaded ) {
            return Container(
               height: appState.screenHeight * .618,
               child:  Center(
                  child: Container(
                     height: appState.screenHeight * .169,
                     child: CircularProgressIndicator() ))
               );
         } else if ( bil.length == 0 ) {
            return Container(
               height: appState.screenHeight * .618,
               child:  Center(
                  child: Container(
                     height: appState.screenHeight * .169,
                     child: Text("No books yet..", style: TextStyle(fontSize: 16))))
               );
         }
         print( "  mb: going to bil" );
         bil.forEach((book) => bookChunks.add( makeBookChunkCol( appState, book )));
         
         return Expanded(
            child: SizedBox(
               child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: bookChunks
                  )));
      }   

      Widget _makeBody() {
         if( appState.loaded ) {
            print( "AppState Loaded" );
            assert( appState.myLibraries != null );
            if( appState.selectedLibrary == "") {
               _updateSelectedLibrary( appState.privateLibId ); 
            }
            
            return Center(
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,    // required for listView child
                  children: <Widget>[
                     _makeLibraryRow(),
                     Divider( color: Colors.grey[200], thickness: 3.0 ),
                     _makeSelectedLib( appState.selectedLibrary ),
                     Divider( color: Colors.grey[200], thickness: 3.0 ),
                     _makeBooks( )
                     ]));
         } else {
            print( "AppState not ? Loaded" );
            return CircularProgressIndicator();
         }
      }

      print( "Build Homepage, scaffold x,y: " + appState.screenWidth.toString() + " " + appState.screenHeight.toString() );
      
      return Scaffold(
         appBar: makeTopAppBar( context, "Home" ),
         bottomNavigationBar: makeBotAppBar( context, "Home" ),
         body: _makeBody()
         );
   }
}
