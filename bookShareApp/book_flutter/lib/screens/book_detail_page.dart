import 'package:flutter/material.dart';

import 'package:bookShare/utils.dart';
import 'package:bookShare/utils_load.dart';
import 'package:bookShare/app_state_container.dart';


class BookShareBookDetailPage extends StatefulWidget {
  BookShareBookDetailPage({Key key}) : super(key: key);

  @override
  _BookShareBookDetailState createState() => _BookShareBookDetailState();

}

class _BookShareBookDetailState extends State<BookShareBookDetailPage> {
   @override
   void initState() {
      super.initState();
   }


  @override
  void dispose() {
    super.dispose();
  }

  @override
     Widget build(BuildContext context) {
     
      final container = AppStateContainer.of(context);
      final appState = container.state;

      final imageHeight = appState.screenHeight * .8;
      final imageWidth  = imageHeight * .913;
      const inset       = 20.0;

      final book = appState.detailBook;

      var image;
      if( book.image != null && book.image != "" ) { image = Image.network( book.image, height: imageHeight, width: imageWidth, fit: BoxFit.contain ); }
      else                                         { image = Image.asset( 'images/blankBook.jpeg', height: imageHeight, width: imageWidth, fit: BoxFit.cover); }

      // do not delete books, delete ownerships and shares.  Don't add book if it exists already.
      void _deleteConfirmed() {
         String uid = appState.userId;
         String bookId = book.id;
         String postData = '{ "Endpoint": "DelBook", "BookId": "$bookId", "PersonId": "$uid" }';               
         deleteBook( context, container, postData );

         // No need to kill this.. book still exists, just not share, ownership.  If do kill, first rebuild tries reading and fails.
         // appState.detailBook = null;

         // Iterate through all libs, removing the book (leave empty libs alone)
         appState.booksInLib.forEach((k, v) {
               for( final b in v ) {
                  if( b.id == bookId ) {
                     v.remove( b );
                     break;
                  }
               }
            });

         // pop means nothing rebuilds unless forced to.  Force here passing back deleted.
         Navigator.of( context ).pop();            // dialog
         Navigator.of( context ).pop( 'deleted');  // book detail
      }

      void _deleteBook() {
         confirm( context, "Confirm delete", "Press Continue to proceed.",
                  _deleteConfirmed, () => Navigator.of( context ).pop() );
      }

      return Scaffold(
         appBar: PreferredSize(
            preferredSize: Size.fromHeight( appState.screenHeight*.001 ),
            child: AppBar( leading: Container() )),
         body: Center(
           child: SingleChildScrollView(
              key: Key( 'bookDetail' ),
              child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.start,
                 mainAxisSize: MainAxisSize.min,
                 children: <Widget>[
                    Padding(
                       padding: const EdgeInsets.fromLTRB(6.0, 12, 6.0, 0),
                       child: ClipRRect(
                          borderRadius: new BorderRadius.circular(12.0),
                          child: image )),
                    Padding(
                       padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                       child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                             Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                   Padding(
                                      padding: const EdgeInsets.fromLTRB(inset, 6, 6, 0),
                                      child: Container( width: appState.screenWidth * .55,
                                                        child: Text(book.title, softWrap: true, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))),
                                   Padding(
                                      padding: const EdgeInsets.fromLTRB(inset, 0, 6, 0),
                                      child: Container( width: appState.screenWidth * .55,
                                                        child: Text("By: " + book.author, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)))),
                                   Padding(
                                      padding: const EdgeInsets.fromLTRB(inset, 0, 6, 0),
                                      child: Container( width: appState.screenWidth * .55,
                                                               child: Text("Publisher: " + book.publisher, style: TextStyle(fontSize: 14)))),
                                   Padding(
                                      padding: const EdgeInsets.fromLTRB(inset, 0, 6, 0),
                                      child: Text("Published date: " + book.publishedDate, style: TextStyle(fontSize: 14))),
                                   Padding(
                                      padding: const EdgeInsets.fromLTRB(inset, 0, 6, 0),
                                      child: Text("Pages: " + book.pageCount, style: TextStyle(fontSize: 14))),
                                   Padding(
                                      padding: const EdgeInsets.fromLTRB(inset, 0, 6, 0),
                                      child: Text("Preferred ISBN: " + book.ISBN, style: TextStyle(fontSize: 14)))
                                   ]),
                             makeActionButtonSmall(
                                appState,
                                "Back",
                                () async { Navigator.pop(context); })
                             ])),
                    Padding(
                       padding: const EdgeInsets.fromLTRB(inset, 12, 6, 0),
                       child: Container( width: appState.screenWidth * .9,
                                         key: Key( 'Description' ),
                                         child: Text("Description: " + book.description, style: TextStyle(fontSize: 14)))),
                    Padding(
                       padding: const EdgeInsets.fromLTRB(inset, 12, 0, 0),
                       child: makeActionButtonSmall(
                          appState,
                          "Delete",
                          () async { _deleteBook(); }))
                    ]))));
   }
}

        

