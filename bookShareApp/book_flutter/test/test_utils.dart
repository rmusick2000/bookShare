import 'package:test/test.dart';
import 'package:bookShare/utils.dart';

void main() {
   test('Simple increment test', () {

         final val = testIncrement(13);
         expect(val, 14);
  });
}
