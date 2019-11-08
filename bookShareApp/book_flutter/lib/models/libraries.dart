import 'dart:convert';  

class Library {
   final int          id;
   final String       name;
   //final int          imageID;
   final List<int> members;

   //Library({this.id, this.name, this.imageID, this.members});
   Library({this.id, this.name, this.members});
   //Library({this.id, this.name});
   
   factory Library.fromJson(Map<String, dynamic> json) {
      // print( "FROMJSON: " + json.toString() );
      // Extra step needed to convert from List<dynamic> to List<int>
      var dynamicMem = json['Members'];
         
      return Library(
         id: json['LibraryId'],
         name: json['LibraryName'],
         //imageID: json['imageID'],
         members: new List<int>.from(dynamicMem)
         );
   }
}

class LibrarySketch {
   final int          id;
   final String       name;
   final int          imageID;

   LibrarySketch({this.id, this.name, this.imageID});
   
   factory LibrarySketch.fromJson(Map<String, dynamic> json) {
      print( "in fromjson.. id " + json['id'].toString() + " name: " + json['name'] );
      return LibrarySketch(
         id: json['id'],
         name: json['name'],
         imageID: json['imageID']
         );
   }

   toString() {
      print( "Library: " + name );
   }
}

