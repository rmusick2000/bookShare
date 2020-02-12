import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';
import 'package:http/http.dart' as http;

import 'package:bookShare/utils.dart';

import 'package:bookShare/screens/launch_page.dart';

import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/models/libraries.dart';
import 'package:bookShare/models/books.dart';
import 'package:bookShare/models/ownerships.dart';


logout( context, container, appState ) {
   final wrapper = container.onPressWrapper((){
         Cognito.signOut();
         
         // Rebuilding page below, don't need to setState (which isn't available here). 
         appState.usernameController.clear();
         appState.passwordController.clear();
         appState.attributeController.clear();
         appState.confirmationCodeController.clear();
         Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => BSLaunchPage()),
            ModalRoute.withName("BSSplashPage")
            );
      });
   wrapper();
}      


bool checkReauth( context, container ) {
   final appState  = container.state;
   print( "" );
   print( "" );
   print( "" );
   print (" !!! !!! !!!" );
   print (" !!! !!!" );
   print (" !!!" );
   print( "Refreshing tokens.." );
   print (" !!!" );
   print (" !!! !!!" );
   print (" !!! !!! !!!" );
   print( "" );
   print( "" );
   print( "" );
   showToast( context, "Cloud tokens expired, reauthorizing.." );
   
   appState.authRetryCount += 1; 
   if( appState.authRetryCount > 100 ) {
      print( "Too many reauthorizations, please sign in again" );
      logout( context, container, appState );
      showToast( context, "Reauthorizing failed - your cloud authorization has expired.  Please re-login." ); 
      return false;
   }
   else { return true; }
}


Future<http.Response> postIt( String shortName, postData, container ) async {
   print( shortName );
   final appState  = container.state;

   final gatewayURL = appState.apiBasePath + "/find"; 
   
   final response =
      await http.post(
         gatewayURL,
         headers: {HttpHeaders.authorizationHeader: appState.idToken},
         body: postData
         );

   return response;
}


// If failure is authorization, we can reauthorize to fix it, usually
Future<bool> checkFailure( response, shortName, context, container ) async {
   bool retval = false;
   if (response.statusCode == 401 ) {  
      if( checkReauth( context, container ) ) {
         await container.getAuthTokens( true );
         retval = true;
      }
   }
   else {
      print( "RESPONSE: " + response.statusCode.toString() + " " + json.decode(utf8.decode(response.bodyBytes)).toString());
      throw Exception( shortName + ': AWS data failed to load.');
   }

   return retval;
}


Future<List<Library>> fetchLibraries( context, container, postData ) async {
   String shortName = "fetchLibrary";
   final response = await postIt( shortName, postData, container );
   
   if (response.statusCode == 201) {
      // print( "JSON RESPONSE BODY: " + response.body.toString() );         
      Iterable l = json.decode(utf8.decode(response.bodyBytes));
      List<Library> libs = l.map((sketch)=> Library.fromJson(sketch)).toList();
      return libs;
   } else {
      bool didReauth = await checkFailure( response, shortName, context, container );
      if( didReauth ) { return await fetchLibraries( context, container, postData ); }
   }
}

Future<List<Book>> fetchBooks( context, container, postData ) async {
   String shortName = "fetchBook";
   final response = await postIt( shortName, postData, container );
   
   if (response.statusCode == 201) {
      Iterable l = json.decode(utf8.decode(response.bodyBytes));
      List<Book> books = l.map((sketch)=> Book.fromJson(sketch)).toList();
      return books;
   } else {
      bool didReauth = await checkFailure( response, shortName, context, container );
      if( didReauth ) { return await fetchBooks( context, container, postData ); }
   }
}

Future<Map<String,Set>> fetchOwnerships( context, container, postData ) async {
   String shortName = "fetchOwnerships";
   final response = await postIt( shortName, postData, container );
   
   if (response.statusCode == 201) {
      print( response.body.toString() );         
      final o = json.decode(utf8.decode(response.bodyBytes));
      final ownership = Ownership.fromJson(o);
      return ownership.shares;
   } else {
      bool didReauth = await checkFailure( response, shortName, context, container );
      if( didReauth ) { return await fetchOwnerships( context, container, postData ); }
   }
}


