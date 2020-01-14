import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import '../test_driver/utils.dart';

// create account
// do 'lots of stuff'.
// logout
// login
// login( driver );
// do same 'lots of stuff'
// logout
// kill account

void main() {

  group('Login group, good user', () {

        FlutterDriver driver;

        // Connect to the Flutter driver before running any tests.
        setUpAll(() async {
              print( "IN SETUPALL" );
              driver = await FlutterDriver.connect();
           });
        
        // Close the connection to the driver after the tests have completed.
        tearDownAll(() async {
              print( "IN TEARDOWN" );
              if (driver != null) { driver.close(); }
           });

        test('Signin for known user', () async {
              bool known = true;
              await login( driver, known );
           });

        test('Logout.', () async {
              await logout( driver );
           });

        test('Login.', () async {
              bool known = true;
              await login( driver, known );
           });


     });
  
}
