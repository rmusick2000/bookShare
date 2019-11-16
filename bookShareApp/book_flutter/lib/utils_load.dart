import 'dart:convert';  // json encode/decode
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:bookShare/utils.dart';
import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/models/libraries.dart';
import 'package:bookShare/models/books.dart';



Future<List<Library>> fetchLibraries( appState, postData ) async {
   print( "fetchLibrary " + postData );
   final gatewayURL = appState.apiBasePath + "/find"; 
   
   final response =
      await http.post(
         gatewayURL,
         headers: {HttpHeaders.authorizationHeader: appState.idToken},
         body: postData
         );
   
   if (response.statusCode == 201) {
      print( "JSON RESPONSE BODY: " + response.body.toString() );         
      
      Iterable l = json.decode(response.body);
      List<Library> libs = l.map((sketch)=> Library.fromJson(sketch)).toList();
      return libs;
   } else {
      print( "RESPONSE: " + response.statusCode.toString() + " " + json.decode(response.body).toString());
      throw Exception('Failed to load library');
   }
}

// XXX 1 func for all here?  
Future<List<Book>> fetchBooks( appState, postData ) async {
   print( "fetchBook " + postData );
   final gatewayURL = appState.apiBasePath + "/find"; 
   
   final response =
      await http.post(
         gatewayURL,
         headers: {HttpHeaders.authorizationHeader: appState.idToken},
         body: postData
         );
   
   if (response.statusCode == 201) {
      print( response.body.toString() );         
      
      Iterable l = json.decode(response.body);
      List<Book> books = l.map((sketch)=> Book.fromJson(sketch)).toList();
      return books;
   } else {
      print( "RESPONSE: " + response.statusCode.toString() + " " + json.decode(response.body).toString());
      throw Exception('Failed to load books');
   }
}


// Troublesome: glorious cause 9780345427571
// Version 1 v1 of google books api
// Note: undocumented varients, different results:   q=isbn#, q=isbn=#, q=isbn<#>, q=ISBN
// Note: multiple editions per book, google asks for a primary isbn, then related isbn.
Future<List<Book>> fetchISBN( isbn ) async {
   print( "fetchISBN " + isbn );
   final gatewayURLSingle = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn;
   final gatewayURLMany   = "https://www.googleapis.com/books/v1/volumes?q=isbn=" + isbn;
   var response = await http.get( gatewayURLSingle);
   
   if (response.statusCode != 200) {
      print( "RESPONSE Single: " + response.statusCode.toString() + " " + json.decode(response.body).toString());
      throw Exception('Failed to load books');
   }

   Iterable results = (json.decode(response.body))['items'];

   if( results == null ) {
      print( "Exact method failed, get multiple" );
      response = await http.get( gatewayURLMany);

      if (response.statusCode != 200) {
         print( "RESPONSE Many: " + response.statusCode.toString() + " " + json.decode(response.body).toString());
         throw Exception('Failed to load books');
      }
      results = (json.decode(response.body))['items'];
   }

   if( results == null ) { return null; }

   print( "There are " + results.length.toString() + " that match that ISBN" );
   List<Book> books = results.map((book)=> Book.bookGoogleFromJson(book, isbn)).toList();
   return books;
}

// AWS has username via cognito signin
// Update tables: Books, LibraryShares, Ownerships
Future<bool> putBook( appState, postData ) async {
   print( "putBook " + postData );
   final gatewayURL = appState.apiBasePath + "/find"; 
   
   final response =
      await http.post(
         gatewayURL,
         headers: {HttpHeaders.authorizationHeader: appState.idToken},
         body: postData
         );
   
   if (response.statusCode == 201) {
      print( response.body.toString() );         
      return true;
   } else {
      print( "RESPONSE: " + response.statusCode.toString() + " " + json.decode(response.body).toString());
      throw Exception('Failed to add book');
   }
}





// Called on signin
initMyLibraries( appState ) async {
   print( "initMyLibs" );
   appState.myLibraries = await fetchLibraries( appState, '{ "Endpoint": "GetLibs" }' );
   if( appState.myLibraries.length > 0 ) {
      for( final lib in appState.myLibraries ) {
         if( lib.private ) {
            appState.privateLibId = lib.id;
            break;
         }
      }
   }
   await initSelectedLibrary( appState );
}

initSelectedLibrary( appState ) async {
   print( "InitSelectedLib" );
   assert( appState.myLibraries.length >= 1 );
   final selectedLib = appState.privateLibId;
   await initLibBooks( appState, selectedLib );
}

initLibBooks( appState, selectedLibrary ) async {
   print( "InitLIBBOOKS" );
   appState.booksInLib[selectedLibrary] = await fetchBooks( appState, '{ "Endpoint": "GetBooks", "SelectedLib": "$selectedLibrary" }' );  
}
     
