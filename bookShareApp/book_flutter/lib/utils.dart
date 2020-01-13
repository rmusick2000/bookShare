import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/screens/my_library_page.dart';
import 'package:bookShare/screens/loan_page.dart';
import 'package:bookShare/screens/search_page.dart';
import 'package:bookShare/screens/home_page.dart';
import 'package:bookShare/screens/add_book_page.dart';
import 'package:bookShare/screens/profile_page.dart';

import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/models/libraries.dart';
import 'package:bookShare/models/books.dart';



int testIncrement( val ) {
   return val + 1;
}

void notYetImplemented(BuildContext context) {
   Fluttertoast.showToast(
      msg: "Future feature",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.pinkAccent,
      textColor: Colors.white,
      fontSize: 14.0
      );
}

void showToast(BuildContext context, msg) {
   Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.pinkAccent,
      textColor: Colors.white,
      fontSize: 18.0
      );
}

void confirm( BuildContext context, confirmHeader, confirmBody, okFunc, cancelFunc ) {
   showDialog(
      context: context,
      builder: (BuildContext context) {
                 return AlertDialog(
                    title: new Text( confirmHeader ),
                    content: new Text( confirmBody ),
                    actions: <Widget>[
                       new FlatButton(
                          child: new Text("Continue"),
                          onPressed: okFunc ),
                       new FlatButton(
                          child: new Text("Cancel"),
                          onPressed: cancelFunc )
                       ]);
              });
}

paddedLTRB( child, double L, double T, double R, double B ) {
   return Padding(
      padding: EdgeInsets.fromLTRB(L,T,R,B),
      child: child );
}

makeActionButton( BuildContext context, buttonText, fn ) {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
   final container   = AppStateContainer.of(context);
   final appState    = container.state;
   return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
         key: Key( buttonText ),
         minWidth: appState.screenWidth - 30,
         padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
         onPressed: fn,
         child: Text( buttonText,
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                         color: Colors.white, fontWeight: FontWeight.bold)),
         )
      );
}

// XXX kill context above
makeActionButtonSmall( appState, buttonText, fn ) {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 12.0);
   return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
         minWidth: appState.screenWidth * .25,
         onPressed: fn,
         child: Text( buttonText,
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                         color: Colors.white, fontWeight: FontWeight.bold)),
         )
      );
}


makeTitleText( title, width, wrap, lines ) {
   return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 6, 0),
      child: Container( width: width, 
                        child: Text(title, softWrap: wrap, maxLines: lines, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))));
}

makeAuthorText( author, width, wrap, lines ) {
   return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 6, 0),
      child: Container( width: width,
                        child: Text("By: " + author, softWrap: wrap, maxLines: lines, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic))));
}
      
makeInputField( BuildContext context, hintText, obscure, controller ) {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   return TextField(
      key: Key( hintText ),
      obscureText: obscure,
      style: style,
      decoration: InputDecoration(
         contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
         hintText: hintText,
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
      controller: controller
      );
}


makeTopAppBar( BuildContext context, currentPage ) {
   final container   = AppStateContainer.of(context);
   final appState    = container.state;
   final iconSize    = appState.screenHeight*.0422;
   return PreferredSize(
      preferredSize: Size.fromHeight( appState.screenHeight*.054 ),
      child: AppBar(
         leading: IconButton(
            icon: currentPage == "MyLibrary" ? Icon(customIcons.book_shelf_here) : Icon(customIcons.book_shelf),
            key: currentPage == "MyLibrary"  ? Key( "myLibraryHereIcon" ) : Key( "myLibraryIcon" ),
            onPressed: ()
            {
               if( currentPage == "MyLibrary" ) { return; }
               MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareMyLibraryPage());
               Navigator.push( context, newPage );
            },
            iconSize: iconSize,
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
            ),
         title: Text( "BookShare", style: new TextStyle( fontFamily: 'Mansalva', fontSize: 16 )),
         actions: <Widget>[
            IconButton(
               icon: currentPage == "Loan" ? Icon(customIcons.loan_here) : Icon(customIcons.loan),
               key:  currentPage == "Loan" ? Key( "loanHereIcon" ) : Key( "loanIcon" ),
               onPressed: ()
               {
                  if( currentPage == "Loan" ) { return; }
                  MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareLoanPage());
                  Navigator.push( context, newPage);
               },
               iconSize: iconSize,
               ),
            IconButton(
               icon: currentPage == "Search" ? Icon(customIcons.search_here) : Icon(customIcons.search),
               key:  currentPage == "Search" ? Key( "searchHereIcon" ) : Key( "searchIcon" ),
               onPressed: ()
               {
                  if( currentPage == "Search" ) { return; }
                  MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareSearchPage());
                  Navigator.push( context, newPage );
               },
               iconSize: iconSize,
               padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 1.0)
               ),
            ]));
}

