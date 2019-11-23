import 'dart:convert';  
import 'package:random_string/random_string.dart';


class Share {
   final String            bookId;
   final Map<String,bool>  libraries;  

   Share({ this.bookId, this.libraries });

   factory Share.fromJson(Map<String, dynamic> json) {

      final dynamicLib = json['Libraries'];
      final listLibs   = new List<String>.from(dynamicLib);
      Map<String,bool> libraries  = new Map.fromIterable( listLibs, key: (item) => item, value: (item) => true );
      
      // DynamoDB is not camelCase
      // All fields here have values, else something is broken in load
      return Share(
         bookId:     json['BookId'],
         libraries:  libraries
         );
   }
   
   String toString() {
      print( "Shared book: " + bookId );

      String res = "\nShared book : " + bookId;
      res += "\n   Libraries: " + libraries.toString();
      return res;
   }


}

