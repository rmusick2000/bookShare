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
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/models/libraries.dart';
import 'package:bookShare/models/books.dart';


class BookShareMyLibraryPage extends StatefulWidget {
  BookShareMyLibraryPage({Key key}) : super(key: key);

  @override
  _BookShareMyLibraryState createState() => _BookShareMyLibraryState();
}


class _BookShareMyLibraryState extends State<BookShareMyLibraryPage> {

   AppState appState;
   String contentView;
   String selectedLib;
   
   @override
   void initState() {
      super.initState();
      contentView = "grid";
      selectedLib = "";
   }
   
   
   @override
   void dispose() {
      super.dispose();
   }

   // IconButton theme likes 48 pixel spread, which is huge.  use GD instead.
   Widget _makeContextMenu( context ) {

      Library myLib;
      for( final lib in appState.myLibraries ) {
         if( lib.id == appState.privateLibId ){ myLib = lib; break; }
      }
         
      return Row( 
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: <Widget>[
            Row( 
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.start,
               children: <Widget>[
                  Padding(
                     padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                     child: Column( 
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                           Text( myLib.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                           Text( "99 books", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
                           ])),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                     child: GestureDetector( 
                        onTap:  ()
                        {
                           notYetImplemented( context );
                           setState(() { contentView = "create"; });
                        },
                        child: Icon( Icons.fiber_new )
                        )),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                     child: GestureDetector( 
                        onTap:  ()
                        {
                           setState(() { contentView = "share"; });
                        },
                        child: Icon( Icons.create )
                        ))
                  ]),
                  Row( 
                     crossAxisAlignment: CrossAxisAlignment.center,
                     mainAxisAlignment: MainAxisAlignment.start,
                     children: <Widget>[
                        Padding(
                           padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                           child: GestureDetector( 
                              onTap:  ()
                              {
                                 setState(() { contentView = "grid"; });
                              },
                              child: Icon( Icons.apps )
                              )),
                        Padding(
                           padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                           child: GestureDetector( 
                              onTap:  ()
                              {
                                 notYetImplemented( context );
                                 setState(() { contentView = "list"; });
                              },
                              child: Icon( Icons.list )
                              )),
                        Padding(
                           padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                           child: GestureDetector( 
                              onTap:  ()
                              {
                                 notYetImplemented( context );
                                 setState(() { contentView = "full"; });
                              },
                              child: Icon( Icons.fullscreen )
                              )),
                        ])]);
   }

   Widget _makeBookChunkSmall( book ) {
     final imageHeight = appState.screenHeight * .36;
     final imageWidth  = imageHeight;
     
     var image;
     if( book.image != "---" ) { image = Image.network( book.image, height: imageHeight, width: imageWidth, fit: BoxFit.contain ); }
     else                      { image = Image.asset( 'images/blankBook.jpeg', height: imageHeight, width: imageWidth, fit: BoxFit.contain); }
     
     return GestureDetector(
           onTap:  ()
           {
              setState(() { appState.detailBook = book; });
              Navigator.push( context, MaterialPageRoute(builder: (context) => BookShareBookDetailPage()));
           },
           child: ClipRRect( borderRadius: new BorderRadius.circular(12.0), child: image )
           );
  }

   // gridview controls object sizing
   Widget _gridView( bookChunks ) {
      return GridView.count(
         primary: false,
         scrollDirection: Axis.vertical,
         padding: const EdgeInsets.all(0),
         crossAxisSpacing: 0,
         mainAxisSpacing: 12,
         crossAxisCount: 3,
         children: bookChunks
         );
   }

   
   Widget _shareView() {

      // XXX ouch.. utils, homepage namespace issues  going too fast here
      Widget libChunk = Container();
      List<Widget> libChunks = [];
      Library result;

      // XXX tmp
      selectedLib = appState.privateLibId;
      
      if( selectedLib != "" ) {
         for( final lib in appState.myLibraries ) {
            if( lib.id == selectedLib ) { result = lib; break; }
         }
         assert( result != null );
         libChunk = makeLibraryChunk( appState, result.name, result.id );
         
         assert( appState.myLibraries.length >= 1 );
         appState.myLibraries.forEach((lib) => libChunks.add( makeLibraryChunk( appState, lib.name, lib.id )));
      }
      
      return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.start,
         children: <Widget>[
            Row( 
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.start,
               children: <Widget>[
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12, 20, 0, 0),
                     child: Text( "Sharing with:" , style: TextStyle(fontSize: 16 ))),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                     child: libChunk),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(6, 12, 0, 12),
                     child: VerticalDivider( color: Colors.grey[200], thickness: 3.0 )),
                  Expanded( child: ConstrainedBox( 
                               constraints: new BoxConstraints(
                                  minHeight: 20.0,
                                  maxHeight: appState.screenHeight * .1523
                                  ),
                               child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: libChunks
                                  )))
                  ]),
            ]);
   }

   
   Widget _makeContent() {
      List<Widget> bookChunks = [];

      print( contentView );
      
      if( contentView == "grid" || contentView == "list" || contentView == "full" )
      {
         if( appState.booksInLib == null ) { return Container(); }
         final bil = appState.booksInLib[appState.privateLibId];
         if( bil == null ) { return Container(); }

         bil.forEach((book) => bookChunks.add( _makeBookChunkSmall( book )));
      }
         
      Widget content;
      if( contentView == "grid" )       { content = _gridView( bookChunks ); }
      else if( contentView == "share" ) { content = _shareView(); }
      else                              { content = Container(); }
      
      return content;
   }



   // !! use this and column starts in center..???
   // mainAxisSize: MainAxisSize.min,    
   Widget _makeBody() {
      return Center(
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
               _makeContextMenu( context ),
               Divider( color: Colors.grey[200], thickness: 3.0, height: 3.0 ),
               SizedBox( height: appState.screenHeight * .76, child: _makeContent( ) )
               ]));
   }
   

  
   @override
   Widget build(BuildContext context) {

      final container = AppStateContainer.of(context);
      appState = container.state;
      
      return Scaffold(
         appBar: makeTopAppBar( context, "MyLibrary" ),
         bottomNavigationBar: makeBotAppBar( context, "MyLibrary" ),
         body: _makeBody()
         );
   }
}
