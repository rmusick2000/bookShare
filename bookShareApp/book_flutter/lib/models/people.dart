import 'dart:typed_data';                   // ByteData

import 'package:flutter/material.dart';

// Dynamodb serializes primary key before using it... so...
class Person {
   final String id;
   String       firstName;
   String       lastName;
   String       userName;
   String       email;
   Uint8List    imagePng;     // ONLY   use to, from and in dynamoDB
   Image        image;        // ALWAYS use elsewhere

   Person({this.id, this.firstName, this.lastName, this.userName, this.email, this.imagePng, this.image});
   
   dynamic toJson() {
      if( imagePng == null ) {
         return { 'id': id, 'firstName': firstName, 'lastName': lastName, 'userName': userName, 'email': email, 'imagePng': null };

      } else {
         return { 'id': id, 'firstName': firstName, 'lastName': lastName, 'userName': userName, 'email': email, 
               'imagePng': String.fromCharCodes( imagePng ) };
      }
   }
   
   factory Person.fromJson(Map<String, dynamic> json) {

      var imagePng;
      var image;
      final dynamicImage = json['ImagePng'];   // string rep of bytes
      if( dynamicImage != null ) {
         imagePng =  Uint8List.fromList( dynamicImage.codeUnits );   // codeUnits gets Uint16List
         image = Image.memory( imagePng );
      }

      return Person(
         id:          json['PersonId'],
         firstName:   json['FirstName'],
         lastName:    json['LastName'],
         userName:    json['UserName'],
         email:       json['Email'],
         imagePng:    imagePng,
         image:       image
         );
   }

   String toString() {
      firstName = firstName ?? "";
      lastName  = lastName ?? "";
      userName  = userName ?? "";
      email     = email ?? "";

      String res = "\nPerson : " + firstName + " " + lastName;
      res += "\n   userName: " + userName;
      res += "\n   email: " + email;
      res += "\n   id: " + id;
      if( image != null ) { res += "\n   there is an image"; }

      return res;
   }
}

