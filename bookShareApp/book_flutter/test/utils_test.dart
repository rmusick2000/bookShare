import 'package:test/test.dart';

import 'package:bookShare/utils.dart';

void main() {

   group('Utils Basics', () {

         print( "Testing group utilsBasics" );
         test('Simple increment test', () {
               final val = testIncrement(13);
               expect(val, 14);
            });
      });
}
