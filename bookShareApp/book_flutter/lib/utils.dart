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
   return Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(10.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
         minWidth: MediaQuery.of(context).size.width - 30,
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
   return PreferredSize(
      preferredSize: Size.fromHeight(32.0),
      child: AppBar(
         leading: IconButton(
            icon: currentPage == "MyLibrary" ? Icon(customIcons.book_shelf_here) : Icon(customIcons.book_shelf),
            onPressed: ()
            {
               MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareMyLibraryPage());
               manageRouteStack( context, newPage );
               currentPage == "MyLibrary" ? {} : Navigator.push( context, newPage );
            },
            iconSize: 25,
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
            ),
         title: Text( "BookShare", style: new TextStyle( fontFamily: 'Mansalva', fontSize: 16 )),
         actions: <Widget>[
            IconButton(
               icon: currentPage == "Loan" ? Icon(customIcons.loan_here) : Icon(customIcons.loan),
               onPressed: ()
               {
                  MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareLoanPage());
                  manageRouteStack( context, newPage );
                  currentPage == "Loan" ? {} : Navigator.push( context, newPage);
               },
               iconSize: 25,
               //padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 1.0)
               ),
            IconButton(
               icon: currentPage == "Search" ? Icon(customIcons.search_here) : Icon(customIcons.search),
               onPressed: ()
               {
                  MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareSearchPage());
                  manageRouteStack( context, newPage );
                  currentPage == "Search" ? {} : Navigator.push( context, newPage );
               },
               iconSize: 25,
               padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 1.0)
               ),
            ]));
}

makeBotAppBar( BuildContext context, currentPage ) {
   return SizedBox(
      height: 32, 
      child: BottomAppBar(
         child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
               IconButton(
                  icon: currentPage == "Home" ? Icon(customIcons.home_here) : Icon(customIcons.home),
                  onPressed: ()
                  {
                     MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareHomePage());
                     manageRouteStack( context, newPage );
                     currentPage == "Home" ? {} : Navigator.push( context, newPage );
                  },
                  iconSize: 25,
                  padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
                  ),
               Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                     IconButton(
                        icon: currentPage == "AddBook" ? Icon(customIcons.add_book_here) : Icon(customIcons.add_book),
                        onPressed: ()
                        {
                           MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareAddBookPage());
                           manageRouteStack( context, newPage );
                           currentPage == "AddBook" ? {} : Navigator.push( context, newPage );
                        },
                        iconSize: 25,
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
                        ),
                     IconButton(
                        icon: currentPage == "Profile" ? Icon(customIcons.profile_here) : Icon(customIcons.profile),
                        onPressed: ()
                        {
                           MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareProfilePage());
                           manageRouteStack( context, newPage );
                           currentPage == "Profile" ? {} : Navigator.push( context, newPage );
                        },
                        iconSize: 25,
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
                        )
                     ])
               ])));
}



// Keep a rotating route stack, in a list, to support navigator removeBelowRoute.
// This helps keep a functioning back button (up to some number), while putting a hard
// limit on the size of the navigator stack.  Stack size limit is routeStack.length + 1
void manageRouteStack( context, newPage ) {
   final container   = AppStateContainer.of(context);
   final appState    = container.state;

   // Remove anchor if it's on the stack
   try {
      if( appState.routeStack[appState.anchor] != null ) {
         // Hmmm this deletes stuff badly if routeStack is null
         Navigator.removeRouteBelow( context, appState.routeStack[appState.anchor] );
      }
   } catch( e ) {
      print( "MRS failed to removeRoute, anchor: " + appState.anchor.toString() );
   }
       
   // update
   appState.routeStack[appState.anchor] = newPage;
   appState.anchor = (appState.anchor+1) % appState.routeStack.length;
   
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
