import 'dart:typed_data';                   // ByteData
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
   var returnValue;       // catch callback return values from buttonpress calls to cognito funcs
   UserState userState;
   bool cogInitDone;      // main: sometimes cog init is slow.  Timer refires until this is true
   bool newUser;          // signup: newuser creating a login has some special requirements during setup
   bool gatOverride;      // prevent cognito callback from double-firing
   
   String apiBasePath;                         // where to find lambda interface to aws
   TextEditingController usernameController;   
   TextEditingController passwordController;
   TextEditingController attributeController; 
   TextEditingController confirmationCodeController;
   double screenHeight;
   double screenWidth;

   // App logic   
   bool loaded;                           // control expensive aspects of state initialization
   bool loading;                    
   String userId;
   String privateLibId;
   List<Library> myLibraries;             // libraries that I've a member of, or I've created
   List<Library> exploreLibraries;        // libraries to explore
   bool updateLibs;                       // time to update libs.  e.g. new image, or other edits
   Map<String, List<Book>> booksInLib;
   Book detailBook;

   String selectedLibrary;
   bool booksLoaded;

   bool sharesLoaded;              // my_library_page  shares.   is libraryShares dirty?
   Map<String, Set> ownerships;    // my_library_page: shares.   {libraryId: ["books"]}

   bool makeLibPng;                // image_page: it is time to convert canvas to png data
   Uint8List currentPng;           // image_page: current converted png data
   
   initAppData() {
      loaded = false;
      loading = false;
      myLibraries = null;
      exploreLibraries = null;
      updateLibs = true;
      
      privateLibId = "";
      userId = "";
      booksInLib = new Map<String, List<Book>>();
      detailBook = null;

      selectedLibrary = "";
      booksLoaded = true;
      sharesLoaded = false;   
      ownerships = new Map<String, Set>();

      makeLibPng = false;
      currentPng = null;
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
      cogInitDone = false;
      gatOverride = false;
      newUser = false;
      
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
