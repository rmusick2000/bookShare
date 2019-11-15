import 'dart:convert';  

// Dynamodb serializes primary key before using it... so...
class Library {
   final String       id;
   final String       name;
   final List<String> members;
   final bool         private;

   Library({this.id, this.name, this.members, this.private});
   
   factory Library.fromJson(Map<String, dynamic> json) {

      // Extra step needed to convert from List<dynamic> to List<int>
      var dynamicMem = json['Members'];
         
      return Library(
         id:      json['LibraryId'],
         name:    json['LibraryName'],
         private: json['JustMe' ],
         members: new List<String>.from(dynamicMem)
         );
   }

   String toString() {
      String res = "\nLibrary : " + name;
      res += "\n   id: " + id;
      res += "\n   private?: " + private.toString();
      res += "\n   members: " + members.toString();
      return res;
   }
}

