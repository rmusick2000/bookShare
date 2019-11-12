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
               manageRouteStack( context, newPage, "mylib" );
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
                  manageRouteStack( context, newPage, "loan" );
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
                  manageRouteStack( context, newPage, "search" );
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
                     manageRouteStack( context, newPage, "home" );
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
                           manageRouteStack( context, newPage, "add" );
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
                           manageRouteStack( context, newPage, "profile" );
                           Navigator.push( context, newPage );
                        },
                        iconSize: iconSize,
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
                        )
                     ])
               ])));
}


// Title will wrap if need be, growing row height as needed
GestureDetector makeBookChunk( appState, book ) {
   // final imageHeight = appState.screenHeight * .169;
   final imageHeight = appState.screenHeight * .6;
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







// Keep a rotating route stack, in a list, to support navigator removeBelowRoute.
// This helps keep a functioning back button (up to some number), while putting a hard
// limit on the size of the navigator stack.  Stack size limit is routeStack.length + 1
void manageRouteStack( context, newPage, pageName ) {
   final container   = AppStateContainer.of(context);
   final appState    = container.state;

   // Remove anchor if it's on the stack
   // Remove is very sensitive and error prone.  If routeStack is null, looks like memory corruption
   // if try to remove at stack depth, bad things can happen.  Only allow at stack depth + 1
   try {
      if( appState.routeStack[appState.anchor] != null && appState.stackDepth > appState.maxDepth ) {
         Navigator.removeRouteBelow( context, appState.routeStack[appState.anchor] );
         appState.stackDepth = appState.maxDepth;
      }
   } catch( e ) {
      print( "MRS failed to removeRoute, anchor: " + appState.anchor.toString() );
   }
       
   // update
   appState.routeStack[appState.anchor] = newPage;
   appState.stackDepth++;
   
   // Because the stack is on the widge tree, they get updated.  This enables a short-circuit
   // in each screen to do the minimal work.  buuuut.. does it kill back?
   appState.routeName[appState.anchor] = pageName;
   appState.anchor = (appState.anchor+1) % appState.routeStack.length;
}

bool isCurrentRoute( appState, pageName, routeNum ) {
   bool retVal = false;
   int anchor = getRouteNum( appState );
   
   if( ( routeNum == anchor || routeNum == -1 ) && appState.routeName[anchor] == pageName ) { retVal = true; }

   return retVal;
}

int getRouteNum( appState ) {
   if( appState.anchor > 0 ) { return appState.anchor - 1; }
   else                      { return appState.routeName.length - 1; }
}

// Without managing back button, computation avoidance with routeName fails (empty container)
Future<bool> requestPop( context ) {
   final container   = AppStateContainer.of(context);
   final appState    = container.state;
   
   if( appState.anchor > 0 ) { appState.anchor--; }
   else {  appState.anchor = appState.routeName.length - 1; }

   // Remove route from routeStack, else next push removeRouteBelow, anchor is not null,
   // nor is it on Navigator's stack.  Furthermore, probably has been disposed, and so is in bad
   // internal shape.
   appState.routeStack[appState.anchor] = null;
   appState.routeName[appState.anchor] = "";
   appState.stackDepth--;
   
   return new Future.value(true);
}


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
