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

   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   int selectedLibrary = -1;
   bool booksLoaded = true;
   int myRouteNum;

   AppState appState;
   
   @override
   void initState() {
      print( "HOMEPAGE INIT" );
      super.initState();
      myRouteNum = -1;
   }

   @override
   void dispose() {
      super.dispose();
   }
   
   _updateSelectedLibrary( selectedLib ) async {
      print( "UpdateSelectedLib " + selectedLib.toString() );
      if( !appState.booksInLib.containsKey( "lib"+selectedLib.toString() )) {
         setState(() {
               selectedLibrary = selectedLib;
               booksLoaded = false;
            });
      } else {
         setState(() {
               selectedLibrary = selectedLib;
            });
      }

      if( !booksLoaded ) {
         print( "Re-init libBooks for selected: " + selectedLib.toString() );
         await initLibBooks( appState, selectedLib );
         setState(() {
               booksLoaded = true;
            });
      }
   }

   GestureDetector makeLibraryChunk( libraryName, libraryId ) {
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


   
   Widget _makeSelectedLib( libId ) {
      // Selected Lib can be uninitialized briefly
      if( appState.myLibraries == null ) { return Container(); }
      print( "makeSelectedLib" );
      
      Library selectedLib;
      assert( appState.myLibraries.length >= 1 );
      for( final lib in appState.myLibraries ) {
         if( lib.id == libId ) { selectedLib = lib; break; }
      };

      assert( selectedLib != null );
      var name = selectedLib.name;
      var numM = selectedLib.members.length.toString();
      var numB = "99";

      numM += ( numM == "1" ? " member" : " members" );
      numB += ( numB == "1" ? " book" : " books" );

      print( " ... ms: making row" );
      
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


   @override
   Widget build(BuildContext context) {

      final container   = AppStateContainer.of(context);
      appState          = container.state;

      // This page may be on routeStack, keep it from being rebuilt while not on top
      if( !isCurrentRoute( appState, "home", myRouteNum )) {
         return Container();
      }
      print( "Building Home " + myRouteNum.toString() );
      myRouteNum = getRouteNum( appState ); 
      
      Widget makeLibraryRow() {
         List<Widget> libChunks = [];
         // NOTE this will be null for a brief flash of time at init
         if( appState.myLibraries == null ) { return Container(); }
         
         assert( appState.myLibraries.length >= 1 );
         appState.myLibraries.forEach((lib) => libChunks.add( makeLibraryChunk( lib.name, lib.id )));
         
         // XXX ListView me
         return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row (
               mainAxisSize: MainAxisSize.max,
               mainAxisAlignment: MainAxisAlignment.start,
               children: libChunks
               ));
      }

      Widget makeBooks( ) {
         List<Widget> bookChunks = [];
         String libName = "lib" + selectedLibrary.toString();
         print( "makeBooks" );

         var bil = appState.booksInLib[libName];

         // first time through, books have not yet been fetched
         if( appState.booksInLib == null || bil == null || bil.length == 0 || !booksLoaded ) {
            return Container(
               height: appState.screenHeight * .618,
               child:  Center(
                  child: Container(
                     height: appState.screenHeight * .169,
                     child: CircularProgressIndicator() ))
               );
         }
         print( "  mb: going to bil" );
         bil.forEach((book) => bookChunks.add( makeBookChunk( appState, book )));
         
         return Expanded(
            child: SizedBox(
               child: ListView(
                  scrollDirection: Axis.vertical,
                  children: bookChunks
                  )));
      }   

      Widget makeBody() {
         if( appState.loaded ) {

            assert( appState.myLibraries != null );
            if( selectedLibrary == -1 ) {
               _updateSelectedLibrary( appState.myLibraries[0].id );  // XXX
            }
            
            return Center(
               child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,    // required for listView child
                  children: <Widget>[
                     makeLibraryRow(),
                     Divider( color: Colors.grey[200], thickness: 3.0 ),
                     _makeSelectedLib( selectedLibrary ),
                     Divider( color: Colors.grey[200], thickness: 3.0 ),
                     makeBooks( )
                     ]));
         } else {
            return CircularProgressIndicator();
         }
      }

      print( "Build Homepage, scaffold x,y: " + appState.screenWidth.toString() + " " + appState.screenHeight.toString() );
      
      return WillPopScope(
         onWillPop: () => requestPop(context),   // Future<bool> function()
         child: Scaffold(
            appBar: makeTopAppBar( context, "Home" ),
            bottomNavigationBar: makeBotAppBar( context, "Home" ),
            body: makeBody()
            ));
      
   }
}
