class AppState {
   bool isLoading;
   String aname;
   
   // Empty constructor with two named parameters, not used...
   AppState({this.isLoading = false, this.aname = 'Freddy Jones' });
   
   // A constructor for when the app is loading.
   factory AppState.loading() => new AppState(isLoading: true, aname: 'Duffy Pete');

  @override
  String toString() {
     return 'AppState{isLoading: $isLoading, aname: ${aname?.toString() ?? 'WADDA NAME'}}';
  }
}
