import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

const TESTER_NAME   = "_bs_tester_1664";
const TESTER_PASSWD = "passWD123";

// https://medium.com/flutter-community/testing-flutter-ui-with-flutter-driver-c1583681e337


// XXX darg... fluuuuuttterrrrrrr
Future<bool> isPresent( FlutterDriver driver, SerializableFinder finder ) async {
   try {
      // NOTE 200 was overly eager.  500 OK?
      await driver.waitFor(finder, timeout: Duration( milliseconds: 500 ) );
      return true;
   } catch (e) {
      return false;
   }
}

Future<bool> enterText( FlutterDriver driver, SerializableFinder txtField, String data ) async {
   // verify text not already in UI.. note this is overly aggressive, as it fails if data shows up in another widget.
   if( data != "" ) { expect( await isPresent( driver, find.text( data ) ), false ); }

   // acquire focus
   await driver.tap( txtField );
   // enter text
   await driver.enterText( data );
   // verify in ui
   expect( await isPresent( driver, find.text( data )), true );

   return true;
}


Future<bool> login( FlutterDriver driver, known ) async {

   SerializableFinder loginButton = find.byValueKey('Login');
      
   // Verify key launch page buttons
   await driver.waitFor( find.byValueKey('Create New Account') );
   await driver.waitFor( loginButton );

   // Jump to login page
   await driver.tap( loginButton );

   SerializableFinder userName = find.byValueKey('username');
   SerializableFinder password = find.byValueKey('password');

   // will re-find login on current page
   await driver.waitFor( userName );
   await driver.waitFor( password );
   await driver.waitFor( loginButton );

   // Enter u/p and attempt to login
   String tname = TESTER_NAME;
   tname += known ? "" : "1234321";
   await enterText( driver, userName, tname );
   await enterText( driver, password, TESTER_PASSWD );
   // Login, jump to homepage
   await driver.tap( loginButton );

   // verify topbar, botbar icons
   // These show up quickly.
   if( known ) {
      print( "FIND ICONS" );
      await driver.waitFor( find.byValueKey( 'myLibraryIcon' ) );  // on top bar, but..
      await driver.waitFor( find.byValueKey( 'homeHereIcon' ) );   // landed here on bot bar

      // Default name of private lib, selected by default upon login.
      // This takes longer, once it shows up, fully loaded.
      await driver.waitFor( find.byValueKey( 'My Books' ) );  
   } else {
      // can't apply key to toast, so... look for no app bar, yes login stuff
      expect( await isPresent( driver, find.byValueKey( 'homeIcon' ) ), false );
      expect( await isPresent( driver, find.byValueKey( 'homeHereIcon' ) ), false );

      await driver.waitFor( userName );
      await driver.waitFor( password );
      await driver.waitFor( loginButton );
   }



   return true;
}


Future<bool> logout( FlutterDriver driver ) async {

   // Go to profile page
   SerializableFinder profileIcon = find.byValueKey( 'profileIcon' );
   expect( await isPresent( driver, profileIcon ), true );
   await driver.tap( profileIcon ); 

   // Logout
   SerializableFinder profileHereIcon = find.byValueKey( 'profileHereIcon' );
   SerializableFinder logoutButton = find.byValueKey('Logout');
   expect( await isPresent( driver, profileHereIcon ), true );
   expect( await isPresent( driver, logoutButton ), true );
   await driver.tap( logoutButton );

   // Verify signin page
   await driver.waitFor( find.byValueKey('Create New Account') );
   await driver.waitFor( find.byValueKey('Login') );
   expect( await isPresent( driver, profileIcon ), false );
   expect( await isPresent( driver, profileHereIcon ), false );

   return true;
}
