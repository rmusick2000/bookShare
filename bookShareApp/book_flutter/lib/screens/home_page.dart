import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:bookShare/screens/my_library_page.dart';
import 'package:bookShare/screens/loan_page.dart';
import 'package:bookShare/screens/search_page.dart';
import 'package:bookShare/screens/home_page.dart';
import 'package:bookShare/screens/add_book_page.dart';
import 'package:bookShare/screens/profile_page.dart';
import 'package:bookShare/screens/book_detail_page.dart';

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
   var container;
   AppState appState;
   bool updateLibRow;                    // to allow joining a lib to show up 
   
   @override
   void initState() {
      print( "HOMEPAGE INIT" );
      super.initState();
      currentBookCount = -1;
      updateLibRow = true;
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
         await initLibBooks( context, container, selectedLib );
         setState(() {
               appState.booksLoaded = true;
               currentBookCount = appState.booksInLib[selectedLib].length;
            });
      }
   }

   
   Widget _makeLibraryChunk( lib ) {
      return GestureDetector(
         onTap: () { _updateSelectedLibrary( lib.id ); },
         child: makeLibraryChunk( lib, appState.screenHeight, false ) 
         );
   }


   Widget _joinText() {
      return  GestureDetector(
         onTap: ()
         {
            updateLibRow = false;
            Library currentLib = null;
            appState.exploreLibraries.forEach((lib) { if( lib.id == appState.selectedLibrary ) { currentLib = lib; } });
            print( "JOINING LIB " + currentLib.name + " " + currentLib.id );
            
            // move from exploreLibraries to myLibraries
            bool removed = appState.exploreLibraries.remove( currentLib );
            assert( removed );
            currentLib.members.add( appState.userId );
            appState.myLibraries.add( currentLib );
            
            // update dynamo
            String newLib = json.encode( currentLib );
            String postData = '{ "Endpoint": "PutLib", "NewLib": $newLib }';               
            putLib( context, container, postData );
            
            print( "SET STATE hompage updatelibrow" );
            setState(() => updateLibRow = true );         // redraw libraryRow
         },
         child: Text( "Join",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.lightBlue, fontWeight: FontWeight.bold)));
   }

   Widget _leaveText() {
      return  GestureDetector(
         onTap: ()
         {
            updateLibRow = false;
            Library currentLib = null;
            appState.myLibraries.forEach((lib) { if( lib.id == appState.selectedLibrary ) { currentLib = lib; } });
            print( "LEAVING LIB " + currentLib.name + " " + currentLib.id );
            
            // move from  myLibraries to exploreLibraries
            bool removed = appState.myLibraries.remove( currentLib );
            assert( removed );
            currentLib.members.remove( appState.userId );
            if( appState.exploreLibraries == null ) { appState.exploreLibraries =  [ currentLib ]; }
            else                                    { appState.exploreLibraries.add( currentLib ); }
            
            // update dynamo
            String newLib = json.encode( currentLib );
            String postData = '{ "Endpoint": "PutLib", "NewLib": $newLib }';               
            putLib( context, container, postData );
            
            print( "SET STATE hompage updatelibrow" );
            setState(() => updateLibRow = true );         // redraw libraryRow
         },
         child: Text( "Leave",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.lightBlue, fontWeight: FontWeight.bold)));
   }

   Widget _memberText() {
      // null if exploreLib, or during early init
      Library currentLib = getLib( appState );  
      if( currentLib.members.indexOf(appState.userId) == -1 ) { return _joinText(); }   // join if not member
      else if( currentLib.members.length > 1 )                { return _leaveText(); }  // exit if more members than 1
      else                                                    { return Container(); } 
   }

   Widget _requestText( bookId ) {
      Library currentLib = getMemberLib( appState );
      final bil = appState.booksInLib;
      bool myBook =  false;

      // XXX Slow.. good thing it's lazy
      if( bil != null && bil[appState.privateLibId] != null ) {
         for( final book in bil[appState.privateLibId] ) {
            if( book.id == bookId ) { myBook = true; break; }
         }
      }

      if( currentLib != null && currentLib.members.indexOf(appState.userId) != -1 && !myBook ) {
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

      // when navigate to home page, privateLib will be on top, and updateSelLib has not been called.
      if( currentBookCount == -1 && libId == appState.privateLibId ) {
         currentBookCount = appState.booksInLib[appState.privateLibId].length;
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
               Text( name, key: Key( name ), style: TextStyle(fontSize: 14)),
               Text( numM, style: TextStyle(fontSize: 14)),
               Text( numB, style: TextStyle(fontSize: 14)),
               _memberText()
               ]
            ));
   }   

  /// XXX How much overlap with add_book?
  // Title will wrap if need be, growing row height as needed
  GestureDetector makeBookChunkCol( appState, book ) {
     final imageHeight = appState.screenHeight * .45;
     final imageWidth  = appState.screenWidth * .42;
     const inset       = 20.0;
     
     var image;
     if( book.image != "---" ) { image = Image.network( book.image, height: imageHeight, width: imageWidth, fit: BoxFit.contain ); }
     else                      { image = Image.asset( 'images/blankBook.jpeg', height: imageHeight, width: imageWidth, fit: BoxFit.contain); }
     
     return GestureDetector(
        onTap:  ()
        {
           setState(() { appState.detailBook = book; });
           Navigator.push( context, MaterialPageRoute(builder: (context) => BookShareBookDetailPage()));
        },
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
              makeTitleText( book.title, imageWidth-inset-6, true, 2 ),
              makeAuthorText( book.author, imageWidth, true, 1 ),
              paddedLTRB( _requestText( book.id ), inset, 0, 6, 0 )
              ]));
  }
  
   @override
   Widget build(BuildContext context) {

      container   = AppStateContainer.of(context);
      appState    = container.state;

      // ListView horizontal messes with singleChildScroll (to prevent overflow on orientation change). only on this page.
      SystemChrome.setPreferredOrientations([ DeviceOrientation.portraitUp, DeviceOrientation.portraitDown ]);
      
      Widget _makeLibraryRow() {
         List<Widget> libChunks = [];
         if( appState.myLibraries == null || !updateLibRow ) { return Container(); }  // null during update
            
         assert( appState.myLibraries.length >= 1 );
         appState.myLibraries.forEach((lib) => libChunks.add( _makeLibraryChunk( lib )));

         if( appState.exploreLibraries != null && appState.exploreLibraries.length >= 1 )
         {
            libChunks.add( paddedLTRB( VerticalDivider( color: Colors.grey[200], thickness: 3.0 ), 6, 12, 0, 12));
            appState.exploreLibraries.forEach((lib) => libChunks.add( _makeLibraryChunk( lib )));
         }
         
         // Hmm.. why doesn't a simple SizedBox work here?
         return ConstrainedBox( 
            constraints: new BoxConstraints(
               minHeight: 20.0,
               //maxHeight: appState.screenHeight * .1523
               maxHeight: appState.screenHeight * .159
               ),
            child: ListView(
               scrollDirection: Axis.horizontal,
               children: libChunks
               ));
      }

      Widget _makeBooks( ) {
         List<Widget> bookChunks = [];
         String libName = appState.selectedLibrary;

         var bil = appState.booksInLib[libName];

         // first time through, books have not yet been fetched
         if( appState.booksInLib == null || bil == null || !appState.booksLoaded ) {
            return Container(
               height: appState.screenHeight * .60,
               child:  Center(
                  child: Container(
                     height: appState.screenHeight * .169,
                     child: CircularProgressIndicator() ))
               );
         } else if ( bil.length == 0 ) {
            return Container(
               height: appState.screenHeight * .60,
               child:  Center(
                  child: Container(
                     height: appState.screenHeight * .169,
                     child: Text("No books yet..", style: TextStyle(fontSize: 16))))
               );
         }

         bil.forEach((book) => bookChunks.add( makeBookChunkCol( appState, book )));
         
         return Expanded(
            child: SizedBox(
               child: ListView(
                  key: Key( "searchedBooks" ),                  
                  scrollDirection: Axis.horizontal,
                  children: bookChunks
                  )));
      }   

      Widget _makeBody() {
         if( appState.loaded ) {
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
