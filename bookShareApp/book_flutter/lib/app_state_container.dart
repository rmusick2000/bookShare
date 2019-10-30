import 'models/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Note - this requires state here: android/app/src/main/res/raw/awsconfiguration.json
import 'package:flutter_cognito_plugin/flutter_cognito_plugin.dart';

class AppStateContainer extends StatefulWidget {
   
  final AppState state;   // bookshare state
  final Widget child;     // This widget is simply the root of the tree, child will be BSApp

  AppStateContainer({ @required this.child, this.state });

  // Return container state with AppState, as the 'of' method which provides state to all children
  static _AppStateContainerState of(BuildContext context) {
     return (context.inheritFromWidgetOfExactType(_InheritedStateContainer) as _InheritedStateContainer).data;
  }

  
  @override
  _AppStateContainerState createState() => new _AppStateContainerState();
}


class _AppStateContainerState extends State<AppStateContainer> {
  AppState state;   // passing the state through so we don't have to manipulate it with widget.state.


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
              state.progress = -1;
           });
        
        return;
     }
     
     if (!mounted) return;
     setState(() {
           state.progress = -1;
           state.userState = value;
        });
  }
  
  @override
  void initState() {
    super.initState();

    if (widget.state != null) {
       state = widget.state;
       print( "AppState: already initialized." );
    } else {
       state = new AppState.loading();
       print( "AppState: initializing." );
    }

    doLoad();
    // This callback controls state updating
    Cognito.registerCallback((value) {
          if (!mounted) return;
          setState(() {
                state.userState = value;
             });
       });
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
      setState(() {
        state.progress = null;
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
          state.progress = -1;
        });
      }

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