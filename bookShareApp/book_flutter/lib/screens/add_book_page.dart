import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:http/http.dart' as http;

import 'package:bookShare/utils.dart';
import 'package:bookShare/utils_load.dart';
import 'package:bookShare/app_state_container.dart';

import 'package:bookShare/screens/home_page.dart';

import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/models/books.dart';
import 'package:bookShare/models/libraries.dart';


class BookShareAddBookPage extends StatefulWidget {
  BookShareAddBookPage({Key key}) : super(key: key);

  @override
  _BookShareAddBookState createState() => _BookShareAddBookState();
}


class _BookShareAddBookState extends State<BookShareAddBookPage> {

   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   String barcode;
   List<String> scans;
   TextEditingController target;
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
      
      target = new TextEditingController();
      target.text = "0";
      //        glorious cause(x) kush(x),            daughters,        the eight,       prestige,        neverwhere
      var s1 = ["9780345427571", "9780446610025", "9787219045213", "9780345419088", "9780312858865", "9780060557812"];
      //        inferno,         kiterunner,      awakening (X)    
      var s2 = ["9780804172264", "9781594631931", "9780312987022"];
      scans = [...s1, ...s2];
   }


  @override
  void dispose() {
    super.dispose();
  }


  void addToLibrary() async {
     print( "Adding " + newBook.toString() + " to private lib" );
     showToast( context, "Adding..." );
     
     // AWS has username via cognito signin
     String libID = appState.privateLibId;
     String book = json.encode( newBook ); 
     String postData = '{ "Endpoint": "PutBook", "SelectedLib": "$libID", "NewBook": $book }';
     print( postData );
     await putBook( context, container, postData );
  }
     
  
  // XXX Moved out of utils to allow proper context for itemNo.  If move to colView, will need to sort this out.
  // Title will wrap if need be, growing row height as needed
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
                                            child: Text(book.title, softWrap: true, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))),
                       Padding(
                          padding: const EdgeInsets.fromLTRB(inset, 0, 6, 0),
                          child: Text("By: " + book.author, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic))),
                       Padding(
                          padding: const EdgeInsets.fromLTRB(inset, 0, 6, 0),
                          child: Text("ISBN: " + book.ISBN, style: TextStyle(fontSize: 12)))
                       ]))]));
  }
  
  
  void makeHomeDirty( appState ) {
     setState(() { 
           appState.booksLoaded = false;
           appState.selectedLibrary = "";
        });
  }

  
  // XXX tell user primary vs secondary isbn
  // XXX allow selection + crop of cover art?
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
                  scrollDirection: Axis.horizontal,
                  children: bookChunks
                  )));
     }
     else { return Container(); }
  }

  void _updateFoundBooks( barcode ) async {
     if( barcode == "keywords" ) { foundBooks = await fetchKeyword( titleKey.text, authorKey.text );  }
     else if( barcode != "" )    { foundBooks = await fetchISBN( barcode );  }
  }
  
  Widget _targetField() {
     return Container(
     width: 50,
     child: TextField(
        decoration: InputDecoration(
           contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
           hintText: target.text,
           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
        controller: target
        ));
  }

  // XXX go to MyPriv, not make home-page dirty
  Widget _acceptGotoButton( ) {
     return makeActionButtonSmall(
        appState,
        "Add this,\n go to MyLib", 
        () async
        {
           newBook = foundBooks[selectedNewBook];
           await addToLibrary();
           makeHomeDirty( appState );
           
           setState(() { 
                 selectedNewBook = 0;
                 foundBooks.clear();
              });
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
           makeHomeDirty( appState );
           
           setState(() { 
                 selectedNewBook = 0;
                 foundBooks.clear();
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
        onPressed: () async
        {
           final EMULATOR = true;   // XXX 
           String bc = "";
           int newTarget = -1;
           
           if( EMULATOR ) { 
              bc = scans[int.parse( target.text )];
              newTarget = ( int.parse( target.text ) + 1 ) % scans.length;
           }
           else {
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
              } catch( error, trace ) {
                 showToast( context, error.toString() );
              }
           }
           
           await _updateFoundBooks( bc );
           setState(() {
                 this.barcode = bc;
                 this.target.text = newTarget.toString();
              });
        },
        child: Text( 'Scan'));
  }

  Widget _makeActionButtons() {
     if( refining ) {
        return _makeRefineGroup();
     } else {
        return Row(
           crossAxisAlignment: CrossAxisAlignment.center,
           mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
           children: <Widget>[
              _acceptGotoButton(),
              _acceptStayButton(),
              _refineButton()
              ]);
     }
  }
  
  Widget _makeBody() {
     final topGap = appState.screenHeight * .06;
     final botGap = appState.screenHeight * .04;
     if( foundBooks == null || foundBooks.length == 0 ) {  // scan
        return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
               SizedBox(height: 5.0),
               Text( "ISBN search", style: TextStyle(fontWeight: FontWeight.bold)),
               SizedBox(height: 5.0),
               Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                     _scanButton(),
                     _targetField()
                     ])
               ]);
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
                 _makeActionButtons(),
                 SizedBox(height: botGap*.3),
                 ])
              ));
     }
  }
      
  
   @override
   Widget build(BuildContext context) {

      container = AppStateContainer.of(context);
      appState = container.state;

      return Scaffold(
            appBar: makeTopAppBar( context, "AddBook" ),
            bottomNavigationBar: makeBotAppBar( context, "AddBook" ),
            body: _makeBody()
            );
   }
}
