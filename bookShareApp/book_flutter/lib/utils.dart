import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:bookShare/customIcons.dart';
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/screens/my_library_page.dart';
import 'package:bookShare/screens/loan_page.dart';
import 'package:bookShare/screens/search_page.dart';
import 'package:bookShare/screens/home_page.dart';
import 'package:bookShare/screens/add_book_page.dart';
import 'package:bookShare/screens/profile_page.dart';

import 'package:bookShare/models/libraries.dart';


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
                          key: Key( 'confirmDelete' ),
                          child: new Text("Continue"),
                          onPressed: okFunc ),
                       new FlatButton(
                          key: Key( 'cancelDelete' ),
                          child: new Text("Cancel"),
                          onPressed: cancelFunc )
                       ]);
              });
}

Widget paddedLTRB( child, double L, double T, double R, double B ) {
   return Padding(
      padding: EdgeInsets.fromLTRB(L,T,R,B),
      child: child );
}

Widget makeActionButton( appState, buttonText, fn ) {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 14.0);
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

Widget makeActionButtonSmall( appState, buttonText, fn ) {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 12.0);
   return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
         key: Key( buttonText ),
         minWidth: appState.screenWidth * .25,
         onPressed: fn,
         child: Text( buttonText,
                      textAlign: TextAlign.center,
                      style: style.copyWith(
                         color: Colors.white, fontWeight: FontWeight.bold)),
         )
      );
}


Widget makeTitleText( title, width, wrap, lines ) {
   return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 6, 0),
      child: Container( width: width,
                        key: Key( title ),
                        child: Text(title, softWrap: wrap, maxLines: lines, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))));
}

Widget makeAuthorText( author, width, wrap, lines ) {
   return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 6, 0),
      child: Container( width: width,
                        key: Key( author ),
                        child: Text("By: " + author, softWrap: wrap, maxLines: lines, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic))));
}
      
Widget makeInputField( BuildContext context, hintText, obscure, controller ) {
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


Widget makeTopAppBar( BuildContext context, currentPage ) {
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

Widget makeBotAppBar( BuildContext context, currentPage ) {
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
   final libraryName = lib.name;

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

   String libName = highlight ? "Selected: " : "";
   libName += libraryName;
   
   return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
         Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 10.0, 0, 0.0),
            child: ClipRRect(
               key: Key( libName ),
               borderRadius: new BorderRadius.circular(12.0),
               child: image )),
         Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 4.0, 0, 0.0),
            child: nameTxt),
         underline
         ]);
}

Future<ByteData> makePngBytes( appState, picture, width, height ) async {
   final img      = await picture.toImage( width, height );
   final pngBytes = await img.toByteData(format: ImageByteFormat.png);
   appState.currentPng = pngBytes.buffer.asUint8List();
   return pngBytes;
}

Library getPrivateLib( appState ) {
   Library result;
   if( appState.myLibraries == null || appState.myLibraries.length < 1 ) { return result; }
   for( final lib in appState.myLibraries ) {
      if( lib.private ) { result = lib; break; }
   }
   return result;
}

// get the library object of the users current selected library, if the user is a member
Library getMemberLib( appState ) {
   Library result;
   if( appState.myLibraries == null || appState.myLibraries.length < 1 ) { return result; }

   String currentLib = appState.selectedLibrary;
   if( currentLib == "" ) { currentLib = appState.privateLibId; }
   
   for( final lib in appState.myLibraries ) {
      if( lib.id == currentLib ) { result = lib; break; }
   }
   return result;
}

Library getLib( appState ) {
   Library result;
   if( appState.myLibraries == null || appState.myLibraries.length < 1 ) { return result; }

   String currentLib = appState.selectedLibrary;
   if( currentLib == "" ) { currentLib = appState.privateLibId; }

   bool found = false;
   for( final lib in appState.myLibraries ) {
      if( lib.id == currentLib ) {
         found = true;
         result = lib; break;
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


