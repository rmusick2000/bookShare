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

// Tricky, since scrollUntil scrolls before looking.  Decided to look first -
// could also have smaller dx
Future<bool> verifyHomeBatch1( FlutterDriver driver ) async {
   expect( await verifyOnHomePage( driver ), true );
   SerializableFinder theList   = find.byValueKey('searchedBooks');

   // Find all 4 books that we just added
   print( "Dragon Boogers" );
   SerializableFinder theChoice = find.byValueKey('Dragon Boogers');
   await driver.scroll( theList, 1000.0, 0.0, Duration( milliseconds: 500 ));       // go to start
   await driver.scrollUntilVisible( theList, theChoice, dxScroll: -200.0 );
   
   print( "Warship" );
   theChoice = find.byValueKey('Warship');
   await driver.scroll( theList, 1000.0, 0.0, Duration( milliseconds: 500 ));
   await driver.scrollUntilVisible( theList, theChoice, dxScroll: -200.0 );

   print( "Money Magic Tricks" );
   theChoice = find.byValueKey('Money Magic Tricks');
   await driver.scroll( theList, 1000.0, 0.0, Duration( milliseconds: 500 ));
   if( !(await isPresent( driver, theChoice ))) {
      await driver.scrollUntilVisible( theList, theChoice, dxScroll: -200.0 );
   }

   print( "Musick" );
   theChoice = find.byValueKey('Melissa Musick Nussbaum');
   await driver.scroll( theList, 1000.0, 0.0, Duration( milliseconds: 500 ));
   await driver.scrollUntilVisible( theList, theChoice, dxScroll: -200.0 );

   return true;
}

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

  /*
  group('BookShare Test Group, content:add books', () {

        FlutterDriver driver;

        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        test('Add book w/refine search', () async {
              bool known = true;
              await gotoAddBook( driver );

              await refineAdd( driver, "Boogers", "", 4, "more" );     // scroll to dragon, land in addbook
              await refineAdd( driver, "warship", "", 0, "more" );     // add first, land in addbook
              await refineAdd( driver, "warship", "", 0, "refine" );     // dont add, land in addbook:refine
              await refineAdd( driver, "", "musick", 5, "more", false ); // add by author, land in addbook
              await refineAdd( driver, "Magic", "", 0, "home" );         // add first, land in homepage

              expect( await verifyHomeBatch1( driver ), true );
              await gotoAddBook( driver );

              await refineAdd( driver, "Analysis", "", 0, "more" );    
              await refineAdd( driver, "Keanna", "", 0, "more" );    
              await refineAdd( driver, "rain hail", "", 1, "more" );    
              await refineAdd( driver, "storm sea", "", 0, "more" );    
              await refineAdd( driver, "mountain chimney", "", 1, "more" );    
              await refineAdd( driver, "hunca munca", "", 0, "home" );    
           });

     });
  

  group('BookShare Test Group, content:book detail', () {

        FlutterDriver driver;

        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        test('Check book details', () async {
              if( !( await isPresent( driver, find.byValueKey( 'homeHereIcon' ))) ) { await gotoHome( driver ); }
              SerializableFinder theList  = find.byValueKey('searchedBooks');
              SerializableFinder back     = find.byValueKey('Back');
              
              print( "Meet Hunca Munca" );
              SerializableFinder theChoice = find.byValueKey('Meet Hunca Munca');
              await driver.scroll( theList, 1000.0, 0.0, Duration( milliseconds: 500 ));       // go to start
              await driver.scrollUntilVisible( theList, theChoice, dxScroll: -200.0 );
              await driver.tap( theChoice );
              expect( await isPresent( driver, find.text( 'Meet Hunca Munca' )), true );
              expect( await isPresent( driver, find.text( 'By: Beatrix Potter' )), true );
              expect( await isPresent( driver, find.text( 'Publisher: Warne' )), true );
              expect( await isPresent( driver, find.text( 'Published date: 1986' )), true );
              expect( await isPresent( driver, back), true );

              SerializableFinder details  = find.byValueKey('bookDetail');
              await driver.scroll( details, 0.0, -500.0, Duration( milliseconds: 500 ));      
              expect( await isPresent( driver, find.byValueKey( 'Delete' ), 2000), true );
              expect( await isPresent( driver, find.text( 'Preferred ISBN: 9780723234210' )), true );
              expect( await isPresent( driver, find.text( 'Pages: 12' )), true );
              expect( await isPresent( driver, find.byValueKey( 'Description' )), true );
              await driver.tap( back );
              expect( await verifyOnHomePage( driver ), true );
              
              print( "Mari Schuh" );
              theChoice = find.byValueKey('Mari Schuh');
              await driver.scroll( theList, 2000.0, 0.0, Duration( milliseconds: 500 ));
              await driver.scrollUntilVisible( theList, theChoice, dxScroll: -200.0 );
              await driver.tap( theChoice );
              expect( await isPresent( driver, find.text( 'Rain, Snow, Sleet, and Hail' ), 2000), true );
              expect( await isPresent( driver, find.text( 'Publisher: Carson-Dellosa Publishing' )), true );
              expect( await isPresent( driver, back), true );

              await driver.scroll( details, 0.0, -500.0, Duration( milliseconds: 500 ));      
              expect( await isPresent( driver, find.byValueKey( 'Delete' ), 2000), true );
              expect( await isPresent( driver, find.text( 'Preferred ISBN: 9781731628480' )), true );
              expect( await isPresent( driver, find.byValueKey( 'Description' )), true );
              await driver.tap( back );
              expect( await verifyOnHomePage( driver ), true );
              
           });
     });
  */
  
  group('BookShare Test Group, content:myLibPage', () {

        FlutterDriver driver;

        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        test('XXX', () async {
           });
     });

  group('BookShare Test Group, content:homePage', () {

        FlutterDriver driver;

        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        test('XXX', () async {
           });
     });

  group('BookShare Test Group, content:delete books', () {

        FlutterDriver driver;

        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        test('XXX', () async {
           });
     });

  group('BookShare Test Group, content:delete libs', () {

        FlutterDriver driver;

        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        test('XXX', () async {
           });
     });
  
}
