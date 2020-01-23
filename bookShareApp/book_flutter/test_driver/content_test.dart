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
   expect( await findBook( driver, theList, 'Dragon Boogers' ), true );
   expect( await findBook( driver, theList, 'Warship' ), true );
   expect( await findBook( driver, theList, 'Money Magic Tricks' ), true );

   SerializableFinder theChoice = find.byValueKey('Melissa Musick Nussbaum');
   await driver.scroll( theList, 1000.0, 0.0, Duration( milliseconds: 500 ));
   await driver.scrollUntilVisible( theList, theChoice, dxScroll: -200.0 );

   return true;
}

Future<bool> checkKeanna( FlutterDriver driver ) async {
   await driver.tap( find.byValueKey( 'image: Keanna' ) );
   expect( await isPresent( driver, find.text( 'By: Namester Composition Notebooks' ), 2000), true);
   expect( await isPresent( driver, find.text( 'Keanna' )), true);
   expect( await isPresent( driver, find.byValueKey( 'Back' )), true);
   await driver.tap( find.byValueKey( 'Back' ));
   return true;
}

Future<bool> addLibrary( FlutterDriver driver, String libName, String coverName ) async {
                         
   SerializableFinder create = find.text('< CREATE >');
   SerializableFinder accept = find.byValueKey( 'Accept' );
   SerializableFinder cancel = find.byValueKey( 'Cancel' );
   await driver.tap( create ); 
   expect( await verifyEditLib( driver, "new" ), true );
   await enterText( driver, find.byValueKey( 'input: new' ), libName );
   expect( await verifyEditLib( driver, "new", libName ), true );
   
   await driver.tap( find.byValueKey( 'Choose Image' ) );
   expect( await isPresent( driver, find.text( 'Select image source:' )), true );
   expect( await isPresent( driver, find.byValueKey( 'galleryIcon' )), true );
   expect( await isPresent( driver, find.byValueKey( 'cameraIcon' )), true );
   expect( await isPresent( driver, find.byValueKey( 'coversIcon' )), true );
   
   await driver.tap( find.byValueKey( 'coversIcon' ));
   expect( await isPresent( driver, find.byValueKey( 'image: Dragon Boogers' )), true);
   expect( await isPresent( driver, find.byValueKey( 'image: Keanna' )), true);
   expect( await isPresent( driver, find.byValueKey( 'image: Rain, Snow, Sleet, and Hail' )), true);
   expect( await isPresent( driver, find.byValueKey( 'image: Elementary Functional Analysis' )), true);
   
   // choose cover
   await driver.tap( find.byValueKey( coverName ));            
   expect( await isPresent( driver, accept), true);
   expect( await isPresent( driver, cancel), true);
   
   // crop(ish) & save
   expect( await isPresent( driver, cancel), true);
   await driver.tap( find.byValueKey( 'imageCrop' ));
   await driver.tap( accept );
   await driver.tap( accept );
   expect( await verifyOnHomePage( driver ), true );              
   await gotoMyLib( driver, "edit" );

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
  
  group('BookShare Test Group, content:myLibPage', () {

        FlutterDriver driver;

        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        test('MyLibPage, grid', () async {
              await gotoMyLib( driver, "grid" );
              expect( await isPresent( driver, find.byValueKey( 'image: Sandia Mountain Hiking Guide' )), true);
              expect( await isPresent( driver, find.text( 'Sandia Mountain Hiking Guide' )), false);
              expect( await isPresent( driver, find.text( 'By: Bob Longe' )), false);

              expect( await isPresent( driver, find.byValueKey( 'image: Dragon Boogers' )), true);
              expect( await isPresent( driver, find.byValueKey( 'image: Keanna' )), true);
              expect( await isPresent( driver, find.byValueKey( 'image: Rain, Snow, Sleet, and Hail' )), true);
              expect( await isPresent( driver, find.byValueKey( 'image: Elementary Functional Analysis' )), true);

              // check access to book detail
              expect( await checkKeanna( driver ), true );
           });
        
        test('MyLibPage, list', () async {
              await gotoMyLib( driver, "list" );
              expect( await isPresent( driver, find.text( 'By: Bob Longe' )), true);

              expect( await isPresent( driver, find.byValueKey( 'image: Sandia Mountain Hiking Guide' )), true);
              expect( await isPresent( driver, find.text( 'Sandia Mountain Hiking Guide' )), true);
              expect( await isPresent( driver, find.text( 'By: Michael Elliott Coltrin' )), true);
              
              expect( await isPresent( driver, find.byValueKey( 'image: Meet Hunca Munca' )), true);
              expect( await isPresent( driver, find.text( 'Meet Hunca Munca' )), true);
              expect( await isPresent( driver, find.text( 'By: Beatrix Potter' )), true);

              // check access to book detail
              expect( await checkKeanna( driver ), true );
           });


        test('MyLibPage, share', () async {
              await gotoMyLib( driver, "share" );
              String shareText = "Share books from your private library on this page, once you've created or joined another library.";
              expect( await isPresent( driver, find.text( shareText )), true);              
           });

        test('MyLibPage, edit', () async {
              await gotoMyLib( driver, "edit" );
              
              // Basic setup
              SerializableFinder create = find.text('< CREATE >');
              SerializableFinder cancel = find.byValueKey( 'Cancel' );
              SerializableFinder myLib  = find.byValueKey( 'My Books' ); 
              expect( await isPresent( driver, create), true);
              expect( await isPresent( driver, find.text( 'Select a Library to edit...')), true);
              expect( await isPresent( driver, myLib), true);
              await driver.tap( myLib );
              expect( await verifyEditLib( driver, "My Books" ), true );

              // Change name, but cancel
              SerializableFinder libName = find.byValueKey( 'input: My Books' );
              await enterText( driver, libName, "BootCamp" );
              expect( await verifyEditLib( driver, "My Books", "BootCamp" ), true );
              await driver.tap( cancel );
              expect( await verifyEditLib( driver, "My Books" ), true );

              // Create lib
              expect( await addLibrary( driver, "Stormy", "image: Warship" ), true );
              expect( await addLibrary( driver, "Dreamy", "image: Keanna" ), true );
              
           });
        
        test('MyLibPage, share', () async {
              await gotoMyLib( driver, "share" );
              SerializableFinder dropLib = find.byValueKey('dropLib');
              SerializableFinder dreamy = find.byValueKey('Dreamy');
              SerializableFinder stormy = find.byValueKey('Stormy');
              SerializableFinder theList = find.byValueKey('bookShares');
              SerializableFinder theChoice = find.byValueKey('check: ' + 'Meet Hunca Munca');

              // STORMY
              // Can't check false version - both appear to be present.
              expect( await isPresent( driver, dreamy ), true );
              await driver.tap( dropLib );
              await driver.tap( stormy );
              expect( await isPresent( driver, stormy, 2000 ), true );


              expect( await isPresent( driver, find.text( "Book shares for: " )), true );
              expect( await isPresent( driver, find.text( "By: Sebastian Junger" )), true );
              expect( await isPresent( driver, find.text( "Money Magic Tricks" )), true );
              expect( await isPresent( driver, find.text( "By: Bob Longe" )), true );
              expect( await isPresent( driver, find.text( "Dragon Boogers" )), true );

              await driver.tap( find.byValueKey( 'check: Money Magic Tricks' ) );
              await wait(driver, 500);
              await driver.tap( find.byValueKey( 'check: Dragon Boogers' ) );
              await wait(driver, 500);
              await driver.scrollUntilVisible( theList, theChoice, dyScroll: -200.0 );
              await driver.tap( theChoice );
              await wait(driver, 500);

              // DREAMY
              await driver.tap( dropLib );
              await driver.tap( dreamy );
              expect( await isPresent( driver, dreamy, 2000 ), true );
              
              expect( await isPresent( driver, find.text( "Book shares for: " )), true );
              expect( await isPresent( driver, find.text( "By: Sebastian Junger" )), true );
              expect( await isPresent( driver, find.text( "Money Magic Tricks" )), true );
              expect( await isPresent( driver, find.text( "By: Bob Longe" )), true );
              expect( await isPresent( driver, find.text( "Dragon Boogers" )), true );

              await driver.tap( find.byValueKey( 'check: shareAll' ) );
              await wait(driver, 3000);
                 
              await driver.tap( find.byValueKey( 'check: Money Magic Tricks' ) );
              await wait(driver, 500);
              await driver.tap( find.byValueKey( 'check: Dragon Boogers' ) );
              await wait(driver, 500);
              await driver.scrollUntilVisible( theList, theChoice, dyScroll: -200.0 );
              await driver.tap( theChoice );
              await wait(driver, 500);
           });
     });

  group('BookShare Test Group, content:homePage', () {

        FlutterDriver driver;
        SerializableFinder myLib   = find.byValueKey('My Books');
        SerializableFinder dreamy  = find.byValueKey('Dreamy');
        SerializableFinder stormy  = find.byValueKey('Stormy');

        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        test('HomePage: Check Libs', () async {

              // Basics
              if( !( await isPresent( driver, find.byValueKey( 'homeHereIcon' ))) ) { await gotoHome( driver ); }
              expect( await isPresent( driver, myLib ), true );
              expect( await isPresent( driver, stormy ), true );
              expect( await isPresent( driver, dreamy ), true );

              expect( await isPresent( driver, find.text( 'My Books' )), true );
              expect( await isPresent( driver, find.text( '1 member' )), true );
              expect( await isPresent( driver, find.text( '10 books' )), true );
           });

        test('HomePage: Check book sharing', () async {
              if( !( await isPresent( driver, find.byValueKey( 'homeHereIcon' ))) ) { await gotoHome( driver ); }
              expect( await isPresent( driver, dreamy ), true );

              SerializableFinder theList  = find.byValueKey('searchedBooks');

              // DREAMY
              await driver.tap( dreamy ); 
              expect( await isPresent( driver, myLib ), true );
              expect( await isPresent( driver, stormy, 2000 ), true );
              expect( await isPresent( driver, dreamy ), true );
              
              expect( await isPresent( driver, find.text( 'Dreamy' )), true );
              expect( await isPresent( driver, find.text( '1 member' )), true );
              expect( await isPresent( driver, find.text( '7 books' )), true );

              // find 7
              expect( await findBook( driver, theList, 'The Perfect Storm: A True Story of Men Against the Sea' ), true );
              expect( await findBook( driver, theList, 'Sandia Mountain Hiking Guide' ), true );
              expect( await findBook( driver, theList, 'Elementary Functional Analysis' ), true );
              expect( await findBook( driver, theList, 'Warship' ), true );
              expect( await findBook( driver, theList, 'Keanna' ), true );
              expect( await findBook( driver, theList, 'I Will Lie Down This Night' ), true );
              expect( await findBook( driver, theList, 'Rain, Snow, Sleet, and Hail' ), true );


              // STORMY
              await driver.tap( stormy ); 
              expect( await isPresent( driver, myLib ), true );
              expect( await isPresent( driver, stormy, 2000 ), true );
              expect( await isPresent( driver, dreamy ), true );
              
              expect( await isPresent( driver, find.text( 'Stormy' )), true );
              expect( await isPresent( driver, find.text( '1 member' )), true );
              expect( await isPresent( driver, find.text( '3 books' )), true );

              // find 3
              expect( await findBook( driver, theList, 'Meet Hunca Munca' ), true );
              expect( await findBook( driver, theList, 'Money Magic Tricks' ), true );
              expect( await findBook( driver, theList, 'Dragon Boogers' ), true );
              
           });
     });
  */

  group('BookShare Test Group, content:delete books', () {

        FlutterDriver driver;

        setUpAll(() async {
              driver = await FlutterDriver.connect();
           });
        
        tearDownAll(() async {
              if (driver != null) { driver.close(); }
           });

        test('Cleanup books', () async {
              if( !( await isPresent( driver, find.byValueKey( 'homeHereIcon' ))) ) { await gotoHome( driver ); }
              SerializableFinder theList    = find.byValueKey('searchedBooks');
              SerializableFinder detailList = find.byValueKey('bookDetail');

              SerializableFinder myLib   = find.byValueKey('My Books');
              SerializableFinder dreamy  = find.byValueKey('Dreamy');
              SerializableFinder stormy  = find.byValueKey('Stormy');
              SerializableFinder delete  = find.byValueKey('Delete');

              await driver.tap( myLib );

              // DREAMY
              // Check 1st.. cancel delete, then delete
              /*
              await deleteBook( driver, theList, dreamy, 'The Perfect Storm: A True Story of Men Against the Sea', true );
              expect( await isPresent( driver, find.text( "7 books" )), true );
              await driver.tap( myLib );
              expect( await isPresent( driver, find.text( "10 books" )), true );
              await driver.tap( stormy );
              expect( await isPresent( driver, find.text( "3 books" )), true );

              await deleteBook( driver, theList, dreamy, 'The Perfect Storm: A True Story of Men Against the Sea');
              expect( await isPresent( driver, find.text( "6 books" ), 2000 ), true );
              await driver.tap( myLib );
              expect( await isPresent( driver, find.text( "9 books" )), true );
              await driver.tap( stormy );
              expect( await isPresent( driver, find.text( "3 books" )), true );

              await deleteBook( driver, theList, dreamy, 'Sandia Mountain Hiking Guide' );
              await deleteBook( driver, theList, dreamy, 'Elementary Functional Analysis' );
              await deleteBook( driver, theList, dreamy, 'Warship' );
              await deleteBook( driver, theList, dreamy, 'Keanna' );
              await deleteBook( driver, theList, dreamy, 'I Will Lie Down This Night' );
              await deleteBook( driver, theList, dreamy, 'Rain, Snow, Sleet, and Hail' );
              expect( await isPresent( driver, find.text( "0 books" ), 2000 ), true );
              await driver.tap( myLib );
              expect( await isPresent( driver, find.text( "3 books" )), true );
              await driver.tap( stormy );
              expect( await isPresent( driver, find.text( "3 books" )), true );
              */
              
              await deleteBook( driver, theList, stormy, 'Meet Hunca Munca' );
              await deleteBook( driver, theList, stormy, 'Money Magic Tricks' );
              await deleteBook( driver, theList, stormy, 'Dragon Boogers' );
              expect( await isPresent( driver, find.text( "0 books" ), 2000 ), true );
              await driver.tap( myLib );
              expect( await isPresent( driver, find.text( "0 books" )), true );
              await driver.tap( dreamy );
              expect( await isPresent( driver, find.text( "0 books" )), true );

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
