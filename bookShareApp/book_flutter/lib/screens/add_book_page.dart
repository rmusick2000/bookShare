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
   int myRouteNum;
   List<String> scans;
   TextEditingController target;
   Book  newBook;
   List<Book> foundBooks;

  @override
      void initState() {
      super.initState();
      myRouteNum = -1;
      barcode = "";
      newBook = null;
      foundBooks = [];

      target = new TextEditingController();
      target.text = "0";
      //        kush(x),            daughters,        the eight,       prestige,        neverwhere
      var s1 = ["9780446610025", "9787219045213", "9780345419088", "9780312858865", "9780060557812"];
      //        inferno,         kiterunner,      awakening (X)    glorious cause(x)
      var s2 = ["9780804172264", "9781594631931", "9780312987022", "9780345427571"];
      scans = [...s1, ...s2];
   }


  @override
  void dispose() {
    super.dispose();
  }


  // XXX tell user primary vs secondary isbn
  // XXX allow selection + crop of cover art?
  Widget makeBooks( appState ) {
     print( "MAKE BOOK START" );

     List<Widget> bookChunks = [];

     // XXX temp
     if( newBook != null ) { foundBooks.add( newBook ); }
     var bil = foundBooks;
     
     if( bil == null || bil.length == 0 ) { return Container(); }

     bil.forEach((book) => bookChunks.add( makeBookChunkCol( appState, book )));
     
     if( newBook != null ) {
         return Expanded(
            child: SizedBox(
               child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: bookChunks
                  )));
     }
     else { return Container(); }
  }

  void updateNewBook( barcode ) async {
     print( "UPDATE NEW BOOK START" );
     if( barcode != "" ) { newBook = await fetchISBN( barcode );  }
     print( "UPDATE NEW BOOK END" );
  }
  
  
   @override
   Widget build(BuildContext context) {

      final container = AppStateContainer.of(context);
      final appState = container.state;
      
      if( !isCurrentRoute( appState, "add", myRouteNum )) {
         return Container();
      }
      print( "Building AddBook " + myRouteNum.toString() );
      myRouteNum = getRouteNum( appState ); 
      
      final targetField = Container(
         width: 50,
         child: TextField(
         decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: target.text,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
         controller: target
            ));
      

      
      final scanButton = RaisedButton(
         onPressed: () async
         {
            print( "SCAN BUTTON PRESS" );
            print( "Scans: " + scans.toString() );
            print( "Target: " + target.text );
            String bc = scans[int.parse( target.text )];
            int newTarget = ( int.parse( target.text ) + 1 ) % scans.length;
            await updateNewBook( bc );
            setState(() {
                  this.barcode = bc;
                  this.target.text = newTarget.toString();
               });

         },

        // Need to put this on the phone.
         /*
        onPressed: () async
        {
           try{
              String bc = await BarcodeScanner.scan();
              setState(() { this.barcode = bc; });
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
        },
         */
        child: Text( 'Scan'));
                        
      
      return WillPopScope(
         onWillPop: () => requestPop(context),
         child: Scaffold(
            appBar: makeTopAppBar( context, "AddBook" ),
            bottomNavigationBar: makeBotAppBar( context, "AddBook" ),
            body: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.center,
               mainAxisSize: MainAxisSize.min,    // required for listView child
               children: <Widget>[
                  SizedBox(height: 5.0),
                  Text( "Add Book", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5.0),
                  Row(
                     crossAxisAlignment: CrossAxisAlignment.center,
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: <Widget>[
                        scanButton,
                        targetField
                     ]),
                  SizedBox(height: 5.0),
                  makeBooks( appState )
                  ])));
         

   }
}
