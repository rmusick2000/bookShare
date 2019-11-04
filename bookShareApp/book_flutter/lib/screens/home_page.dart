import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:bookShare/screens/my_library_page.dart';
import 'package:bookShare/screens/loan_page.dart';
import 'package:bookShare/screens/search_page.dart';
import 'package:bookShare/screens/home_page.dart';
import 'package:bookShare/screens/add_book_page.dart';
import 'package:bookShare/screens/profile_page.dart';

import 'package:bookShare/utils.dart';
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/models/app_state.dart';





class BookShareHomePage extends StatefulWidget {
  BookShareHomePage({Key key}) : super(key: key);

  @override
  _BookShareHomeState createState() => _BookShareHomeState();
}


class _BookShareHomeState extends State<BookShareHomePage> {

   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   String bookState;
   
   @override
   void initState() {
      super.initState();
   }


   @override
   void dispose() {
      super.dispose();
   }
   
   final libraryBar = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row (
         mainAxisSize: MainAxisSize.max,
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: <Widget>[
            GestureDetector(
               onTap: () {
                               print("Container clicked");
                            },
               child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0, 0.0),
                     child: ClipRRect(
                        borderRadius: new BorderRadius.circular(12.0),
                        child: Image.asset( 'images/kiteLibrary.jpg', height: 60.0, width: 60.0, fit: BoxFit.fill))),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12.0, 4.0, 0, 0.0),
                     child: Text("My Libraryxx", style: TextStyle(fontSize: 12)))])
               ),
            Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0, 0.0),
                     child: ClipRRect(
                        borderRadius: new BorderRadius.circular(12.0),
                        child: Image.asset( 'images/kiteLibrary.jpg', height: 60.0, width: 60.0, fit: BoxFit.fill))),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12.0, 4.0, 0, 0.0),
                     child: Text("My Libraryxx", style: TextStyle(fontSize: 12)))]),
            Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0, 0.0),
                     child: ClipRRect(
                        borderRadius: new BorderRadius.circular(12.0),
                        child: Image.asset( 'images/kiteLibrary.jpg', height: 60.0, width: 60.0, fit: BoxFit.fill))),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12.0, 4.0, 0, 0.0),
                     child: Text("My Libraryxx", style: TextStyle(fontSize: 12)))]),
            Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0, 0.0),
                     child: ClipRRect(
                        borderRadius: new BorderRadius.circular(12.0),
                        child: Image.asset( 'images/kiteLibrary.jpg', height: 60.0, width: 60.0, fit: BoxFit.fill))),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12.0, 4.0, 0, 0.0),
                     child: Text("My Libraryxx", style: TextStyle(fontSize: 12)))]),
            Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.center,
               children: <Widget>[
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12.0, 12.0, 0, 0.0),
                     child: ClipRRect(
                        borderRadius: new BorderRadius.circular(12.0),
                        child: Image.asset( 'images/kiteLibrary.jpg', height: 60.0, width: 60.0, fit: BoxFit.fill))),
                  Padding(
                     padding: const EdgeInsets.fromLTRB(12.0, 4.0, 0, 0.0),
                     child: Text("My Libraryxx", style: TextStyle(fontSize: 12)))]),
               
               ]));


   @override
   Widget build(BuildContext context) {

      final container = AppStateContainer.of(context);
      final appState = container.state;

      return Scaffold(
         appBar: makeTopAppBar( context, "Home" ),
         bottomNavigationBar: makeBotAppBar( context, "Home" ),
         body: Center(
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               mainAxisAlignment: MainAxisAlignment.start,
               children: <Widget>[
                  libraryBar,
                  Divider( color: Colors.grey[200], thickness: 3.0 ),
                  
                  SingleChildScrollView( 
                     child: Container(
                        color: Colors.white,
                        child: Padding(
                           padding: const EdgeInsets.all(36.0),
                           child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                 SizedBox(height: 5.0),
                                 Text( "Home", style: TextStyle(fontWeight: FontWeight.bold)),
                                 SizedBox(height: 5.0),
                                 Text( appState.userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic)),
                                 ]))))
                  ])));
   }
}
