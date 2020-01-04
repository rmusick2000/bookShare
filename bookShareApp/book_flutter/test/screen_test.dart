import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:bookShare/main.dart';
import 'package:bookShare/app_state_container.dart';

const TESTER_NAME   = "_bs_tester_1664";
const TESTER_PASSWD = "passWD123";

// STATUS: early termination.  Moving to Driver-based integration tests instead.

// Widget tests
// For BookShare, these tests are severely limited in scope due to the nature of flutter's WidgetTester framework: 
//    - setState is does not force re-build automatically during testing
//    - tests run in the same process as the app
//    - recommended not to test across async calls in app 
//    - daunting to create good finders without .byValueKey (a driver method).
// The majority of BookShare's functionality occurs post-authentication, and involves retrieving data over the network.
// For example, there is no good way to wait for Cognito.signin from the login app below.  Future.delayed deadlocks, Timer
// does not block until Duration, and pumpAndSettle for a duration doesn't help when no frames are scheduled in the app
// until after an async call completes. Additionally, manually pumping past setStates seems artificial and error prone.
// 
// Some issues may be worked around by mocking services, but this avoids large chunks of codepath.
//
// Integration tests with driver have several benefits - the main downside is the requirement to run on a device or an emulator.
// The current lack of support for running emulators in github CI is annoying, but hopefully will be addressed in the near term.

// Somewhat random notes: 
// finder runs each time you use it.. not cached.  That explains multiple objects within .byWidgetPredicate
// Bad state: no element can throw when finder has 1, but use of finder (i.e. enterText) requires a different type (i.e. editableText)
// don't just set usernameController directly...  avoids too much code
// hmm... not going to get around confirmation code without magic.  Could turn off auto-verification for this test user..?
// https://stackoverflow.com/questions/58796911/flutter-testing-forms
// https://stackoverflow.com/questions/41404878/aws-cognito-test-environment


Future<bool> createAccount( WidgetTester tester ) async {

   // Verify key launch page buttons
   expect(find.text('Create New Account'), findsOneWidget);
   expect(find.text('Login'), findsOneWidget);
   
   Finder button = find.byWidgetPredicate(
      ( Widget widget ) => widget is MaterialButton && (widget.child as Text).data == 'Create New Account',
      description: "Find me the create acct button" );
   
   await tester.tap( button );

   await tester.pumpAndSettle();
   
   // expect to find login stuff
   expect( find.text( 'username' ), findsOneWidget );
   expect( find.text( 'password' ), findsOneWidget );
   expect( find.text( 'email address' ), findsOneWidget );
   expect( find.text( 'Send confirmation code' ),    findsOneWidget );

   return true;
}

Future<bool> login( WidgetTester tester ) async {

   // Verify key launch page buttons
   expect(find.text('Create New Account'), findsOneWidget);
   expect(find.text('Login'), findsOneWidget);

   // Go to login page
   Finder button = find.byWidgetPredicate( ( Widget widget ) => widget is MaterialButton && (widget.child as Text).data == 'Login' );
   await tester.tap( button );
   await tester.pumpAndSettle();
   
   // expect to find login stuff
   expect( find.text( 'username' ), findsOneWidget ); 
   expect( find.text( 'password' ), findsOneWidget );
   expect( find.text( 'Login' ),    findsOneWidget );


   // enter name, passwd
   Finder userName = find.byWidgetPredicate( ( Widget widget ) {
         return ( widget is TextField && (widget as TextField).decoration.hintText == 'username' );
      });
   await tester.enterText( userName, TESTER_NAME );

   Finder passwd = find.byWidgetPredicate( ( Widget widget ) {
         return ( widget is TextField && (widget as TextField).decoration.hintText == 'password' );
      });
   await tester.enterText( passwd, TESTER_PASSWD );

   // Actually log in
   Finder loginButton = find.byWidgetPredicate( ( Widget widget ) => widget is MaterialButton && (widget.child as Text).data == 'Login' );
   await tester.tap( loginButton );
   await tester.pumpAndSettle( Duration(seconds: 25) );  // duration is no help here - no scheduled frames

   // https://stackoverflow.com/questions/52176777/how-to-wait-for-a-future-to-complete-in-flutter-widget-test
   // await Future.delayed( Duration( seconds: 10 ), () { print( "wait done" ); });
   
   // expect to find homepage stuff, buuuuut
   // login has not gotten through cognito yet, so this fails.
   // expect( find.text( 'My Books' ), findsOneWidget );
   return true;
}


void main() {

   // Need to be logged in to do much of anything.  
   testWidgets('Test framework', (WidgetTester tester) async {

         //await tester.runAsync(() async {
               
               // Build BookShare, wait for splash screen
               await tester.pumpWidget( AppStateContainer( child: new BSApp()) );
               await tester.pumpAndSettle( Duration(seconds: 25) );
               
               bool res = false;
               
               // create account
               // res = await createAccount( tester );
               //assert( res );
               
               // do 'lots of stuff'.
               // logout
               // login
               res = await login( tester );
               assert( res );
               
               // do same 'lots of stuff'
               // logout
               // kill account
               
         // });
      });
}

