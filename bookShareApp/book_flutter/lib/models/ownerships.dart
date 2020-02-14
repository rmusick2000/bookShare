
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
