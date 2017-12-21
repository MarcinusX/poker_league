import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:redux/redux.dart';

middleware(Store<ReduxState> store, action, NextDispatcher next) {
  if (action is DoLogIn) {
    _logIn(store);
  }
  next(action);
  if (action is InitAction) {
    _tryLogInInBackground(store);
  }
}

_tryLogInInBackground(Store<ReduxState> store) async {
  FirebaseUser user = await store.state.firebaseState.firebaseAuth
      .currentUser();
  if (user != null) {
    store.dispatch(new OnLoggedInSuccessful(user));
  }
}

_logIn(Store<ReduxState> store) async {
  GoogleSignIn googleSignIn = new GoogleSignIn();
  FirebaseAuth auth = store.state.firebaseState.firebaseAuth;
  GoogleSignInAccount currentUser = googleSignIn.currentUser;
  if (currentUser == null) {
    currentUser = await googleSignIn.signInSilently();
  }
  if (currentUser == null) {
    await googleSignIn.signIn();
  }
  if (await auth.currentUser() == null) {
    GoogleSignInAuthentication credentials = await currentUser.authentication;
    await auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
  }
  store.dispatch(new OnLoggedInSuccessful(await auth.currentUser()));
}
