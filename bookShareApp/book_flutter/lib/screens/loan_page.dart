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


class BookShareLoanPage extends StatefulWidget {
  BookShareLoanPage({Key key}) : super(key: key);

  @override
  _BookShareLoanState createState() => _BookShareLoanState();
}


class _BookShareLoanState extends State<BookShareLoanPage> {

   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   String bookState;
   int myRouteNum;

  @override
     void initState() {
     super.initState();
     myRouteNum = -1;
   }


  @override
  void dispose() {
    super.dispose();
  }
  
   @override
   Widget build(BuildContext context) {

      final container = AppStateContainer.of(context);
      final appState = container.state;

     return Scaffold(
        appBar: makeTopAppBar( context, "Loan" ),
        bottomNavigationBar: makeBotAppBar( context, "Loan" ),
        body: Center(
           child: SingleChildScrollView( 
              child: Container(
                 color: Colors.white,
                 child: Padding(
                    padding: const EdgeInsets.all(36.0),
                    child: Column(
                       crossAxisAlignment: CrossAxisAlignment.center,
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: <Widget>[
                          SizedBox(height: 5.0),
                          Text( "Loans, Requests", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5.0),
                          Text( appState.userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic))
                          ])))
              
              )));
   }
}
