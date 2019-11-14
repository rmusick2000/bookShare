import 'dart:convert';  
import 'package:random_string/random_string.dart';

class Book {
   final String  id;
   final String  title;
   final String  author;
   final String  ISBN;
   final String  imageSmall;
   final String  image;

   Book({this.id, this.title, this.author, this.ISBN, this.image, this.imageSmall});
   
   factory Book.fromJson(Map<String, dynamic> json) {

      return Book(
         id:     json['BookId'],
         title:  json['Title'],
         author: json['Author'],
         ISBN:   json['ISBN']
         );
   }

   factory Book.bookGoogleFromJson(Map<String, dynamic> jsonV, requestedISBN) {
      var json = jsonV['volumeInfo'];
      
      var dynamicAuth = json['authors'];
      String isbn = "";
      
      // 978 in front == ISBN_13 10 is shorter
      final dynamicIden = json['industryIdentifiers'];
      if( dynamicIden != null ) {
         final identifiers = new List<Map<String, dynamic>>.from(dynamicIden);
         for( final ident in identifiers ) {
            if( ident['type'] == "ISBN_13" ) { isbn = ident['identifier'].toString(); break; }
         };
      }

      // Can't do this, chances are this is not a primary isbn.
      // if( isbn != requestedISBN ) { print( isbn + " doesn't match requested " + requestedISBN + " .. skipping."); return null; }

      print( "FOUND " + json['title'] );
      /*
      print( json['authors'] );
      print( (new List<String>.from(dynamicAuth))[0] );
      print( isbn );
      print( json['description'] );
      print( json['publishedDate'] );
      print( json['publisher'] );
      print( json['pageCount'] );
      print( json['imageLinks'] );
      */
      String image = "";
      String imageSmall = "";
      
      if( json['imageLinks'] != null ) {
         image      = json['imageLinks']['thumbnail'];
         imageSmall = json['imageLinks']['smallThumbnail'];
      }

      // XXX
      return Book(
         id:         randomAlpha(10),
         title:      json['title'],
         author:     (new List<String>.from(dynamicAuth))[0],
         ISBN:       isbn,
         image:      image,
         imageSmall: imageSmall 
         );
   }

   String toString() {
      String res = "\nBook : " + title;
      res += "\n   author: " + author;
      res += "\n   ISBN: " + ISBN;
      res += "\n   id: " + id;
      return res;
   }


}