Future<bool> initOwnership( context, container, postData ) async {
   String shortName = "initOwnership";
   final response = await postIt( shortName, postData, container );
   
   if (response.statusCode == 201) {
      print( "JSON RESPONSE BODY: " + response.body.toString() );         
      return true;
   } else {
      bool didReauth = await checkFailure( response, shortName, context, container );
      if( didReauth ) { return await initOwnership( context, container, postData ); }
   }
}

Future<bool> putBook( context, container, postData ) async {
   String shortName = "putBook";
   final response = await postIt( shortName, postData, container );
   
   if (response.statusCode == 201) {
      print( response.body.toString() );         
      return true;
   } else {
      bool didReauth = await checkFailure( response, shortName, context, container );
      if( didReauth ) { return await putBook( context, container, postData ); }
   }
}

Future<bool> putLib( context, container, postData ) async {
   String shortName = "putLib";
   final response = await postIt( shortName, postData, container );
   
   if (response.statusCode == 201) {
      // print( response.body.toString() );         
      return true;
   } else {
      bool didReauth = await checkFailure( response, shortName, context, container );
      if( didReauth ) { return await putLib( context, container, postData ); }
   }
}

Future<bool> putPerson( context, container, postData ) async {
   String shortName = "putPerson";
   final response = await postIt( shortName, postData, container );
   
   if (response.statusCode == 201) {
      // print( response.body.toString() );         
      return true;
   } else {
      bool didReauth = await checkFailure( response, shortName, context, container );
      if( didReauth ) { return await putPerson( context, container, postData ); }
   }
}


Future<bool> deleteLib( context, container, postData ) async {
   String shortName = "deleteLib";
   final response = await postIt( shortName, postData, container );
   
   if (response.statusCode == 201) {
      // print( response.body.toString() );         
      return true;
   } else {
      bool didReauth = await checkFailure( response, shortName, context, container );
      if( didReauth ) { return await deleteLib( context, container, postData ); }
   }
}

Future<bool> deleteBook( context, container, postData ) async {
   String shortName = "deleteBook";
   final response = await postIt( shortName, postData, container );
   
   if (response.statusCode == 201) {
      return true;
   } else {
      bool didReauth = await checkFailure( response, shortName, context, container );
      if( didReauth ) { return await deleteBook( context, container, postData ); }
   }
}

Future<bool> putShares( context, container, postData ) async {
   String shortName = "putShares";
   final response = await postIt( shortName, postData, container );
   
   if (response.statusCode == 201) {
      print( response.body.toString() );         
      return true;
   } else {
      bool didReauth = await checkFailure( response, shortName, context, container );
      if( didReauth ) { return await putShares( context, container, postData ); }
   }
}

// Version 1 v1 of google books api
// Note: undocumented varients, different results:   q=isbn#, q=isbn=#, q=isbn<#>, q=ISBN
// Note: multiple editions per book, google asks for a primary isbn, then related isbn.
Future<List<Book>> fetchISBN( isbn ) async {
   print( "fetchISBN " + isbn );
   final gatewayURLSingle = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn;
   final gatewayURLMany   = "https://www.googleapis.com/books/v1/volumes?q=isbn=" + isbn;
   var response = await http.get( gatewayURLSingle);
   
   if (response.statusCode != 200) {
      print( "RESPONSE Single: " + response.statusCode.toString() + " " + json.decode(utf8.decode(response.bodyBytes)).toString());
      throw Exception('Failed to load books');
   }

   Iterable results = (json.decode(utf8.decode(response.bodyBytes)))['items'];

   if( results == null ) {
      print( "Exact method failed, get multiple" );
      response = await http.get( gatewayURLMany);

      if (response.statusCode != 200) {
         print( "RESPONSE Many: " + response.statusCode.toString() + " " + json.decode(utf8.decode(response.bodyBytes)).toString());
         throw Exception('Failed to load books');
      }
      results = (json.decode(utf8.decode(response.bodyBytes)))['items'];
   }

   if( results == null ) { return null; }

   print( "There are " + results.length.toString() + " that match that ISBN" );
   List<Book> books = results.map((book)=> Book.bookGoogleFromJson(book, isbn)).toList();
   return books;
}

