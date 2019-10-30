import 'package:flutter/material.dart';

// Note - this requires state here: android/app/src/main/res/raw/awsconfiguration.json
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

import 'dart:async';


// Flutter is all about widgets, stateless and stateful.
// Mounted, setState, initState, dispose are all parts of that picture.
// Mounted is true if the initState has been run and added to the BuildContext somewhere in the parent tree.
// Respect the flutter.

// Option 2 looks good?
// https://stackoverflow.com/questions/46542768/how-to-access-an-object-created-in-one-stateful-widget-in-another-stateful-widge

// Maybe .. ? sufficient but look at provider and scopemodel.
// ?? how does it interact with state widget
// https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html;
// ***  https://flutterbyexample.com/set-up-inherited-widget-app-state/

class BookShareAuth extends StatefulWidget {
  BookShareAuth({Key key}) : super(key: key);

  @override
  _BookShareAuthState createState() => _BookShareAuthState();
}


class _BookShareAuthState extends State<BookShareAuth> {

   var returnValue;
   UserState userState;
   double progress;
   final usernameController = TextEditingController();
   final passwordController = TextEditingController();
   final attributeController = TextEditingController();
   final confirmationCodeController = TextEditingController();

  // init Cognito
  Future<void> doLoad() async {
    var value;
    try {
      value = await Cognito.initialize();
    } catch (e, trace) {
      print(e);
      print(trace);

      if (!mounted) return;
      setState(() {
        returnValue = e;
        progress = -1;
      });

      return;
    }

    if (!mounted) return;
    setState(() {
      progress = -1;
      userState = value;
    });
  }

  @override
  void initState() {
     print( "... Auth init state" );
     super.initState();
     doLoad();
     Cognito.registerCallback((value) {
           if (!mounted) return;
           setState(() {
                 userState = value;
              });
        });
  }

  @override
  void dispose() {
    Cognito.registerCallback(null);
    usernameController.dispose();
    passwordController.dispose();
    attributeController.dispose();
    confirmationCodeController.dispose();
    super.dispose();
  }

  // wraps a function from the auth library with some scaffold code.
  onPressWrapper(fn) {
    wrapper() async {
      setState(() {
        progress = null;
      });

      String value;
      try {
        value = (await fn()).toString();
      } catch (e, stacktrace) {
        print(e);
        print(stacktrace);
        setState(() => value = e.toString());
      } finally {
        setState(() {
          progress = -1;
        });
      }

      setState(() => returnValue = value);
    }

    return wrapper;
  }

  @override
     Widget build(BuildContext context) {}
  
}