makeBotAppBar( BuildContext context, currentPage ) {
   final container   = AppStateContainer.of(context);
   final appState    = container.state;
   final iconSize    = appState.screenHeight*.0422;
   return SizedBox(
      height: appState.screenHeight*.054, 
      child: BottomAppBar(
         child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
               IconButton(
                  icon: currentPage == "Home" ? Icon(customIcons.home_here) : Icon(customIcons.home),
                  key:  currentPage == "Home" ? Key( "homeHereIcon" ) : Key( "homeIcon" ),
                  onPressed: ()
                  {
                     if( currentPage == "Home" ) { return; }
                     appState.selectedLibrary = appState.privateLibId;
                     MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareHomePage());
                     Navigator.push( context, newPage );
                  },
                  iconSize: iconSize,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
                  ),
               Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                     IconButton(
                        icon: currentPage == "AddBook" ? Icon(customIcons.add_book_here) : Icon(customIcons.add_book),
                        key:  currentPage == "AddBook" ? Key( "addBookHereIcon" ) : Key( "addBookIcon" ),
                        onPressed: ()
                        {
                           if( currentPage == "AddBook" ) { return; }
                           MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareAddBookPage());
                           Navigator.push( context, newPage );
                        },
                        iconSize: iconSize,
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
                        ),
                     IconButton(
                        icon: currentPage == "Profile" ? Icon(customIcons.profile_here) : Icon(customIcons.profile),
                        key:  currentPage == "Profile" ?  Key( "profileHereIcon" ) : Key( "profileIcon" ),
                        onPressed: ()
                        {
                           if( currentPage == "Profile" ) { return; }
                           MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareProfilePage());
                           Navigator.push( context, newPage );
                        },
                        iconSize: iconSize,
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
                        )
                     ])
               ])));
}


Widget makeLibraryChunk( lib, screenHeight, highlight ) {
   final imageSize   = screenHeight * .1014;
   //final imageSize   = screenHeight * .08;
   final libraryName = lib.name;
   final libraryId   = lib.id;

   var image = lib.image;
   if( image == null ) { image = Image.asset( 'images/kiteLibrary.jpg', height: imageSize, width: imageSize, fit: BoxFit.fill); }

   Text nameTxt = Text(libraryName, style: TextStyle(fontSize: 12));

   //  Nicer.  Actual underline has 0 gap between text and underline.
   Widget underline = Container();
   if( highlight ) {
      underline = Padding( 
         padding: const EdgeInsets.fromLTRB(12.0, 1.0, 0, 0.0),
         child: Container( height: 5.0, width: imageSize, color: Colors.pinkAccent ));
   }
   
   return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
         Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0, 0.0),
            child: ClipRRect(
               borderRadius: new BorderRadius.circular(12.0),
               child: image )),
         Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 4.0, 0, 0.0),
            child: nameTxt),
         underline
         ]);
}

// Future<dynamic>   hmmmmm... maybe either write, or save to libchunk here, don't pass back.
makePngBytes( appState, picture, width, height ) async {
   final img      = await picture.toImage( width, height );
   final pngBytes = await img.toByteData(format: ImageByteFormat.png);
   appState.currentPng = pngBytes.buffer.asUint8List();
   return pngBytes;
}

