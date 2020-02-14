import 'dart:convert';  // json encode/decode

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';

import 'package:bookShare/utils.dart';
import 'package:bookShare/utils_load.dart';
import 'package:bookShare/app_state_container.dart';

import 'package:bookShare/screens/home_page.dart';

import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/models/books.dart';


class BookShareAddBookPage extends StatefulWidget {
  BookShareAddBookPage({Key key}) : super(key: key);

  @override
  _BookShareAddBookState createState() => _BookShareAddBookState();
}


class _BookShareAddBookState extends State<BookShareAddBookPage> {

   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   String barcode;
   List<String> scans;
   TextEditingController titleKey;
   TextEditingController authorKey;
      
   Book  newBook;
   List<Book> foundBooks;
   int selectedNewBook;

   bool refining;

   var container;
   AppState appState;
   
  @override
  void initState() {
      super.initState();
      barcode = "";

      newBook = null;
      foundBooks = [];
      selectedNewBook = 0;

      refining  = false;
      titleKey  = new TextEditingController();
      authorKey = new TextEditingController();
      
   }


  @override
  void dispose() {
    super.dispose();
  }

  Future<void> addToLibrary() async {
     print( "Adding " + newBook.title + " to private lib" );
     showToast( context, "Adding..." );
     
     // AWS has username via cognito signin
     String libID = appState.privateLibId;
     String book = json.encode( newBook ); 
     String postData = '{ "Endpoint": "PutBook", "SelectedLib": "$libID", "NewBook": $book }';
     print( postData );
     bool success = await putBook( context, container, postData );

     if( success ) {
        List<Book> bil = appState.booksInLib[libID];
        bool addBook = true;
        // No need to initOwnership - this has happened already upon first login
        if( bil != null ) { 
           for( final book in bil ) {
              if( book.id == newBook.id ) { addBook = false; break; }
           }
        }
        if( addBook ) { appState.booksInLib[libID].add( newBook ); }
     }
  }
     
