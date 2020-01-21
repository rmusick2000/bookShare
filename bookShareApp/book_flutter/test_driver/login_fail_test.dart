import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import '../test_driver/utils.dart';

void main() {
  group('BookShare Test Group, bad user', () {

        FlutterDriver driver;

        // Connect to the Flutter driver before running any tests.
        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        // Close the connection to the driver after the tests have completed.
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        test('Attempted signin, unknown user', () async {
              bool known = false;
              await login( driver, known );

              // clear out login stuff, hit back
              SerializableFinder userName = find.byValueKey('username');
              SerializableFinder password = find.byValueKey('password');
              print( "reset uname" );
              await enterText( driver, userName, "" );
              print( "reset passwd" );
              await enterText( driver, password, "" );


              // Can't (yet) find system back button from within driver, nor can you pop a route.
              // Can't (yet) restart (waiting for https://github.com/tomaszpolanski/fast_flutter_driver
              // new file... can at least avoid rebuild.
           });


     });
  
}
