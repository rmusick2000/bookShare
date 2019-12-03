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


class BookShareMyLibraryPage extends StatefulWidget {
  BookShareMyLibraryPage({Key key}) : super(key: key);

  @override
  _BookShareMyLibraryState createState() => _BookShareMyLibraryState();
}


class _BookShareMyLibraryState extends State<BookShareMyLibraryPage> {

   var container;
   AppState appState;
   String contentView;
   // String selectedLib;   

   // Dropdown
   bool dirtyLibChunks;
   List<String> shareLibs;
   Map<String,Widget> libChunks;
   String shareLibrary;

   // shares
   bool shareAll; 
   
   @override
   void initState() {
      super.initState();
      contentView = "grid";
      // selectedLib = "";

      dirtyLibChunks = true;
      libChunks = new Map<String,Widget>();
      shareLibs = [];
      shareLibrary = "";
      shareAll = false;

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
      String numB =  appState.booksInLib[ appState.privateLibId ].length.toString();
      numB       += ( numB == "1" ? " book" : " books" );
      
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
                           Text( numB, style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic))
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

   _updateLibChunks() {
      if( dirtyLibChunks )
      {
         print( "Make libchunk" );
         libChunks.clear();
         shareLibs.clear();
         assert( appState.myLibraries.length >= 1 );
         for( final lib in appState.myLibraries ) {
            if( lib.id != appState.privateLibId ) {
               libChunks[lib.id] = makeLibraryChunk( appState, lib.name, lib.id );
               shareLibs.add( lib.id );
               print( " ... added " + lib.name + " " + shareLibs.length.toString() );
            }
         }
         dirtyLibChunks = false;
      }
   }



   // Dropdown button selects strings, then uses a map to find pre-built libchunk for display.  cool beans.
   Widget _makeDropLib() {

      if( shareLibs.length == 0 ) { return Container(); }
      if( shareLibrary == "" )  {
         shareLibrary = shareLibs[0];
      }

      return DropdownButton<String>(
         value: shareLibrary,
         itemHeight: appState.screenHeight * .16,
         elevation: 5,
         onChanged: (String newVal) 
         {
            if( !appState.ownerships.containsKey( newVal ) ) {
               appState.ownerships[newVal] = new Set<String>();
            }
            setState(() {
                  shareAll = false;
                  shareLibrary = newVal;
               });
         },
         underline:  Container( height: 0, color: Colors.white ),
         items: shareLibs
         .map<DropdownMenuItem<String>>((String value) {
               return DropdownMenuItem<String>(
                  value: value,
                  child: libChunks[value]
                  );
            })
         .toList()
         );
   }

   Widget _makeBookShare( book ) {
      final textWidth = appState.screenWidth * .7;
      assert( shareLibrary != "" && shareLibrary != appState.privateLibId );
      // print( "Making bookshare for lib " + shareLibrary + " " + book.id );
      final shares = appState.ownerships[shareLibrary];
      
      checkVal() {
         if( shares == null ) { return false; }
         return shares.contains(book.id);
      }
         
      return Row(
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: <Widget>[
            Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                  makeTitleText( book.title, textWidth, false, 1 ),
                  makeAuthorText( book.author, textWidth, false, 1 )
                  ]),
            Padding(
               padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
               child: Checkbox(
                  value: checkVal(),
                  onChanged: (bool value)
                  {
                     _updateOwnerships( book.id, shareLibrary, value, false );
                  }))
            ]);
   }

   // No border padding
   Widget _makeHDivider( width, lgap, rgap) {
      return Padding(
         padding: EdgeInsets.fromLTRB(lgap, 0, rgap, 0),
         child: Container( width: width, height: 2, color: Colors.grey[200] ));
   }
      
   
   Widget _makeBookShares() {
      if( shareLibs.length == 0 ) { return Container(); }

      final bil = appState.booksInLib[ appState.privateLibId ];
      if( bil.length == 0 ) { return Container(); }

      List<Widget> bookShares = [];
      bookShares.add( Container( height: appState.screenHeight * .03 ));

      bookShares.add( Row(
                         crossAxisAlignment: CrossAxisAlignment.center,
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: <Widget>[
                            Padding(
                               padding: EdgeInsets.fromLTRB(appState.screenWidth * .3, 0, 0, 0),
                               child: Text("", style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic))),
                            Padding(
                               padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                               child: Checkbox(
                                  value: shareAll,
                                  onChanged: (bool value)
                                  {
                                     _updateOwnerships( "", shareLibrary, value, true );
                                  }))
                            ]));
      bookShares.add( _makeHDivider( appState.screenWidth * .8, 0.0, appState.screenWidth * .1 ));
                      
      for( final book in bil ) {
         bookShares.add( _makeBookShare( book ));
         bookShares.add( _makeHDivider( appState.screenWidth * .8, 0.0, appState.screenWidth * .1 ));
      }
      
      return ConstrainedBox( 
         constraints: new BoxConstraints(
            minHeight: 20.0,
            maxHeight: appState.screenHeight * .6
            ),
         child: ListView(
            scrollDirection: Axis.vertical,
            children: bookShares
            ));
   }

   _updateOwnerships( bookId, libId, newValue, setAll ) async {
      print( "updating Share, all? " + setAll.toString() );
      // setState here would force a reload that you do not want, at least not without going to tristate.
      appState.sharesLoaded = false;

      if( setAll ) {
         if( newValue ) { appState.ownerships[libId] = new Set<String>.from( appState.ownerships[appState.privateLibId] );  }
         else           { appState.ownerships[libId].clear();   }
         await setAllShares( context, container, libId, newValue );
      } else {
         if( newValue ) { appState.ownerships[libId].add( bookId ); }
         else {           appState.ownerships[libId].remove( bookId );   }
         await setShare( context, container, bookId, libId, newValue );
      }

      // No need to wait for this one..  ensure homepage consistency
      if( appState.booksInLib.containsKey( libId ) ) { appState.booksInLib[libId].clear(); }
      initLibBooks( context, container, libId );
      
      setState(() {
            appState.sharesLoaded = true;
            shareAll = newValue && setAll;
         });
   }

   _initOwnerships() async {
      print( "loading Ownerships" );
      await initOwnerships( context, container );
      setState(() {
            appState.sharesLoaded = true;
         });
   }
   
   Widget _shareView() {
      final width = appState.screenWidth; 
      final height = appState.screenHeight * .08;
      String shareText = "Book shares for: ";
      if( libChunks.length == 0 ) { shareText = "Share books from your private library on this page, once you've joined another library."; }
      if( !appState.sharesLoaded ) {
         _initOwnerships(); 
      }
      
      return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.start,
         children: <Widget>[
            Row( 
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: <Widget>[
                  Padding(
                     padding: EdgeInsets.fromLTRB( 12, height, 0, 0),
                     child: Text( shareText , style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic))),
                  _makeDropLib(),
                  Container()
                  ]),
            _makeBookShares()
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

      container = AppStateContainer.of(context);
      appState = container.state;

      _updateLibChunks();
      
      return Scaffold(
         appBar: makeTopAppBar( context, "MyLibrary" ),
         bottomNavigationBar: makeBotAppBar( context, "MyLibrary" ),
         body: _makeBody()
         );
   }
}
