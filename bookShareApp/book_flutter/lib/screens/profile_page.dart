import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

import 'package:bookShare/screens/launch_page.dart';

import 'package:bookShare/screens/my_library_page.dart';
import 'package:bookShare/screens/loan_page.dart';
import 'package:bookShare/screens/search_page.dart';
import 'package:bookShare/screens/home_page.dart';
import 'package:bookShare/screens/add_book_page.dart';
import 'package:bookShare/screens/profile_page.dart';

import 'package:bookShare/utils.dart';
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/models/app_state.dart';


class BookShareProfilePage extends StatefulWidget {
  BookShareProfilePage({Key key}) : super(key: key);

  @override
  _BookShareProfileState createState() => _BookShareProfileState();

}


class _BookShareProfileState extends State<BookShareProfilePage> {

   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
   AppState appState; 
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
      appState = container.state;

      final logoutButton = makeActionButton( context, 'Logout',  container.onPressWrapper((){
               Cognito.signOut();
               Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (context) => BSLaunchPage()),
                  ModalRoute.withName("BSSplashPage")
                  );
               setState(() {
                     bookState = "illiterate";
                     appState.usernameController.clear();
                     appState.passwordController.clear();
                     appState.attributeController.clear();
                     appState.confirmationCodeController.clear();
                  });
            }));


      
   return Scaffold(
        appBar: makeTopAppBar( context, "Profile" ),
        bottomNavigationBar: makeBotAppBar( context, "Profile" ),
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
                          logoutButton,
                          SizedBox(height: 5.0),
                          Text( appState.userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic))
                          ])))
              
              )));
   }
}
