import 'dart:typed_data';                   // ByteData

import 'package:flutter/material.dart';

// Dynamodb serializes primary key before using it... so...
// https://stackoverflow.com/questions/47124945/how-to-read-bytes-of-a-local-image-file-in-dart-flutter
class Library {
   final String id;
   String       name;
   String       description;
   List<String> members;
   Uint8List    imagePng;     // ONLY   use to, from and in dynamoDB
   Image        image;        // ALWAYS use elsewhere
   final bool   private;
   bool         prospect;     // only true when creating a new lib, before edits are accepted

   Library({this.id, this.name, this.description, this.members, this.imagePng, this.image, this.private, this.prospect});
   
   dynamic toJson() {
      if( imagePng == null ) {
         return { 'id': id, 'name': name, 'description': description, 'private': private, 'members': members, 'imagePng': null };

      } else {
         return {'id': id, 'name': name, 'description': description, 'private': private, 'members': members, 
               'imagePng': String.fromCharCodes( imagePng ) };
      }
   }
   
   factory Library.fromJson(Map<String, dynamic> json) {

      var dynamicMem = json['Members'];

      var imagePng;
      var image;
      final dynamicImage = json['ImagePng'];   // string rep of bytes
      if( dynamicImage != null ) {
         imagePng =  Uint8List.fromList( dynamicImage.codeUnits );   // codeUnits gets Uint16List
         image = Image.memory( imagePng );
      }

      bool priv = false;
      if( json['JustMe' ] == true || json['JustMe' ] == "true" ) { priv = true; }
      
      return Library(
         id:          json['LibraryId'],
         name:        json['LibraryName'],
         description: json['Description'],
         private:     priv,
         members:     new List<String>.from(dynamicMem),
         imagePng:    imagePng,
         image:       image,
         prospect:    false
         );
   }

   String toString() {
      name        = name ?? "";
      description = description ?? "";

      String res = "\nLibrary : " + name;
      res += "\n   description: " + description;
      res += "\n   id: " + id;
      res += "\n   private?: " + private.toString();
      res += "\n   prospect?: " + prospect.toString();
      res += "\n   members: " + members.toString();
      if( image != null ) { res += "\n   there is an image"; }

      return res;
   }
}

