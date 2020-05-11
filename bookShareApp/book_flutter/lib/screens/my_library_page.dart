import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

import 'package:bookShare/screens/home_page.dart';
import 'package:bookShare/screens/book_detail_page.dart';
import 'package:bookShare/screens/image_page.dart';

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

   // Dropdown
   bool dirtyLibChunks;
   List<String> shareLibs;
   Map<String,Widget> libChunks;
   String shareLibrary;              // selected lib for assigning book shares

   String  editLibId;                // selected lib ID that is under edit or being created
   Library editLibrary;              // the selected lib
   bool    updateProspect;           // time to create a new prospect
   bool    prospectActive;           // active prospect on the library row bar
   bool    newCropImage;             // image was selected, but lib edits not yet saved.  force update to createlib row
   
   // shares
   bool shareAll; 

   TextEditingController nameController;  // edit state.  don't want these overwritten on return from chooseImage
   TextEditingController descController;
   Image                 origImage;       // orig state.
   
   @override
   void initState() {
      super.initState();
      contentView = "grid";

      dirtyLibChunks = true;
      libChunks = new Map<String,Widget>();
      shareLibs = [];
      shareLibrary = "";
      editLibId = "";
      editLibrary = null;
      updateProspect = false;
      prospectActive = false;
      newCropImage = false;
      shareAll = false;

      nameController = new TextEditingController();   
      descController = new TextEditingController();
      nameController.text = "";
      descController.text = "";
      origImage = null;
   }
   
   
   @override
   void dispose() {
      super.dispose();
   }

   // IconButton theme likes 48 pixel spread, which is huge.  use GD instead.
   Widget _makeContextMenu( context ) {

      // if this page is on the stack when log out, myLibraries may be null here
      if( appState.myLibraries == null ) { return Container(); }
      
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
                        key: Key( 'editIcon' ),
                        onTap:  ()
                        {
                           print( "SETSTATE makeContextMenu icon" );
                           setState(() { contentView = "create"; });
                        },
                        child: Icon( Icons.fiber_new )
                        )),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                     child: GestureDetector( 
                        key: Key( 'shareIcon' ),
                        onTap:  ()
                        {
                           print( "SETSTATE makeContextMenu icon" );
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
                              key: Key( 'gridIcon' ),
                              onTap:  ()
                              {
                                 print( "SETSTATE makeContextMenu icon" );
                                 setState(() { contentView = "grid"; });
                              },
                              child: Icon( Icons.apps )
                              )),
                        Padding(
                           padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                           child: GestureDetector( 
                              key: Key( 'listIcon' ),
                              onTap:  ()
                              {
                                 print( "SETSTATE makeContextMenu icon" );
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
                                 print( "SETSTATE makeContextMenu icon" );
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
        key: Key( 'image: ' + book.title ),
        onTap:  ()
        {
           print( "SETSTATE makeBookChunk tap" );
           setState(() { appState.detailBook = book; });
           Navigator.push( context, MaterialPageRoute(builder: (context) => BookShareBookDetailPage()));
        },
        child: ClipRRect( borderRadius: new BorderRadius.circular(12.0), child: image )
        );
  }

   // gridview controls object sizing
   Widget _gridView( bookChunks ) {
      return GridView.count(
         key: Key( 'gridView' ),
         primary: false,
         scrollDirection: Axis.vertical,
         padding: const EdgeInsets.all(0),
         crossAxisSpacing: 0,
         mainAxisSpacing: 12,
         crossAxisCount: 3,
         children: bookChunks
         );
   }

   Widget _listView( bil ) {
      List<Widget> bookList = [];
      // bookList.add( Container( height: appState.screenHeight * .03 ));
      for( final book in bil ) {
         bookList.add( _makeBookList( book ));
         bookList.add( _makeHDivider( appState.screenWidth * .8, 0.0, appState.screenWidth * .1 ));
      }

      return ConstrainedBox( 
         constraints: new BoxConstraints(
            minHeight: 20.0,
            maxHeight: appState.screenHeight * .9
            ),
         child: ListView(
            scrollDirection: Axis.vertical,
            children: bookList
            ));
   }


   // XXX Why repeat view in homepage?  Probably unneeded, wasteful.  Consider removing from UI
   Widget _fullView( bookChunks ) {
      return Container(); 
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
               libChunks[lib.id] = makeLibraryChunk( lib, appState.screenHeight, false );
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

      return Theme(
         data: Theme.of(context).copyWith( canvasColor: Colors.grey[200] ),
         child: DropdownButton<String>(
            key: Key( 'dropLib' ),
            value: shareLibrary,
            itemHeight: appState.screenHeight * .16,
            elevation: 5,
            onChanged: (String newVal) 
            {
               if( !appState.ownerships.containsKey( newVal ) ) {
                  appState.ownerships[newVal] = new Set<String>();
               }
               setState(() {
                     print( "SETSTATE makeDroplib change" );
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
            ));
   }

   Widget _makeBookList( book ) {
      final textWidth = appState.screenWidth * .7;
      final imageHeight = appState.screenHeight * .06;
      final imageWidth  = imageHeight;
      
     var image;
     if( book.image != "---" ) { image = Image.network( book.image, height: imageHeight, width: imageWidth, fit: BoxFit.contain ); }
     else                      { image = Image.asset( 'images/blankBook.jpeg', height: imageHeight, width: imageWidth, fit: BoxFit.contain); }
     
     return GestureDetector(
        onTap:  ()
        {
           print( "SETSTATE makeBookList tap" );
           setState(() { appState.detailBook = book; });
           Navigator.push( context, MaterialPageRoute(builder: (context) => BookShareBookDetailPage()));
        },
        child: Row(
           crossAxisAlignment: CrossAxisAlignment.center,
           mainAxisAlignment: MainAxisAlignment.spaceAround,
           children: <Widget>[
              ClipRRect( key: Key('image: ' + book.title ), borderRadius: new BorderRadius.circular(12.0), child: image ),
              Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: <Widget>[
                    makeTitleText( book.title, textWidth, false, 1 ),
                    makeAuthorText( book.author, textWidth, false, 1 )
                    ])
              ])
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
                  key: Key( 'check: ' + book.title ),
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
                                  key: Key( 'check: shareAll' ),
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
            key: Key( 'bookShares' ),
            scrollDirection: Axis.vertical,
            children: bookShares
            ));
   }

   Future<void> _updateOwnerships( bookId, libId, newValue, setAll ) async {
      print( "updating Share, all? " + setAll.toString() );
      // setState here would force a reload that you do not want, at least not without going to tristate.
      appState.sharesLoaded = false;

      // Might have just joined
      if( !appState.ownerships.containsKey( libId ) ) {
         print( "Updating shares to add entry for " + libId );
         appState.ownerships[libId] = new Set<String>(); 
      }
      
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
      
      print( "SETSTATE updateOwnership share" );
      setState(() {
            appState.sharesLoaded = true;
            shareAll = newValue && setAll;
         });
   }

   Future<void> _initOwnerships() async {
      print( "loading Ownerships" );
      await initOwnerships( context, container );
      print( "SETSTATE initOwnership init" );
      setState(() {
            appState.sharesLoaded = true;
         });
   }
   
   Widget _shareView() {
      final width = appState.screenWidth; 
      final height = appState.screenHeight * .08;
      String shareText = "Book shares for: ";
      if( libChunks.length == 0 ) { shareText = "Share books from your private library on this page, once you've created or joined another library."; }
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
                     child: Container( width: width * .6,
                                       child: Text( shareText, softWrap: true, style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic)))),
                  _makeDropLib(),
                  Container()
                  ]),
            _makeBookShares()
            ]);
   }

   void _setNewEditLib( lib ) {
      editLibrary = lib;
      if( editLibrary != null ) {
         // print( editLibrary.toString() );
         if( editLibrary.description == null || editLibrary.description == "---EMPTY---" ) { editLibrary.description = ""; }
         nameController.text = editLibrary.name;
         descController.text = editLibrary.description;
         origImage = editLibrary.image;
      }
   }

   // XXX Consider confirming choice of new lib if editLib != null, otherwise if editing one, then choose another, edits are lost
   void _editLibrary( libraryId, lib ) {
      if( lib == null ) {
         if( prospectActive ) { showToast( context, "Just one new lib at a time." ); }
         else {
            print( "SETSTATE editLib updateProspect" );
            setState(() => updateProspect = true );
         }
      } else {
         prospectActive = false;
         _setNewEditLib( lib );
         print( "SETSTATE editLIb editLibId" );
         setState(() => editLibId = libraryId );
      }
   }
      
   Widget _makeLibraryChunk( lib ) {
      bool highlight = ( lib.id == editLibId );
      return GestureDetector(
         onTap: () { _editLibrary( lib.id, lib ); },
         child: makeLibraryChunk( lib, appState.screenHeight, highlight ) 
         );
   }

   Widget _makeProspect() {
      bool highlight = true;

      editLibId = randomAlpha(10);
      List<String> meme = new List<String>();
      meme.add( appState.userId );
      editLibrary = new Library( id: editLibId, name: "new", private: false, members: meme, imagePng: null, image: null, prospect: true );
      updateProspect = false;
      prospectActive = true;
      _setNewEditLib( editLibrary );
      return GestureDetector(
         onTap: () { _editLibrary( editLibId, editLibrary); },
         child: makeLibraryChunk( editLibrary, appState.screenHeight, highlight ) 
         );
   }
   
   Widget _makeNewLib() {
      final imageSize = appState.screenHeight * .1014;
      return GestureDetector(
         onTap: () { _editLibrary( "new", null ); },
         child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
               Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0, 0.0),
                  child: Icon( Icons.fullscreen, size: imageSize, color: Colors.pinkAccent )),
               Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 4.0, 0, 0.0),
                  child: Text("< CREATE >", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)))
               ])
         );
   }
      
   // Don't need to update elsewhere - this page must be on the stack to edit, and edits here mod other pages via appState
   Widget _makeLibraryRow() {
      List<Widget> libChunksCreateRow = [];
      if( appState.myLibraries == null ) { return Container(); }  // null during update

      if( appState.updateLibs || libChunksCreateRow.length == 0 ) {
         print( "myLib updating libs" );
         libChunksCreateRow.add( _makeNewLib() );
         if( updateProspect ) { libChunksCreateRow.add( _makeProspect() ); }
         else if( editLibrary != null && editLibrary.prospect ) { libChunksCreateRow.add( _makeLibraryChunk( editLibrary )); }
         assert( appState.myLibraries.length >= 1 );
         appState.myLibraries.forEach((lib) => libChunksCreateRow.add( _makeLibraryChunk( lib )));
         appState.updateLibs = false;
         newCropImage = false;
      }
      
      return ConstrainedBox( 
         constraints: new BoxConstraints(
            minHeight: 20.0,
            maxHeight: appState.screenHeight * .167
            ),
         child: ListView(
            scrollDirection: Axis.horizontal,
            children: libChunksCreateRow
            ));
   }

   Widget _makePixButton( ) {
      return makeActionButtonSmall(
            appState,
            "Choose Image", 
            ()
            {
               Navigator.push( context, MaterialPageRoute(
                                  builder: (context) => BookShareImagePage(),
                                  settings: RouteSettings( arguments: editLibrary )))
                  .then((value) {
                        if( value == 'accepted' ) { setState(() => newCropImage = true ); }
                     });
            });
   }


   Widget _makeSmallInputField( txt, controller ) {
      return TextField(
         key: Key( 'input: ' + txt ),
         obscureText: false,
         style: TextStyle(fontSize: 18),
         maxLines: 1,
         maxLength: 11,
         autofocus: false,
         decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(8,8,8,8),
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            hintText: txt ),
         controller: controller
         );
   }

   Widget _makeLargeInputField( txt, controller ) {
      return TextField(
         obscureText: false,
         style: TextStyle(fontSize: 18),
         autofocus: false,
         maxLines: 3,
         decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(8,8,8,8),
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
            hintText: txt ),
         controller: controller
         );
   }

   void _rejectEdit() {
      if( editLibrary.prospect ) {
         prospectActive = false;
         editLibrary = null;
         editLibId = "";
         updateProspect = false;
         print( "SETSTATE reject updateLibs" );
         setState(() => appState.updateLibs = true );   // force rebuild of lib row bar, without prospect
      } else if( editLibId != "" ) {
         // Go back to current selected lib
         nameController.text = editLibrary.name;
         descController.text = editLibrary.description;
         editLibrary.image = origImage;   // reversed, since tmp state is stored in the lib!
         setState(() => appState.updateLibs = true );   // force rebuild of lib row bar, with orig image
      } else {
         // probably can't get here
         nameController.clear();
         descController.clear();
         origImage = null;
      }
   }

   Widget _makeEditLibBody() {
      final width = appState.screenWidth;
      final height = appState.screenHeight;

      // NOTE this does not remove in-app ownership state, but it's invisible, harmless, and temporary til next load
      void _deleteConfirmed() {
         if( editLibrary.prospect ) { _rejectEdit(); }
         else if( editLibrary.members.length > 1 ) { notYetImplemented( context ); } 
         else if( editLibId == appState.privateLibId) { showToast( context, "Your private library can not be deleted." ); }
         else {
            String libId = editLibId;
            String uid = appState.userId;
            String postData = '{ "Endpoint": "DelLib", "LibId": "$libId", "PersonId": "$uid" }';               
            deleteLib( context, container, postData );
            
            appState.myLibraries.remove( editLibrary );
            editLibrary = null;
            editLibId = "";
            
            setState(() {
                  appState.updateLibs = true;  // force rebuild of lib row bar, removing deleted
                  dirtyLibChunks = true;       // update sharing droplib
               });
         }
         Navigator.of( context ).pop(); 
      }
      
      void _deleteLib() {
         confirm( context, "Confirm delete", "This action can not be undone.  Press Continue to proceed.",
                  _deleteConfirmed, () => Navigator.of( context ).pop() );
      }

      void _acceptEdit() {
         // dynamo policy.. grrr
         editLibrary.name        = nameController.text;
         editLibrary.description = descController.text;
         if( editLibrary.description == "" ) { editLibrary.description = "---EMPTY---"; }

         // thanks geppetto
         if( editLibrary.prospect ) {      
            editLibrary.prospect = false;
            prospectActive = false;
            appState.myLibraries.add( editLibrary );
         }
         
         String newLib = json.encode( editLibrary );
         String postData = '{ "Endpoint": "PutLib", "NewLib": "$newLib" }';               
         putLib( context, container, postData );

         if( editLibrary.description == "---EMPTY---" ) { editLibrary.description = ""; }
         print( "SETSTATE makeeditLibBody updateLibs" );
         setState(() {
               appState.updateLibs = true;  // force rebuild of lib row bar, showing new stuff
               dirtyLibChunks = true;       // update sharing droplib
            });

         // Not the best choice. Feels wrong to return to, say, addBook from here. 
         // Navigator.pop(context);

         // Prefer homepage.  another option would be myLib page, gridview.
         Navigator.push( context, MaterialPageRoute(builder: (context) => BookShareHomePage()));
      }

                        
      if( editLibId == "" ) {
         return Padding(
            padding: EdgeInsets.fromLTRB( width * .1, height * .05, 0, 0.0),
            child: Text("Select a Library to edit...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)));
      }
      else {
         return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
               Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                     Padding(
                        padding: EdgeInsets.fromLTRB( 0, 0.0, width * .05, 0.0),
                        child: Text( "Editing " + editLibrary.name + " Library" , style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold ))),
                     ]),
               _makeHDivider( appState.screenWidth * .7, appState.screenWidth * .15, appState.screenWidth * .15 ),
               Container( height: height * .05 ),

               Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                     Padding(
                        padding: EdgeInsets.fromLTRB( width * .05, 0, width * .025, 0.0),
                        child: Text( "Library name: ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                     Padding(
                        padding: EdgeInsets.fromLTRB( 0,0,0, 0.0),
                        child: SizedBox( width: width * .32, height: height * .05, child: _makeSmallInputField( editLibrary.name, nameController ))),
                     ]),
               Container( height: height * .03 ),

               Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                     Padding(
                        padding: EdgeInsets.fromLTRB( width * .05, height * .01, width * .07, height * .03),
                        child: Text( "Description:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                     SizedBox( width: width * .65, height: height * .13, child: _makeLargeInputField( editLibrary.description, descController )),
                     ]),

               Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                     paddedLTRB( _makePixButton(), width * .1, height * .03, width * .04, height * .03)
                     ]),
               Container( height: appState.screenHeight * .03 ),
               Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                     paddedLTRB( makeActionButtonSmall( appState, "Accept", () async { _acceptEdit(); }), 0,0,width * .02,0 ),
                     paddedLTRB( makeActionButtonSmall( appState, "Delete", () async { _deleteLib(); }),  0,0,width * .02,0 ),
                     paddedLTRB( makeActionButtonSmall( appState, "Cancel", () async { _rejectEdit(); }), 0,0,width * .04,0 )
                     ])
               ]);
            }
   }
   
   Widget _createView() {
      return Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.start,
         children: <Widget>[
            _makeLibraryRow(),
            Divider( color: Colors.grey[200], thickness: 3.0 ),
            _makeEditLibBody(),
            ]);
   }

   
   Widget _makeContent() {
      List<Widget> bookChunks = [];
      List<Book> bil = []; 
      
      print( contentView );
      
      if( contentView == "grid" || contentView == "list" || contentView == "full" )
      {
         if( appState.booksInLib == null ) { return Container(); }
         bil = appState.booksInLib[appState.privateLibId];
         if( bil == null ) { return Container(); }

         bil.forEach((book) => bookChunks.add( _makeBookChunkSmall( book )));
      }
         
      Widget content;
      if( contentView == "grid" )       { content = _gridView( bookChunks ); }
      else if( contentView == "list" )  { content = _listView( bil ); }
      else if( contentView == "full" )  { content = _fullView( bookChunks ); }
      else if( contentView == "create") { content = _createView(); }
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
      
      // print( "Build myLib, scaffold." );
      return Scaffold(
         appBar: makeTopAppBar( context, "MyLibrary" ),
         bottomNavigationBar: makeBotAppBar( context, "MyLibrary" ),
         body: SingleChildScrollView(
            child: GestureDetector(
               onTap: () { FocusScope.of(context).requestFocus(new FocusNode()); },  // keyboard mgmt
               child: _makeBody() ))
         );
   }
}
