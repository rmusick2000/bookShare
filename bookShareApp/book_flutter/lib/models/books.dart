import 'dart:convert';  

class Book {
   final int     id;
   final String  title;
   final String  author;
   final String  ISBN;
   //final int          image;

   Book({this.id, this.title, this.author, this.ISBN});
   
   factory Book.fromJson(Map<String, dynamic> json) {
      // print( "FROMJSON: " + json.toString() );
      return Book(
         id:     json['BookId'],
         title:  json['Title'],
         author: json['Author'],
         ISBN:   json['ISBN']
         );
   }
}

