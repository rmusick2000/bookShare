import 'models/app_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();

    // XXX add a generic init for app_state, called from here?
    if (widget.state != null) {
       state = widget.state;
       print( "AppState: already initialized." );
    } else {
       state = new AppState.loading();
       print( "AppState: initializing." );
    }
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
