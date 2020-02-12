import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';
import 'package:random_string/random_string.dart';

import 'package:bookShare/utils.dart';
import 'package:bookShare/utils_load.dart';
import 'package:bookShare/app_state_container.dart';
import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/models/people.dart';
import 'package:bookShare/models/libraries.dart';
import 'package:bookShare/screens/home_page.dart';

class BookShareSignupPage extends StatefulWidget {
  BookShareSignupPage({Key key}) : super(key: key);

  @override
  _BookShareSignupState createState() => _BookShareSignupState();
}


class _BookShareSignupState extends State<BookShareSignupPage> {
   TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

   // Always create with false.  When logout, all stacks pop, recreate is with false.
   bool showCC = false;
   
   @override
   void initState() {
      super.initState();
      showCC = false;
   }

   @override
   void dispose() {
      super.dispose();
   }
   
   @override
   Widget build(BuildContext context) {

      
      final container = AppStateContainer.of(context);
      final appState = container.state;
      
      final usernameField = makeInputField( context, "username", false, appState.usernameController );
      final passwordField = makeInputField( context, "password", true, appState.passwordController );
      final emailField    = makeInputField( context, "email address", false, appState.attributeController );
      final confirmationCodeField = makeInputField( context, "confirmation code", false, appState.confirmationCodeController );

      final signupButton = makeActionButton( appState, "Send confirmation code", container.onPressWrapper(() async {
               final email = {'email' : appState.attributeController.text };
               try{
                  await Cognito.signUp( appState.usernameController.text, appState.passwordController.text, email );
                  showToast( context, "Code sent to your email");
                  setState(() { showCC = true; });
               } catch(e) {
                  if( e.toString().contains("\'password\' failed") ) {
                     showToast( context, "Password needs 8 chars, some Caps, and some not in the alphabet." );
                  } else if(e.toString().contains("Invalid email address") ) {
                     showToast( context, "Email address is broken." );
                  } else {
                     showToast( context, e.toString() );
                  }}
            }));

      final confirmSignupButton = makeActionButton( appState, "Confirm signup, and Log in", container.onPressWrapper(() async {
               await Cognito.confirmSignUp( appState.usernameController.text, appState.confirmationCodeController.text );

               appState.newUser = true;
               await Cognito.signIn( appState.usernameController.text, appState.passwordController.text );
               bool signedIn = await Cognito.isSignedIn();
               if( signedIn ) { appState.userState = UserState.SIGNED_IN; }

               if( appState.userState != UserState.SIGNED_IN ) {
                  showToast( context, "Signin failed.  Incorrect confirmation code?" );
                  return;
               }
               await container.newUserBasics();

               
               // Person and private lib must exist before signin
               String pid = randomAlpha(10);
               String editLibId = randomAlpha(10);
               appState.userId = pid;

               List<String> meme = new List<String>();
               meme.add( appState.userId );
               Library editLibrary = new Library( id: editLibId, name: "My Books", private: true, members: meme, imagePng: null, image: null,
                                                  prospect: false );

               String newLib = json.encode( editLibrary );
               String lpostData = '{ "Endpoint": "PutLib", "NewLib": $newLib }';
               await putLib( context, container, lpostData );

               
               Person user = new Person( id: pid, firstName: "Marion", lastName: "Star", userName: appState.usernameController.text,
                                         email: appState.attributeController.text, imagePng: null, image: null );

               String newUser = json.encode( user );
               String ppostData = '{ "Endpoint": "PutPerson", "NewPerson": $newUser }';
               await putPerson( context, container, ppostData );

               appState.newUser = false;
               appState.loading = true;
               await initMyLibraries( context, container );
               appState.loading = false;
               appState.loaded = true;
               
               MaterialPageRoute newPage = MaterialPageRoute(builder: (context) => BookShareHomePage());
               Navigator.push( context, newPage );
            }));      

      return Scaffold(
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
                           usernameField,
                           SizedBox(height: 5.0),
                           passwordField,
                           SizedBox( height: 5.0),
                           emailField,
                           SizedBox( height: 5.0),
                           Visibility( visible: showCC, child: confirmationCodeField ),
                           SizedBox( height: 5.0),
                           Visibility( visible: !showCC, child: signupButton ),
                           SizedBox( height: 5.0),
                           Visibility( visible: showCC, child: confirmSignupButton ),
                           SizedBox( height: 5.0),
                           Text( appState.userState?.toString() ?? "UserState here", style: TextStyle(fontStyle: FontStyle.italic))
                           ])))
               
               )));
   }
}
