import 'package:random_string/random_string.dart';

class Book {
   final String  id;
   final String  title;
   final String  author;
   final String  ISBN;
   final String  publisher;
   final String  publishedDate;
   final String  pageCount;
   final String  description;  
   final String  imageSmall;
   final String  image;

   Book({this.id, this.title, this.author, this.ISBN, this.publisher, this.publishedDate, this.pageCount, this.description, this.imageSmall, this.image});

   dynamic toJson() => {'id': id, 'title': title, 'author': author, 'ISBN': ISBN, 
                           'imageSmall': imageSmall, 'image': image, 'publisher': publisher, 
                           'publishedDate': publishedDate, 'pageCount': pageCount, 'description': description
   };
   
   factory Book.fromJson(Map<String, dynamic> json) {

      // DynamoDB is not camelCase
      // All fields here have values, else something is broken in load
      return Book(
         id:            json['BookId'],
         title:         json['Title'],
         author:        json['Author'],
         ISBN:          json['ISBN'],
         publisher:     json['Publisher'],     
         publishedDate: json['PublishedDate'],
         pageCount:     json['PageCount'],
         description:   json['Description'],
         image:         json['Image'],
         imageSmall:    json['ImageSmall'],
         );
   }

   // DynamoDB won't store empty strings.  Grack.
   factory Book.bookGoogleFromJson(Map<String, dynamic> jsonV, requestedISBN) {
      var json = jsonV['volumeInfo'];
      
      String isbn = "---";
      String image = "---";
      String imageSmall = "---";
      String author = "";

      print( "FOUND " + json['title'] );

      // 978 in front == ISBN_13 10 is shorter
      final dynamicIden = json['industryIdentifiers'];
      if( dynamicIden != null ) {
         final identifiers = new List<Map<String, dynamic>>.from(dynamicIden);
         for( final ident in identifiers ) {
            if( ident['type'] == "ISBN_13" ) { isbn = ident['identifier'].toString(); break; }
         }
      }

      if( json['imageLinks'] != null ) {
         image      = json['imageLinks']['thumbnail'];
         imageSmall = json['imageLinks']['smallThumbnail'];

         // book details default to using image
         if( image == null && imageSmall != null ) {
            image = imageSmall;
         }
      }

      
      // Some books found by google were published a LONG time ago, authors not recorded
      var dynamicAuth = json['authors'];
      if( dynamicAuth != null ) {
         Iterable lauth = (new List<String>.from(dynamicAuth));
         if( lauth.length > 0 ) {
            for( final auth in lauth ) {
               if( author != "" ) { author += ", "; }
               author += auth; }
         }
      }
      if( author == "" ) { author = "---"; }

      String pc = json['pageCount']?.toString();   // call toString if not null
      pc ??= "---";                                   // assign if not null

      assert( pc != null );
      print( "page: " + pc );
      print( json['publisher'] ?? "---" );

      // Google is camelCase
      return Book(
         id:            randomAlpha(10),
         title:         json['title'] ?? "---",
         author:        author,
         ISBN:          isbn,
         publisher:     json['publisher'] ?? "---",     
         publishedDate: json['publishedDate'] ?? "---",
         pageCount:     pc,
         description:   json['description'] ?? "---",
         image:         image,
         imageSmall:    imageSmall 
         );
   }

   
   String toString() {
      print( "Book: " + title );
      print( "pub: " + publisher );

      String res = "\nBook : " + title;
      res += "\n   author: " + author;
      res += "\n   ISBN: " + ISBN;
      res += "\n   id: " + id;
      res += "\n   pub: " + publisher;
      res += "\n   pages: " + pageCount;
      res += "\n   pub date: " + publishedDate;
      // res += "\n   description: " + description;
      return res;
   }


}

