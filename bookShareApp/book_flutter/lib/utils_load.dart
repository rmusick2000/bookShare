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
Future<Book> fetchISBN( isbn ) async {
   print( "fetchISBN " + isbn );
   // Version 1 v1
   // Note: undocumented varients, different results:   q=isbn#, q=isbn=#, q=isbn<#>, q=ISBN
   // Note: multiple editions per book, google asks for a primary isbn, then related isbn.
   //       So, don't use isbn: interface, since you probably don't have the primary.
   //           do    use the first result back, as google has sorted it by relevance.
   final gatewayURL = "https://www.googleapis.com/books/v1/volumes?q=isbn:" + isbn;
   
   final response =
      await http.get( gatewayURL);
   
   if (response.statusCode == 200) {
      // print( response.body.toString() );
      // Possibly, maybe, at some point, offer a variety of results and let user choose.
      /*
      Iterable l = (json.decode(response.body))['items'];
      print( gatewayURL );
      print( "There are " + l.length.toString() + " that match that ISBN" );
      List<Book> books = l.map((book)=> Book.bookGoogleFromJson(book, isbn)).toList();
      */
      var results = (json.decode(response.body))['items'];

      if( results != null ) {
         if( results.length > 0 ) {
            Book book = Book.bookGoogleFromJson(results[0], isbn);
            return book;
         }}
      else {
         print( "Exact method failed, trying best guess" );
         final gatewayURL = "https://www.googleapis.com/books/v1/volumes?q=isbn=" + isbn;
         
         final response =
            await http.get( gatewayURL);
         
         if (response.statusCode == 200) {
            var results = (json.decode(response.body))['items'];
            
            if( results != null ) {
               if( results.length > 0 ) {
                  Book book = Book.bookGoogleFromJson(results[0], isbn);
                  return book;
               }}
         }}
   } else {
      print( "RESPONSE: " + response.statusCode.toString() + " " + json.decode(response.body).toString());
      throw Exception('Failed to load books');
   }
}



// Called on signin
initMyLibraries( appState ) async {
   print( "initMyLibs" );
   appState.myLibraries = await fetchLibraries( appState, '{ "Endpoint": "GetLibs" }' );
   await initSelectedLibrary( appState );
}

initSelectedLibrary( appState ) async {
   print( "InitSelectedLib" );
   assert( appState.myLibraries.length >= 1 );
   final selectedLib = appState.myLibraries[0].id;   // XXX XXX XXX
   await initLibBooks( appState, selectedLib );
}

initLibBooks( appState, selectedLibrary ) async {
   print( "InitLIBBOOKS" );
   appState.booksInLib["lib"+selectedLibrary.toString()] = await fetchBooks( appState, '{ "Endpoint": "GetBooks", "SelectedLib": $selectedLibrary }' );  
}
     

