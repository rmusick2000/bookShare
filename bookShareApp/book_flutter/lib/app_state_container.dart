import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Note - this requires state here: android/app/src/main/res/raw/awsconfiguration.json
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';


import 'package:bookShare/models/app_state.dart';
import 'package:bookShare/utils_load.dart';


class AppStateContainer extends StatefulWidget {
   
  final AppState state;   // bookshare state
  final Widget child;     // This widget is simply the root of the tree, child will be BSApp

  AppStateContainer({ @required this.child, this.state });

  // Return container state with AppState, as the 'of' method which provides state to all children
  static _AppStateContainerState of(BuildContext context) {
     // deprecated 1.12
     //return (context.inheritFromWidgetOfExactType(_InheritedStateContainer) as _InheritedStateContainer).data;
     return (context.dependOnInheritedWidgetOfExactType<_InheritedStateContainer>() as _InheritedStateContainer).data;
  }

  
  @override
  _AppStateContainerState createState() => new _AppStateContainerState();
}


class _AppStateContainerState extends State<AppStateContainer> {
  AppState state;  

  // init Cognito
  Future<void> doLoad() async {
     print( "... Cognito doload in init state" );
     var value;
     try {
        value = await Cognito.initialize();
     } catch (e, trace) {
        print(e);
        print(trace);
        
        if (!mounted) return;
        setState(() {
              state.returnValue = e;
           });
        
        return;
     }
     
     if (!mounted) return;
     print( "... Cognito doload returning mounted with " + value.toString() );
     setState(() {
           state.cogInitDone = true;
           state.userState = value;
        });
  }
  
  Future<void> getAuthTokens( override ) async {
     //print( "GAT, with " + state.idToken );
     state.gatOverride = override;
     if( state.accessToken == "" || state.idToken == "" || override == true) {
        List tokenString = (await Cognito.getTokens()).toString().split(" ");
        String accessToken = tokenString[3].split(",")[0];
        String idToken = tokenString[5].split(",")[0];
        String refreshToken = tokenString[7].split(",")[0];
        print( "GAT, with new token " + idToken );
        setState(() {
              state.accessToken = accessToken;
              state.idToken = idToken;
              state.refreshToken = refreshToken;
           });
     }
  }


  Future<void> getAPIBasePath() async {
     if( state.apiBasePath == "" ) {
        String basePath = await DefaultAssetBundle.of(context).loadString('files/api_base_path.txt');
        setState(() {
              state.apiBasePath = basePath.trim();
           });
     }
  }

  Future<void> newUserBasics() async {
     assert( state.newUser );
     await getAuthTokens( false );
     await getAPIBasePath();
  }
  
  @override
  void initState() {
     super.initState();

     print("Container init" );
        
     if (widget.state != null) {
        state = widget.state;
        print( "AppState: already initialized." );
     } else {
        state = new AppState.loading();
        print( "AppStateContainer: initializing." );
     }
     
     doLoad();
     // This callback controls state updating
     Cognito.registerCallback((value) async {
           if (!mounted) return;
           if( state.loading ) return;  // do nothing if callback already in progress
           bool stateLoaded = false;
           
           if( ! state.newUser ) {
              if( value == UserState.SIGNED_IN )
              {
                 print( "Cog callback signed in user " + state.loading.toString() + " " + state.loaded.toString() + " " + stateLoaded.toString());
                 
                 // This callback can get executed several times on startup.  
                 // Callbacks can run back to back, before awaits below finish)
                 if( !state.loading && !state.loaded )
                 {
                    state.loading = true;
                    await getAuthTokens( false );
                    
                    // Libraries and books
                    await getAPIBasePath();
                    
                    await initMyLibraries( context, this );
                    stateLoaded = true;
                    state.loading = false;
                    print ("CALLBACK, loaded TRUE" );
                 }
              }
              
              // set stateLoaded if reauth-inspired gatOverride, avoiding above race
              if( state.loaded && state.gatOverride ) {
                 stateLoaded = true;
              }
              
              // If this becomes async, build is not predictably triggered on state change
              setState(() {
                    state.userState = value;
                    state.loaded = stateLoaded;
                    state.authRetryCount += 1;
                    if( !stateLoaded ) {
                       state.accessToken = "";
                       state.idToken = "";
                       state.initAppData();
                    }
                    print( "container callback setstate done, retries " + state.authRetryCount.toString() );
                 });
           }});
     print( "Container init over" );
  }
  
  @override
  void dispose() {
     Cognito.registerCallback(null);
     state.usernameController.dispose();
     state.passwordController.dispose();
     state.attributeController.dispose();
     state.confirmationCodeController.dispose();
     super.dispose();
  }

  // Cognito button-press wrapper
  onPressWrapper(fn) {
     wrapper() async {
        String value;
        try {
           value = (await fn()).toString();
        } catch (e, stacktrace) {
           print(e);
           print(stacktrace);
           setState(() => value = e.toString());
        }
        // finally { }
        
        setState(() => state.returnValue = value);
     }
     
     return wrapper;
  }

  
  // WidgetTree is: AppStateContainer --> InheritedStateContainer --> The rest of your app. 
  @override
  Widget build(BuildContext context) {
     return new _InheritedStateContainer( data: this, child: widget.child );
  }
}



class _InheritedStateContainer extends InheritedWidget {

   final _AppStateContainerState data;     // The data is whatever this widget is passing down.

  // InheritedWidgets are always just wrappers.
  // Flutter knows to build the Widget thats passed to it, so no build method
  _InheritedStateContainer({
    Key key,
    @required this.data,
    @required Widget child,
  }) : super(key: key, child: child);
  
  // Flutter automatically calls this method when any data in this widget is changed. 
  // can make sure that flutter actually should repaint the tree, or do nothing.
  // It helps with performance.
  @override
  bool updateShouldNotify(_InheritedStateContainer old) => true;
}



