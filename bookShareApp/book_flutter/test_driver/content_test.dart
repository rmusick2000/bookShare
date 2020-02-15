import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import '../test_driver/utils.dart';

const bool CLEANUP = false;
//bool CLEANUP = true;

// ScrollUntil scrolls before looking. 
Future<bool> verifyHomeBatch1( FlutterDriver driver ) async {
   expect( await verifyOnHomePage( driver ), true );
   SerializableFinder theList   = find.byValueKey('searchedBooks');
   
   // Find all 4 books that we just added
   expect( await findBook( driver, theList, 'Dragon Boogers' ), true );
   expect( await findBook( driver, theList, 'Warship' ), true );
   expect( await findBook( driver, theList, 'Money Magic Tricks' ), true );
   expect( await findBook( driver, theList, 'I Will Lie Down This Night' ), true );
   
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

   // Verify new lib shows up on homepage
   expect( await verifyOnHomePage( driver ), true );
   expect( await isPresent( driver, find.byValueKey( libName ), 2000 ), true );
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
   
   if( CLEANUP ) {
      
      group('BookShare Test Group, content:cleanup', () {
            
            FlutterDriver driver;
            
            setUpAll(() async {
                  driver = await FlutterDriver.connect();
               });
            
            tearDownAll(() async {
                  if (driver != null) { driver.close(); }
               });
            
            
            test('Cleanup books', () async {
                  bool atHome = await isPresent( driver, find.byValueKey( 'homeHereIcon' )); 
                  if( !atHome ) { await gotoHome( driver ); }
                  SerializableFinder theList    = find.byValueKey('searchedBooks');
                  SerializableFinder myLib   = find.byValueKey('My Books');
                  
                  expect( await deleteFirstBook( driver, theList, myLib ), true );
                  expect( await deleteFirstBook( driver, theList, myLib ), true );
                  expect( await deleteFirstBook( driver, theList, myLib ), true );
                  expect( await deleteFirstBook( driver, theList, myLib ), true );
                  expect( await deleteFirstBook( driver, theList, myLib ), true );
                  expect( await deleteFirstBook( driver, theList, myLib ), true );
                  expect( await deleteFirstBook( driver, theList, myLib ), true );
                  expect( await deleteFirstBook( driver, theList, myLib ), true );
                  expect( await deleteFirstBook( driver, theList, myLib ), true );
                  expect( await deleteFirstBook( driver, theList, myLib ), true );
                  
                  expect( await isPresent( driver, find.text( "0 books" ), 2000 ), true );
                  
               },
               timeout: Timeout( Duration( seconds:300 )) );
            
            test('Content: delete libs', () async {
                  await gotoMyLib( driver, "edit" );
                  SerializableFinder dreamy  = find.byValueKey('Dreamy');
                  SerializableFinder stormy  = find.byValueKey('Stormy');
                  SerializableFinder delete  = find.byValueKey('Delete');
                  
                  // STORMY.. cancel delete first, then delete
                  await driver.tap( stormy );
                  await driver.tap( delete );
                  expect( await isPresent( driver, find.text( 'Confirm delete' )), true );
                  await driver.tap( find.text( 'Continue' ));
                  expect( await isPresent( driver, find.text( 'Select a Library to edit...' ), 2000), true );
                  
                  // DREAMY
                  await driver.tap( dreamy );
                  expect( await isPresent( driver, find.text( 'Editing Dreamy Library' )), true );
                  await driver.tap( delete );
                  expect( await isPresent( driver, find.text( 'Confirm delete' )), true );
                  await driver.tap( find.text( 'Continue' ));
                  expect( await isPresent( driver, find.text( 'Select a Library to edit...' )), true );
                  
                  await gotoHome( driver );
                  expect( await isPresent( driver, stormy, 2000 ), false );
                  expect( await isPresent( driver, dreamy ), false );
               });
            
         });
      
   }
  else  // NO CLEANUP
  {
     group('BookShare Test Group, content:add books', () {
           
           FlutterDriver driver;
           
           setUpAll(() async {
                 driver = await FlutterDriver.connect();
              });
           
           tearDownAll(() async {
                 if (driver != null) { driver.close(); }
              });
           
           test( 'check functionality', () async {
                 SerializableFinder refineSearch = find.byValueKey( 'Refine search' );
                 SerializableFinder title  = find.byValueKey( 'Keyword from title' );   
                 SerializableFinder author = find.byValueKey( 'Author\'s last name' );   
                 SerializableFinder search  = find.byValueKey( 'Search' );      
                 
                 await gotoAddBook( driver );
                 expect( await isPresent( driver, find.text( 'Scan' ), 3000 ), true );  
                 expect( await isPresent( driver, refineSearch ), true );
                 
                 await refineAdd( driver, "Boogers", "", 4, "more" );     // scroll to dragon, land in addbook
                 expect( await isPresent( driver, find.text( 'Scan' ), 3000 ), true );  
                 expect( await isPresent( driver, refineSearch ), true );
                 
                 await refineAdd( driver, "warship", "", 3, "refine" );     // dont add, land in addbook:refine
                 expect( await isPresent( driver, title ), true );
                 expect( await isPresent( driver, author ), true );
                 expect( await isPresent( driver, search ), true );
                 await gotoHome( driver );
                 await gotoAddBook( driver );
                 
                 await refineAdd( driver, "Magic", "", 1, "home" );         // add first, land in homepage
                 expect( await verifyOnHomePage( driver ), true );
                 
                 // Cleanup
                 SerializableFinder theList = find.byValueKey('searchedBooks');
                 SerializableFinder theLib  = find.byValueKey('My Books');
                 expect( await deleteFirstBook( driver, theList, theLib ), true );
                 expect( await deleteFirstBook( driver, theList, theLib ), true );
                 
              },
              timeout: Timeout( Duration( seconds:300 )) );

           // DARG!  Default timeout on tests is 30s!  Could be a much clearer error message.
           test('Add book w/refine search', () async {
                 await gotoAddBook( driver );
                 
                 await refineAdd( driver, "Dragon Boogers", "", 0, "more" );
                 await refineAdd( driver, "Warship", "Jordan, Dent", 0, "more" );    
                 await refineAdd( driver, "I will lie down", "Melissa Musick", 0, "more" ); 
                 await refineAdd( driver, "Money Magic Tricks", "", 0, "home" );         
                 
                 expect( await verifyHomeBatch1( driver ), true );
                 await gotoAddBook( driver );
                 
                 await refineAdd( driver, "Elementary Functional Analysis", "", 0, "more" );    
                 await refineAdd( driver, "Keanna", "", 0, "more" );    
                 await refineAdd( driver, "Rain, Snow, Sleet, and Hail", "", 0, "more" );    
                 await refineAdd( driver, "The Perfect Storm: A True Story of Men Against the Sea", "", 0, "more" );    
                 await refineAdd( driver, "Sandia Mountain Hiking Guide", "", 0, "more" );    
                 await refineAdd( driver, "Meet hunca munca", "", 0, "home" );    
              },
              timeout: Timeout( Duration( seconds:300 )) );
           
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
                 
                 bool alreadyHome = await isPresent( driver, find.byValueKey( 'homeHereIcon' ), 3000 );
                 if( !alreadyHome ) { await gotoHome( driver ); }
                 SerializableFinder theList  = find.byValueKey('searchedBooks');
                 SerializableFinder back     = find.byValueKey('Back');
                 
                 print( "Meet Hunca Munca" );
                 SerializableFinder theChoice = find.byValueKey('Meet Hunca Munca');
                 expect( await findBook( driver, theList, theChoice ), true );
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
                 expect( await findBook( driver, theList, theChoice ), true );
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
                 
              },
              timeout: Timeout( Duration( seconds:300 )) );
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
                 SerializableFinder theList  = find.byValueKey('gridView');                 

                 expect( await findBook( driver, theList, find.byValueKey( 'image: Sandia Mountain Hiking Guide' ), true), true );
                 expect( await isPresent( driver, find.text( 'Sandia Mountain Hiking Guide' )), false);
                 expect( await isPresent( driver, find.text( 'By: Bob Longe' )), false);

                 expect( await findBook( driver, theList, find.byValueKey( 'image: Dragon Boogers' ), true), true );
                 expect( await findBook( driver, theList, find.byValueKey( 'image: Rain, Snow, Sleet, and Hail' ), true), true );
                 expect( await findBook( driver, theList, find.byValueKey( 'image: Elementary Functional Analysis' ), true), true );
                 expect( await findBook( driver, theList, find.byValueKey( 'image: Keanna' ), true), true );

                 // check access to book detail
                 expect( await checkKeanna( driver ), true );
              });
           
           test('MyLibPage, list', () async {
                 await gotoMyLib( driver, "list" );
                 expect( await isPresent( driver, find.text( 'By: Bob Longe' )), true);
                 
                 expect( await isPresent( driver, find.byValueKey( 'image: Sandia Mountain Hiking Guide' )), true);
                 expect( await isPresent( driver, find.text( 'Sandia Mountain Hiking Guide' )), true);

                 // Coltrin shows up multiple ways
                 bool coltrin = await isPresent( driver, find.text( 'By: Michael Elliott Coltrin' ));
                 if( !coltrin ) { coltrin = await isPresent( driver, find.text( 'By: Mike Coltrin' )); }
                 expect( coltrin, true );
                 
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
                 
              },
              timeout: Timeout( Duration( seconds:300 )) );
           
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
                 
                 expect( await findBook( driver, theList, find.text( "Book shares for: " ), true), true );
                 expect( await findBook( driver, theList, find.text( "By: Sebastian Junger" ), true), true );
                 expect( await findBook( driver, theList, find.text( "By: Bob Longe" ), true), true );
                 
                 expect( await findBook( driver, theList, find.text( "Money Magic Tricks" ), true), true );
                 await driver.tap( find.byValueKey( 'check: Money Magic Tricks' ) );
                 await wait(driver, 500);
                 
                 expect( await findBook( driver, theList, find.text( "Dragon Boogers" ), true), true );
                 await driver.tap( find.byValueKey( 'check: Dragon Boogers' ) );
                 await wait(driver, 500);
                 
                 expect( await findBook( driver, theList, theChoice, true), true );
                 await driver.tap( theChoice );
                 await wait(driver, 500);
                 
                 // DREAMY
                 await driver.tap( dropLib );
                 await driver.tap( dreamy );
                 expect( await isPresent( driver, dreamy, 2000 ), true );
                 
                 expect( await findBook( driver, theList, find.text( "Book shares for: " ), true), true );
                 expect( await findBook( driver, theList, find.text( "By: Sebastian Junger" ), true), true );
                 expect( await findBook( driver, theList, find.text( "By: Bob Longe" ), true), true );
                 
                 expect( await findBook( driver, theList, find.text( 'Book shares for: ' ), true), true );
                 await driver.tap( find.byValueKey( 'check: shareAll' ) );
                 await wait(driver, 3000);
                 
                 expect( await findBook( driver, theList, find.text( "Money Magic Tricks" ), true), true );
                 await driver.tap( find.byValueKey( 'check: Money Magic Tricks' ) );
                 await wait(driver, 500);
                 
                 expect( await findBook( driver, theList, find.text( "Dragon Boogers" ), true), true );
                 await driver.tap( find.byValueKey( 'check: Dragon Boogers' ) );
                 await wait(driver, 500);
                 
                 expect( await findBook( driver, theList, theChoice, true ), true );
                 await driver.tap( theChoice );
                 await wait(driver, 500);
              },
              timeout: Timeout( Duration( seconds:300 )) );
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
                 
              },
              timeout: Timeout( Duration( seconds:300 )) );
        });

     group('BookShare Test Group, content:delete books', () {
           
           FlutterDriver driver;
           
           setUpAll(() async {
                 driver = await FlutterDriver.connect();
              });
           
           tearDownAll(() async {
                 if (driver != null) { driver.close(); }
              });
           
           test('Cleanup books', () async {
                 bool atHome = await isPresent( driver, find.byValueKey( 'homeHereIcon' )); 
                 if( !atHome ) { await gotoHome( driver ); }
                 SerializableFinder theList    = find.byValueKey('searchedBooks');
                 
                 SerializableFinder myLib   = find.byValueKey('My Books');
                 SerializableFinder dreamy  = find.byValueKey('Dreamy');
                 SerializableFinder stormy  = find.byValueKey('Stormy');
                 
                 await driver.tap( myLib );
                 
                 // DREAMY
                 // Check 1st.. cancel delete, then delete
                 await deleteBook( driver, theList, dreamy, 'The Perfect Storm: A True Story of Men Against the Sea', true );
                 expect( await isPresent( driver, find.text( "7 books" )), true );
                 await driver.tap( myLib );
                 expect( await isPresent( driver, find.text( "10 books" ), 2000 ), true );
                 await driver.tap( stormy );
                 expect( await isPresent( driver, find.text( "3 books" ), 2000 ), true );
                 
                 await deleteBook( driver, theList, dreamy, 'The Perfect Storm: A True Story of Men Against the Sea');
                 expect( await isPresent( driver, find.text( "6 books" ), 2000 ), true );
                 await driver.tap( myLib );
                 expect( await isPresent( driver, find.text( "9 books" ), 2000), true );
                 await driver.tap( stormy );
                 expect( await isPresent( driver, find.text( "3 books" ), 2000), true );
                 
                 await deleteBook( driver, theList, dreamy, 'Sandia Mountain Hiking Guide' );
                 await deleteBook( driver, theList, dreamy, 'Elementary Functional Analysis' );
                 await deleteBook( driver, theList, dreamy, 'Warship' );
                 await deleteBook( driver, theList, dreamy, 'Keanna' );
                 await deleteBook( driver, theList, dreamy, 'I Will Lie Down This Night' );
                 await deleteBook( driver, theList, dreamy, 'Rain, Snow, Sleet, and Hail' );
                 expect( await isPresent( driver, find.text( "0 books" ), 2000 ), true );
                 await driver.tap( myLib );
                 expect( await isPresent( driver, find.text( "3 books" ), 2000 ), true );
                 await driver.tap( stormy );
                 expect( await isPresent( driver, find.text( "3 books" ), 2000 ), true );

                 // STORMY
                 await deleteBook( driver, theList, stormy, 'Meet Hunca Munca' );
                 await deleteBook( driver, theList, stormy, 'Money Magic Tricks' );
                 await deleteBook( driver, theList, stormy, 'Dragon Boogers' );
                 expect( await isPresent( driver, find.text( "0 books" ), 2000 ), true );
                 await driver.tap( myLib );
                 expect( await isPresent( driver, find.text( "0 books" ), 2000 ), true );
                 await driver.tap( dreamy );
                 expect( await isPresent( driver, find.text( "0 books" ), 2000 ), true );
                 
              },
              timeout: Timeout( Duration( seconds:300 )) );
        });
     
     group('BookShare Test Group, content:delete libs', () {
           
           FlutterDriver driver;
           
           setUpAll(() async {
                 driver = await FlutterDriver.connect();
              });
           
           tearDownAll(() async {
                 if (driver != null) { driver.close(); }
              });
           
           test('Content: delete libs', () async {
                 await gotoMyLib( driver, "edit" );
                 SerializableFinder dreamy  = find.byValueKey('Dreamy');
                 SerializableFinder stormy  = find.byValueKey('Stormy');
                 SerializableFinder delete  = find.byValueKey('Delete');
                 
                 // STORMY.. cancel delete first, then delete
                 await driver.tap( stormy );
                 expect( await isPresent( driver, find.text( 'Editing Stormy Library' )), true );
                 await driver.tap( delete );
                 expect( await isPresent( driver, find.text( 'Confirm delete' )), true );
                 await driver.tap( find.text( 'Cancel' ));
                 expect( await isPresent( driver, find.text( 'Editing Stormy Library' )), true );
                 await driver.tap( delete );
                 expect( await isPresent( driver, find.text( 'Confirm delete' )), true );
                 await driver.tap( find.text( 'Continue' ));
                 expect( await isPresent( driver, find.text( 'Select a Library to edit...' ), 2000), true );
                 
                 // DREAMY
                 await driver.tap( dreamy );
                 expect( await isPresent( driver, find.text( 'Editing Dreamy Library' )), true );
                 await driver.tap( delete );
                 expect( await isPresent( driver, find.text( 'Confirm delete' )), true );
                 await driver.tap( find.text( 'Continue' ));
                 expect( await isPresent( driver, find.text( 'Select a Library to edit...' )), true );
                 
                 await gotoHome( driver );
                 expect( await isPresent( driver, stormy, 2000 ), false );
                 expect( await isPresent( driver, dreamy ), false );
              });
        });
  }
}
