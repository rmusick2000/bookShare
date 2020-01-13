import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

const TESTER_NAME   = "_bs_tester_1664";
const TESTER_PASSWD = "passWD123";

// flutter drive --target=test_driver/app.dart
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
   // verify text not already in UI
   expect( await isPresent( driver, find.text( data ) ), false );

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
   await enterText( driver, userName, TESTER_NAME );
   await enterText( driver, password, TESTER_PASSWD );
   // Login, jump to homepage
   await driver.tap( loginButton );

   // verify topbar, botbar icons
   // These show up quickly. 
   print( "FIND ICONS" );
   await driver.waitFor( find.byValueKey( 'myLibraryIcon' ) );  // on top bar, but..
   await driver.waitFor( find.byValueKey( 'homeHereIcon' ) );   // landed here on bot bar


   // Default name of private lib, selected by default upon login.
   // This takes longer, once it shows up, fully loaded.
   await driver.waitFor( find.byValueKey( 'My Books' ) );  

   return true;
}


void main() {
  group('Login group', () {

        FlutterDriver driver;

        // Connect to the Flutter driver before running any tests.
        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        // Close the connection to the driver after the tests have completed.
        tearDownAll(() async {
              if (driver != null) {
                 driver.close();
              }
           });
        
        // create account
        // do 'lots of stuff'.
        // logout
        // login
        // login( driver );
        // do same 'lots of stuff'
        // logout
        // kill account

        test('Signin for known user', () async {
              bool known = true;
              await login( driver, known );

              // Use the `driver.getText` method to verify the counter starts at 0.
              // expect(await driver.getText(counterTextFinder), "0");
           });
        
        test('Attempted signin, unknown user', () async {
              // bool known = false;
              // await login( driver, known );
              // expect(await driver.getText(counterTextFinder), "1");
           });
     });
}