  // Different display, tap function than in homePage
  GestureDetector makeBookChunkCol( appState, book, selectedItem, itemNo ) {
     final imageHeight = appState.screenHeight * .46;
     final imageWidth  = appState.screenWidth * .42;
     const inset       = 20.0;
     
     var decoration    = BoxDecoration();
     if( selectedItem == itemNo ) {
        decoration = BoxDecoration( image: DecorationImage( image: AssetImage( 'images/check.png') ));
     }
     
     var image;
     if( book.image != null && book.image != "---" ) { image = Image.network( book.image, height: imageHeight, width: imageWidth, fit: BoxFit.contain ); }
     else                                         { image = Image.asset( 'images/blankBook.jpeg', height: imageHeight, width: imageWidth, fit: BoxFit.cover); }
     
     // Controlling author, title lengths more carefully in lib displays, but
     // here, single click means choose me, not detail view.  Choose to show somewhat more detail here.
     return GestureDetector(
        onTap:  () => setState(() {selectedNewBook = itemNo;}),
        child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           mainAxisAlignment: MainAxisAlignment.center,
           mainAxisSize: MainAxisSize.min,
           children: <Widget>[
              Padding(
                 padding: const EdgeInsets.fromLTRB(6.0, 0, 6.0, 0),
                 child: ClipRRect(
                    key: Key( 'bookChunk$itemNo' ),
                    borderRadius: new BorderRadius.circular(12.0),
                    child: image )),
              Container(
                 decoration: decoration,
                 child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                       Padding(
                          padding: const EdgeInsets.fromLTRB(inset, 6, 6, 0),
                          child: Container( width: imageWidth-inset-6,
                                            child: Text(book.title, maxLines: 3, overflow: TextOverflow.ellipsis,
                                                        softWrap: true, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))),
                       Padding(
                          padding: const EdgeInsets.fromLTRB(inset, 0, 6, 0),
                          child: Text("By: " + book.author, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic))),
                       Padding(
                          padding: const EdgeInsets.fromLTRB(inset, 0, 6, 0),
                          child: Text("ISBN: " + book.ISBN, style: TextStyle(fontSize: 12)))
                       ]))]));
  }
  
  
  Widget _makeBooks( ) {
     var bil = foundBooks;
     List<Widget> bookChunks = [];
     if( bil == null || bil.length == 0 ) { return Container(); }

     int itemNo = 0;
     for( final book in bil ) {
        bookChunks.add( makeBookChunkCol( appState, book, selectedNewBook, itemNo )); 
        itemNo++;
     }
     
     if( foundBooks.length > 0 ) {
         return Expanded(
            child: SizedBox(
               child: ListView(
                  key: Key( "searchedBooks" ),
                  scrollDirection: Axis.horizontal,
                  children: bookChunks
                  )));
     }
     else { return Container(); }
  }

  Future<void> _updateFoundBooks( barcode ) async {
     if( barcode == "keywords" ) { foundBooks = await fetchKeyword( titleKey.text, authorKey.text );  }
     else if( barcode != "" )
     {
        foundBooks = await fetchISBN( barcode );
        if( foundBooks == null || foundBooks.length == 0 ) { showToast( context, "No good results..  Try refining your search." ); }
     }
  }

  Widget _acceptGotoButton( ) {
     return makeActionButtonSmall(
        appState,
        "Add this,\n go to MyLib", 
        () async
        {
           newBook = foundBooks[selectedNewBook];
           await addToLibrary();

           selectedNewBook = 0;   
           foundBooks.clear();

           MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareHomePage());
           Navigator.pushReplacement(context, newPage );
        });
  }

  Widget _acceptStayButton() {
     return makeActionButtonSmall(
        appState,
        "Add this,\n scan more", 
        () async
        {
           newBook = foundBooks[selectedNewBook];
           await addToLibrary();
           
           selectedNewBook = 0; 
           setState(() { 
                 foundBooks.clear();  // back out of current list, to scan mode
              });
        });
  }

  // https://www.googleapis.com/books/v1/volumes?q=intitle:glorious+inauthor:shaara
  Widget _makeRefineGroup() {
     final textWidth = appState.screenWidth * .6;
     final textHeight = appState.screenWidth * .08;
     return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
        children: <Widget> [
           Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                 Container(
                    width: textWidth,
                    height: textHeight,
                    child: TextField(
                       key: Key("Keyword from title"),
                       decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                          hintText: "Keyword from title",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                       controller: titleKey
                       )),
                 SizedBox(height: 5.0),                 
                 Container(
                    width: textWidth,
                    height: textHeight,
                    child: TextField(
                       key: Key( "Author's last name" ),
                       decoration: InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(2.0, 2.0, 2.0, 2.0),
                          hintText: "Author's last name",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
                       controller: authorKey
                       ))
                 ]),
           _searchButton()
           ]);
  }
       
  Widget _refineButton() {
     return makeActionButtonSmall(
        appState,
        "Refine search",
        () async
        {
           setState(() { refining = true; });
        });
  }
  
  Widget _searchButton() {
     return makeActionButtonSmall(
        appState,
        "Search",
        () async
        {
           if( titleKey.text == "" && authorKey.text == "" ) {
              showToast( context, "Oops, forgot to enter something" );
           } else {
              String bc = "keywords";
              await _updateFoundBooks( bc );
              titleKey.clear();
              authorKey.clear();
              setState(() {
                    this.barcode = bc;
                    refining = false;
                 });
           }
        });
  }
  
  Widget _scanButton() {
     return RaisedButton(
        key: Key( 'Scan' ),
        onPressed: () async
        {

           String bc = "";
           try {
              bc = await BarcodeScanner.scan();
           } on PlatformException catch(e) {
              if( e.code == BarcodeScanner.CameraAccessDenied) {
                 showToast( context, "Camera permission not granted" );
              } else {
                 showToast( context, e.toString() );
              }
           } on FormatException {
              showToast( context, "oops - user returned using back button before scanning" );
           } catch( error ) {
              showToast( context, error.toString() );
           }
           
           await _updateFoundBooks( bc );
           setState(() => this.barcode = bc );
        },
        child: Text( 'Scan'));
  }

  Widget _makeActionButtons( gotStuff ) {
     final width = appState.screenWidth;
     if( refining ) {
        return _makeRefineGroup();
     } else if( gotStuff ) {
        return Row(
           crossAxisAlignment: CrossAxisAlignment.center,
           mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
           children: <Widget>[
              _acceptGotoButton(),
              _acceptStayButton(),
              _refineButton()
              ]);
     }
     else {
        return paddedLTRB( _refineButton(), width*.6, 0, 0, 0);
     }
  }
  
  Widget _makeBody() {
     final height = appState.screenHeight;

     final topGap = height * .06;
     final botGap = height * .04;
     if( foundBooks == null || foundBooks.length == 0 ) {  // scan
        return SingleChildScrollView(
           child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                 SizedBox(height: height*.25),
                 Text( "ISBN search", style: TextStyle(fontWeight: FontWeight.bold)),
                 SizedBox(height: 5.0),
                 Center( child: _scanButton() ),
                 SizedBox(height: height * .35 ),
                 _makeActionButtons( false )
                 ]));
     } else {                       // pick
        return  SingleChildScrollView(
           child: Container(
              height: appState.screenHeight * .85,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,    // required for listView child
              children: <Widget>[
                 SizedBox(height: topGap),
                 Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                    child: Text("Select your book below..", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                 //SizedBox(height: botGap * .5),
                 _makeBooks(),
                 _makeActionButtons( true ),
                 SizedBox(height: botGap*.3),
                 ])
              ));
     }
  }
      
  
   @override
   Widget build(BuildContext context) {

      container = AppStateContainer.of(context);
      appState = container.state;

      // print( "Build addBook, scaffold." );
      return Scaffold(
            appBar: makeTopAppBar( context, "AddBook" ),
            bottomNavigationBar: makeBotAppBar( context, "AddBook" ),
            body: _makeBody()
            );
   }
}
