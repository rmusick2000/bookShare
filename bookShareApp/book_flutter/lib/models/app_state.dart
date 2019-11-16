import 'package:flutter/material.dart';

// Note - this requires state here: android/app/src/main/res/raw/awsconfiguration.json
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';
import 'package:bookShare/models/libraries.dart';
import 'package:bookShare/models/books.dart';


class AppState {
   bool isLoading;

   // Credentials
   String accessToken;
   String idToken;
   String refreshToken;

   var returnValue;
   UserState userState;
   double progress;
   String apiBasePath;
   TextEditingController usernameController;
   TextEditingController passwordController;
   TextEditingController attributeController; 
   TextEditingController confirmationCodeController;
   double screenHeight;
   double screenWidth;
   
   // App logic
   bool loaded;
   bool loading;
   String privateLibId;
   List<Library> myLibraries;
   Map<String, List<Book>> booksInLib;

   String selectedLibrary;
   bool booksLoaded;
   
   initAppData() {
      loaded = false;
      loading = false;
      myLibraries = null;
      privateLibId = "";
      booksInLib = new Map<String, List<Book>>();

      selectedLibrary = "";
      booksLoaded = true;
   }

   init() {
      isLoading = true;
      screenHeight = -1;
      screenWidth = -1;
      
      // Cognito values
      UserState userState = UserState.UNKNOWN;
      accessToken = "";
      idToken = "";
      refreshToken = "";
      double progress = -1;
      apiBasePath = "";
      usernameController = TextEditingController();
      passwordController = TextEditingController();
      attributeController = TextEditingController();
      confirmationCodeController = TextEditingController();

      initAppData();
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
