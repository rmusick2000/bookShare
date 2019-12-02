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
   int authRetryCount;
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

   // XXX comments
   // App logic   
   bool loaded;
   bool loading;
   String userId;
   String privateLibId;
   List<Library> myLibraries;
   List<Library> exploreLibraries;
   Map<String, List<Book>> booksInLib;
   Book detailBook;

   String selectedLibrary;
   bool booksLoaded;

   bool sharesLoaded;              // my_library_page  shares.   is libraryShares dirty?
   Map<String, Set> ownerships;    // my_library_page: shares.   {libraryId: ["books"]}
   
   
   initAppData() {
      loaded = false;
      loading = false;
      myLibraries = null;
      exploreLibraries = null;
      privateLibId = "";
      userId = "";
      booksInLib = new Map<String, List<Book>>();
      detailBook = null;

      selectedLibrary = "";
      booksLoaded = true;
      sharesLoaded = false;   
      ownerships = new Map<String, Set>();
   }

   init() {
      isLoading = true;
      screenHeight = -1;
      screenWidth = -1;
      
      // Cognito values
      authRetryCount = 0;
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
