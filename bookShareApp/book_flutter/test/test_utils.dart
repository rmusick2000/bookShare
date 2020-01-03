import 'package:flutter/material.dart';

//import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bookShare/utils.dart';
import 'package:bookShare/main.dart';
import 'package:bookShare/app_state_container.dart';

void main() {

   group('Basics', () {

         testWidgets('Launch page', (WidgetTester tester) async {
               
               // Build our app and trigger a frame.
               await tester.pumpWidget( AppStateContainer( child: new BSApp()) );

               // To pass through timer.. hmm.
               await tester.pumpAndSettle( Duration(seconds: 25) );
               
               // Verify key launch page buttons
               expect(find.text('Create New Account'), findsOneWidget);
               expect(find.text('Login'), findsOneWidget);
               
               // Tap login and build page
               // bah.. just with driver.
               // await tester.tap(find.byValueKey( 'Login' ) );
               await tester.tap( find.byType( MaterialButton ).last );
               await tester.pumpAndSettle();
               
               // expect to find login stuff
               expect( find.text( 'username' ), findsOneWidget );
               expect( find.text( 'password' ), findsOneWidget );
               expect( find.text( 'Login' ),    findsOneWidget );
               
            });
         
         test('Simple increment test', () {
               
               final val = testIncrement(13);
               expect(val, 14);
            });
      });
}
