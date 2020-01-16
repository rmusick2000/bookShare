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

  group('BookShare Test Group, content:login', () {

        FlutterDriver driver;

        // Connect to the Flutter driver before running any tests.
        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        // Close the connection to the driver after the tests have completed.
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        test('Signin for known user', () async {
              bool known = true;
              await login( driver, known );
           });

     });

  group('BookShare Test Group, content:add books', () {

        FlutterDriver driver;

        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        // XXX getting bumblebees here, boogers on my phone
        // XXX BUG when hit refine within book search, select book, refine box doesn't disappear
        // XXX delete
        test('Add book w/refine search', () async {
              bool known = true;
              await gotoAddBook( driver );
              //await refineAdd( driver, "Boogers", "", 6, "more" );     // scroll to dragon, land in addbook
              //await refineAdd( driver, "warship", "", 0, "more" );     // add first, land in addbook
              await refineAdd( driver, "warship", "", 0, "refine" );     // dont add, land in addbook:refine
              await refineAdd( driver, "", "musick", 5, "more", false ); // add by author, land in addbook
              await refineAdd( driver, "Magic", "", 0, "home" );         // add first, land in homepage
              /*
              await verifyHome( driver);
              */
              // Add to 10
              // go home, verify selections, scrolling, book view
              // add delete book
           });


     });
  
}