Future<List<Book>> fetchKeyword( titleKey, authorKey ) async {
   print( "fetchKeyword " + titleKey + " " + authorKey );
   if( titleKey == "" && authorKey == "" ) { return null; }

   String gatewayURL   = "https://www.googleapis.com/books/v1/volumes?q=";

   if( titleKey  != "" ) { gatewayURL += "intitle:" + titleKey + "+"; }
   if( authorKey != "" ) { gatewayURL += "inauthor:" + authorKey; }
   var response = await http.get( gatewayURL);
   
   if (response.statusCode != 200) {
      print( "RESPONSE Single: " + response.statusCode.toString() + " " + json.decode(utf8.decode(response.bodyBytes)).toString());
      throw Exception('Failed to load books');
   }

   Iterable results = (json.decode(utf8.decode(response.bodyBytes)))['items'];

   if( results == null ) { return null; }

   print( "There are " + results.length.toString() + " that match that keywords" );
   List<Book> books = results.map((book)=> Book.bookGoogleFromJson(book, "keywords")).toList();
   return books;
}



// Called on signin
initMyLibraries( context, container ) async {
   print( "initMyLibs" );
   final appState  = container.state;

   // NOTE personID not yet set
   appState.myLibraries = await fetchLibraries( context, container, '{ "Endpoint": "GetLibs" }' );
   assert( appState.myLibraries != null );
   if( appState.myLibraries.length > 0 ) {
      for( final lib in appState.myLibraries ) {
         if( lib.private ) {
            appState.privateLibId = lib.id;

            assert( lib.members.length == 1 );
            appState.userId = lib.members[0]; 
            
            break;
         }
      }
   }
   appState.myLibraries.sort((a, b) => a.private ? -1 : 1 );
   await initExploreLibraries( context, container );
   await initSelectedLibrary( context, container );
}

// XXX PAGINATE on aws
initExploreLibraries( context, container ) async {
   print( "initExploreLibs" );
   final appState  = container.state;
   appState.exploreLibraries = await fetchLibraries( context, container, '{ "Endpoint": "GetExploreLibs" }' );
}

initSelectedLibrary( context, container ) async {
   print( "InitSelectedLib" );
   final appState  = container.state;
   assert( appState.myLibraries.length >= 1 );
   final selectedLib = appState.privateLibId;
   await initLibBooks( context, container, selectedLib );
}

initLibBooks( context, container, selectedLibrary ) async {
   print( "InitLIBBOOKS " + selectedLibrary);
   final appState  = container.state;
   appState.booksInLib[selectedLibrary] = await fetchBooks( context, container, '{ "Endpoint": "GetBooks", "SelectedLib": "$selectedLibrary" }' );

   // new private lib needs some initialization
   if( selectedLibrary == appState.privateLibId && appState.booksInLib[selectedLibrary].length == 0 ) {
      String mylib = appState.privateLibId;
      await initOwnership( context, container, '{ "Endpoint": "InitOwnership", "PrivLibId": "$mylib" }' );
   }
}


initOwnerships( context, container ) async {
   print( "InitOwnerships" );
   final appState  = container.state;
   String uid = appState.userId;
   appState.ownerships = await fetchOwnerships( context, container, '{ "Endpoint": "GetOwnerships", "PersonId": "$uid" }' );
}

setShare( context, container, bookId, libId, newValue ) async {
   print( "setSHARES" );
   final appState  = container.state;

   String uid = appState.userId;
   String plib = appState.privateLibId;
   String share = newValue.toString();
   String postData = '{ "Endpoint": "UpdateShare", "BookId": "$bookId", "PersonId": "$uid", "LibId": "$libId", "PLibId": "$plib", "All": "false", "Value": "$share" }';
   await putShares( context, container, postData );
}

setAllShares( context, container, libId, newValue ) async {
   print( "setAllSHARES" );
   showToast( context, "Updating sharing data" );
   final appState  = container.state;

   String uid = appState.userId;
   String plib = appState.privateLibId;
   String share = newValue.toString();
   String postData = '{ "Endpoint": "UpdateShare", "BookId": "", "PersonId": "$uid", "LibId": "$libId", "PLibId": "$plib", "All": "true", "Value": "$share" }';
   await putShares( context, container, postData );
}

