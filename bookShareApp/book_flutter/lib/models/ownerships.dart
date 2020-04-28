// Ownership is a record of the books a person owns, and the libraries those books are shared out to.
// A book object can be owned by more than one person
// When deleting (or adding) a book it is the ownership and sharing that is deleted, not the book.

// ownershipID: personID
// books:       map: owned book id to attribute list
// shares:      map: library id to stringset owned books shared to that lib

class Ownership {
   final Map<String,Set> shares;  // lib: books

   Ownership({ this.shares });

   factory Ownership.fromJson(Map<String, dynamic> json) {

      // _InternalLinkedHashMap<String, dynamic>
      final dynamicLib = json['Shares'];
      // Map<String,Set<String>> shares  = new Map.fromIterable( dynamicLib, key: (v) => v[0], value: (v) => v[1] );
      dynamicLib.forEach((k,v) => print('$k: $v'));
      Map<String,Set<String>> shares = {};
      dynamicLib.forEach((k,v) {
            shares[k] = Set<String>.from(v);
         }
         );

      return Ownership(
         shares: shares
         );
   }
   
   String toString() {
      String res = "\nOwnership: ";
      res += "\n   Shares: " + shares.toString();
      return res;
   }


}
