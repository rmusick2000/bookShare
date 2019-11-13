import 'dart:convert';  

class Library {
   final int       id;
   final String    name;
   //final int     imageID;
   final List<int> members;
   final bool      private;

   Library({this.id, this.name, this.members, this.private});
   
   factory Library.fromJson(Map<String, dynamic> json) {
      // print( "FROMJSON: " + json.toString() );
      // Extra step needed to convert from List<dynamic> to List<int>
      var dynamicMem = json['Members'];
         
      return Library(
         id:      json['LibraryId'],
         name:    json['LibraryName'],
         private: json['Private' ],
         members: new List<int>.from(dynamicMem)
         );
   }

   String toString() {
      String res = "\nLibrary : " + name;
      res += "\n   private?: " + private.toString();
      res += "\n   id: " + id.toString();
      res += "\n   members: " + members.toString();
      return res;
   }
}