Library getPrivateLib( appState ) {
   Library result = null;
   if( appState.myLibraries == null || appState.myLibraries.length < 1 ) { return result; }
   for( final lib in appState.myLibraries ) {
      if( lib.private ) { result = lib; break; }
   }
   return result;
}

// XXX home_page state.  namespace issues..
Library getMemberLib( appState ) {
   Library result = null;
   if( appState.myLibraries == null || appState.myLibraries.length < 1 ) { return result; }

   String currentLib = appState.selectedLibrary;
   if( currentLib == "" ) { currentLib = appState.privateLibId; }
   
   for( final lib in appState.myLibraries ) {
      if( lib.id == currentLib ) { result = lib; break; }
   }
   return result;
}

Library getLib( appState ) {
   Library result = null;
   if( appState.myLibraries == null || appState.myLibraries.length < 1 ) { return result; }

   String currentLib = appState.selectedLibrary;
   if( currentLib == "" ) { currentLib = appState.privateLibId; }

   bool found = false;
   for( final lib in appState.myLibraries ) {
      if( lib.id == currentLib ) {
         result = lib; break;
         found = true;
      }
   }

   if( appState.exploreLibraries == null ) { return result; }
   if( !found ) {
      for( final lib in appState.exploreLibraries ) {
         if( lib.id == currentLib ) {
            result = lib; break;
         }
      }
   }
      
   return result;
}



// Title will wrap if need be, growing row height as needed
GestureDetector makeBookChunk( appState, book ) {
   final imageHeight = appState.screenHeight * .169;
   final imageWidth  = appState.screenWidth * .48;

   var image;
   if( book.image != null && book.image != "" ) { image = Image.network( book.image, height: imageHeight, width: imageWidth, fit: BoxFit.contain ); }
   else                                         { image = Image.asset( 'images/kush.jpeg', height: imageHeight, width: imageWidth, fit: BoxFit.cover); }
   
   return GestureDetector(
      onTap: () { print( "Giggle!" ); },
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.center,
         mainAxisAlignment: MainAxisAlignment.center,
         children: <Widget>[
            Row(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.start,
               children: <Widget> [
                  Padding(
                     padding: const EdgeInsets.fromLTRB(6.0, 6.0, 6.0, 6.0),
                     child: ClipRRect(
                        borderRadius: new BorderRadius.circular(12.0),
                        //child: Image.asset( 'images/dart.jpeg', height: imageHeight, width: imageWidth, fit: BoxFit.cover))),
                        child: image )),
                  Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: <Widget>[
                        // Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        Container( width: imageWidth, child: Text(book.title, softWrap: true, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                        Text("By: " + book.author, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                        Text("ISBN: " + book.ISBN, style: TextStyle(fontSize: 12)),
                        ])]),
            Container( color: Colors.lightBlue, height: appState.screenHeight*.0338 ),
            ]));
}


// inkscape
// XXX This doesn't belong here.
/// Flutter icons customIcons
/// Copyright (C) 2019 by original authors @ fluttericon.com, fontello.com
/// This font was generated by FlutterIcon.com, which is derived from Fontello.
class customIcons {
  customIcons._();

  static const _kFontFam = 'customIcons';

  static const IconData home = const IconData(0xe800, fontFamily: _kFontFam);
  static const IconData home_here = const IconData(0xe801, fontFamily: _kFontFam);
  static const IconData loan = const IconData(0xe802, fontFamily: _kFontFam);
  static const IconData loan_here = const IconData(0xe803, fontFamily: _kFontFam);
  static const IconData profile = const IconData(0xe804, fontFamily: _kFontFam);
  static const IconData profile_here = const IconData(0xe805, fontFamily: _kFontFam);
  static const IconData search = const IconData(0xe806, fontFamily: _kFontFam);
  static const IconData search_here = const IconData(0xe807, fontFamily: _kFontFam);
  static const IconData book_shelf = const IconData(0xe80a, fontFamily: _kFontFam);
  static const IconData book_shelf_here = const IconData(0xe80b, fontFamily: _kFontFam);
  static const IconData add_book = const IconData(0xe80f, fontFamily: _kFontFam);
  static const IconData add_book_here = const IconData(0xe810, fontFamily: _kFontFam);
}
