import 'package:flutter/material.dart';

// Note - this requires state here: android/app/src/main/res/raw/awsconfiguration.json
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';


class AppState {
   bool isLoading;

   var returnValue;
   UserState userState;
   double progress;
   TextEditingController usernameController;
   TextEditingController passwordController;
   TextEditingController attributeController; 
   TextEditingController confirmationCodeController;

   init() {
      isLoading = true;
      
      // Cognito values
      UserState userState = UserState.UNKNOWN;
      double progress = -1;
      usernameController = TextEditingController();
      passwordController = TextEditingController();
      attributeController = TextEditingController();
      confirmationCodeController = TextEditingController();
   }

   
   AppState() {
      init();
   }
   
   // A constructor for when the app is loading.
   factory AppState.loading() => new AppState();

  @override
  String toString() {
     return 'AppState{isLoading: $isLoading}';
  }
}
