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

makeActionButton( BuildContext context, buttonText, fn ) {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
   final container   = AppStateContainer.of(context);
   final appState    = container.state;
   return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
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


makeInputField( BuildContext context, hintText, obscure, controller ) {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   return TextField(
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
                  onPressed: ()
                  {
                     if( currentPage == "Home" ) { return; }
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

Library getPrivateLib( appState ) {
   Library result = null;
   if( appState.myLibraries == null || appState.myLibraries.length < 1 ) { return result; }
   for( final lib in appState.myLibraries ) {
      if( lib.private ) { result = lib; break; }
   }
   return result;
}

Library getCurrentLib( appState ) {
   Library result = null;
   if( appState.myLibraries == null || appState.myLibraries.length < 1 ) { return result; }

   String currentLib = appState.selectedLibrary;
   if( currentLib == "" ) { currentLib = appState.privateLibId; }
   
   for( final lib in appState.myLibraries ) {
      if( lib.id == currentLib ) { result = lib; break; }
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
