import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

const TESTER_NAME   = "_bs_tester_1664";
const TESTER_PASSWD = "passWD123";

// https://medium.com/flutter-community/testing-flutter-ui-with-flutter-driver-c1583681e337


// XXX darg... fluuuuuttterrrrrrr
Future<bool> isPresent( FlutterDriver driver, SerializableFinder finder, [int timeout = 500]  ) async {
   try {
      // NOTE 200 was overly eager.  500 OK?
      await driver.waitFor(finder, timeout: Duration( milliseconds: timeout ) );
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

Future<bool> verifyOnHomePage( FlutterDriver driver ) async {
   print( "VOHP test" );
   expect( await isPresent( driver, find.byValueKey( 'myLibraryIcon' ), 5000), true );  // on top bar, but..
   expect( await isPresent( driver, find.byValueKey( 'homeHereIcon' )), true );   // landed here on bot bar
   
   // Default name of private lib, selected by default upon login.
   // This takes longer, once it shows up, fully loaded.
   expect( await isPresent( driver, find.byValueKey( 'My Books' )), true );  
   return true;
}

Future<bool> verifyEditLib( FlutterDriver driver, String libName, [String newName = ""] ) async {
   expect( await isPresent( driver, find.byValueKey( 'Selected: ' + libName ), 2000), true );
   expect( await isPresent( driver, find.text( 'Editing ' + libName + ' Library' )), true );
   expect( await isPresent( driver, find.text( 'Library name: ' )), true );
   expect( await isPresent( driver, find.text( 'Description:' )), true );

   if( newName == "" ) { expect( await isPresent( driver, find.text( libName )), true ); }
   else                { expect( await isPresent( driver, find.text( newName )), true ); }
   
   expect( await isPresent( driver, find.byValueKey( 'Choose Image' )), true );
   expect( await isPresent( driver, find.byValueKey( 'Accept' )), true );
   expect( await isPresent( driver, find.byValueKey( 'Delete' )), true );
   expect( await isPresent( driver, find.byValueKey( 'Cancel' )), true );
   
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
   if( known ) { expect( await verifyOnHomePage( driver ), true );  }
   else {
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

Future<bool> wait( FlutterDriver driver, int ms ) async {
   expect( await isPresent( driver, find.text( 'Forcing a timeout here' ), ms ), false );
   return true;
}

Future<bool> findBook( FlutterDriver driver, SerializableFinder theList, String theChoice ) async {
   // go to start
   await driver.scroll( theList, 2000.0, 0.0, Duration( milliseconds: 500 ));       

   // Scrolls before checks visible, so help it
   if( !(await isPresent( driver, find.byValueKey( theChoice ) ))) {
      await driver.scrollUntilVisible( theList, find.byValueKey( theChoice ), dxScroll: -200.0 );
   }
   
   return true;
}

Future<bool> deleteBook( FlutterDriver driver, SerializableFinder theList, SerializableFinder theLib, String theChoice, [bool cancel = false] ) async {
   SerializableFinder detailList = find.byValueKey('bookDetail');
   SerializableFinder delete  = find.byValueKey('Delete');
   SerializableFinder choice  = find.byValueKey( theChoice );

   expect( await isPresent( driver, theLib, 2000 ), true );
   await driver.tap( theLib );
   expect( await findBook( driver, theList, theChoice ), true );

   expect( await isPresent( driver, choice ), true );
   await driver.tap( choice );
   await driver.scrollUntilVisible( detailList, delete, dyScroll: -1000.0 );

   await driver.tap( delete );
   expect( await isPresent( driver, find.byValueKey( 'confirmDelete' )), true );
   expect( await isPresent( driver, find.byValueKey( 'cancelDelete' )), true );

   if( cancel == true ) {
      await driver.tap( find.byValueKey( 'cancelDelete' ));
      await driver.tap( find.byValueKey( 'Back' ));
   }
   else {
      await driver.tap( find.byValueKey( 'confirmDelete' ));
   }
   
   expect( await verifyOnHomePage( driver ), true );
   return true;
}


Future<bool> gotoAddBook( FlutterDriver driver ) async {
   SerializableFinder addBookIcon = find.byValueKey( 'addBookIcon' );
   SerializableFinder addBookHereIcon = find.byValueKey( 'addBookHereIcon' );

   expect( await isPresent( driver, addBookIcon ), true );
   expect( await isPresent( driver, addBookHereIcon ), false );

   await driver.tap( addBookIcon );

   expect( await isPresent( driver, addBookIcon ), false );
   expect( await isPresent( driver, addBookHereIcon ), true );

   return true;
}

Future<bool> gotoHome( FlutterDriver driver ) async {
   SerializableFinder homeIcon = find.byValueKey( 'homeIcon' );
   SerializableFinder homeHereIcon = find.byValueKey( 'homeHereIcon' );

   expect( await isPresent( driver, homeIcon ), true );
   expect( await isPresent( driver, homeHereIcon ), false );

   await driver.tap( homeIcon );

   expect( await isPresent( driver, homeIcon ), false );
   expect( await isPresent( driver, homeHereIcon ), true );

   return true;
}

// Enter this for multiple subs, so check first I'm not already here.
Future<bool> gotoMyLib( FlutterDriver driver, String sub ) async {
   SerializableFinder myLibraryIcon = find.byValueKey( 'myLibraryIcon' );
   SerializableFinder myLibraryHereIcon = find.byValueKey( 'myLibraryHereIcon' );
   SerializableFinder gridIcon  = find.byValueKey( 'gridIcon' );
   SerializableFinder listIcon  = find.byValueKey( 'listIcon' );
   SerializableFinder shareIcon = find.byValueKey( 'shareIcon' );
   SerializableFinder editIcon  = find.byValueKey( 'editIcon' );

   if( !( await isPresent( driver, myLibraryHereIcon ))) {
         expect( await isPresent( driver, myLibraryIcon ), true );
         expect( await isPresent( driver, myLibraryHereIcon ), false );
         await driver.tap( myLibraryIcon );
   }

   expect( await isPresent( driver, myLibraryIcon ), false );
   expect( await isPresent( driver, myLibraryHereIcon ), true );

   if( sub == "grid" ) {
      expect( await isPresent( driver, gridIcon ), true );
      await driver.tap( gridIcon );
   }
   else if( sub == "list" ) {
      expect( await isPresent( driver, listIcon ), true );
      await driver.tap( listIcon );
   }
   else if( sub == "share" ) {
      expect( await isPresent( driver, shareIcon ), true );
      await driver.tap( shareIcon );
   }
   else if( sub == "edit" ) {
      expect( await isPresent( driver, editIcon ), true );
      await driver.tap( editIcon );
   }
   else { return false; }
      
   return true;
}


Future<bool> refineAdd( FlutterDriver driver, titleKey, authorKey, bookChoice, closeOut, [bool checkScan = true] ) async {
   SerializableFinder refineSearch = find.byValueKey( 'Refine search' );

   print( "RefineAdd: " + titleKey + " " + authorKey );
   
   // If got here from hitting refine search in a list of books, scan button is not present.
   // Hmmmm.... same with home...
   if( checkScan ) {
      expect( await isPresent( driver, find.text( 'Scan' ), 5000 ), true );  // if coming from addbook, this can take a while.
      expect( await isPresent( driver, refineSearch ), true );
      
      await driver.tap( refineSearch );
   }

   // verify
   SerializableFinder title  = find.byValueKey( 'Keyword from title' );   
   SerializableFinder author = find.byValueKey( 'Author\'s last name' );   
   expect( await isPresent( driver, title ), true );
   expect( await isPresent( driver, author ), true );

   // search 
   if( titleKey != "" ) { await enterText( driver, title, titleKey );  }
   if( authorKey != "") { await enterText( driver, author, authorKey );  }
   SerializableFinder search  = find.byValueKey( 'Search' );      
   expect( await isPresent( driver, search ), true );
   await driver.tap( search );

   // choose a result
   SerializableFinder theList   = find.byValueKey('searchedBooks');
   SerializableFinder theChoice = find.byValueKey('bookChunk${bookChoice}');
   await driver.scrollUntilVisible( theList, theChoice, dxScroll: -200.0 );
   await driver.tap( theChoice );

   // Add it and go...
   SerializableFinder scanMore = find.byValueKey('Add this,\n scan more');      
   SerializableFinder goHome   = find.byValueKey('Add this,\n go to MyLib');      
   expect( await isPresent( driver, scanMore ), true );      
   expect( await isPresent( driver, goHome ), true );      
   expect( await isPresent( driver, refineSearch ), true );      
   if( closeOut == "more" )        { await driver.tap( scanMore ); }
   else if( closeOut == "home" )   { await driver.tap( goHome ); }
   else if( closeOut == "refine" ) { await driver.tap( refineSearch ); }
   else { return false; }

   return true;
}

