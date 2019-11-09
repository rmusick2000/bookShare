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
     

