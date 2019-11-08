import 'package:flutter/material.dart';

// Note - this requires state here: android/app/src/main/res/raw/awsconfiguration.json
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';


class AppState {
   bool isLoading;

   var returnValue;
   UserState userState;
   String accessToken;
   String idToken;
   double progress;
   String apiBasePath;
   TextEditingController usernameController;
   TextEditingController passwordController;
   TextEditingController attributeController; 
   TextEditingController confirmationCodeController;

   // Route-related
   List<Route> routeStack;
   int anchor;
   
   // App logic 
   
   init() {
      isLoading = true;
      
      // Cognito values
      UserState userState = UserState.UNKNOWN;
      accessToken = "";
      idToken = "";
      double progress = -1;
      apiBasePath = "";
      usernameController = TextEditingController();
      passwordController = TextEditingController();
      attributeController = TextEditingController();
      confirmationCodeController = TextEditingController();

      routeStack = new List(9);
      anchor = 0;
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
