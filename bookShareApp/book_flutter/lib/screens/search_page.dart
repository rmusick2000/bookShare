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


class BookShareSearchPage extends StatefulWidget {
  BookShareSearchPage({Key key}) : super(key: key);

  @override
  _BookShareSearchState createState() => _BookShareSearchState();
}


class _BookShareSearchState extends State<BookShareSearchPage> {

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
  
   @override
   Widget build(BuildContext context) {

      final container = AppStateContainer.of(context);
      final appState = container.state;

     return Scaffold(
        appBar: PreferredSize(
           preferredSize: Size.fromHeight(32.0),
           child: AppBar(
              leading: IconButton(
                 icon: Icon(customIcons.book_shelf),
                 onPressed: ()
                 {
                    Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => BookShareMyLibraryPage()));
                 },
                 iconSize: 25,
                 padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
                 ),
              title: Text( "BookShare", style: new TextStyle( fontFamily: 'Mansalva', fontSize: 16 )),
              actions: <Widget>[
                 IconButton(
                    icon: Icon(customIcons.loan),
                    onPressed: ()
                    {
                       Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BookShareLoanPage()));
                    },
                    iconSize: 25,
                    //padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 1.0)
                    ),
                 IconButton(
                    icon: Icon(customIcons.search_here),
                    onPressed: (){},
                    iconSize: 25,
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 1.0)
                    ),
                 ])),

        bottomNavigationBar: SizedBox( height: 32, 
           child: BottomAppBar(
              child: Row(
                 mainAxisSize: MainAxisSize.max,
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: <Widget>[
                    IconButton(
                       icon: Icon(customIcons.home),
                       onPressed: ()
                       {
                          Navigator.push(
                             context,
                             MaterialPageRoute(builder: (context) => BookShareHomePage()));
                       },
                       iconSize: 25,
                       padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
                       ),
                    Row(
                       mainAxisSize: MainAxisSize.max,
                       children: [
                          IconButton(
                             icon: Icon(customIcons.add_book),
                             onPressed: ()
                             {
                                Navigator.push(
                                   context,
                                   MaterialPageRoute(builder: (context) => BookShareAddBookPage()));
                             },
                             iconSize: 25,
                             padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
                             ),
                          IconButton(
                             icon: Icon(customIcons.profile),
                             onPressed: ()
                             {
                                Navigator.push(
                                   context,
                                   MaterialPageRoute(builder: (context) => BookShareProfilePage()));
                             },
                             iconSize: 25,
                             padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0)
                             )
                          ])
                    ]))),

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
                          Text( "Search", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 5.0),
                          Text( appState.userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic))
                          ])))
              
              )));
   }
}
