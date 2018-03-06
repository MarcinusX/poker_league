import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:redux/redux.dart';

List<Middleware<ReduxState>> createAuthMiddleware({
  @required GoogleSignIn googleSignIn,
  @required FirebaseAuth firebaseAuth,
  @required FacebookLogin facebookSignIn,
}) {
  final logInWithEmail = _createLogInWithEmail(firebaseAuth);
  final registerWithEmail = _createRegisterWithEmail(firebaseAuth);
  final logInWithGoogle = _createLogInWithGoogle(googleSignIn, firebaseAuth);
  final logInWithFacebook =
  _createLogInWithFacebook(facebookSignIn, firebaseAuth);
  final onInit = _createTryToLoginInBackground(firebaseAuth);
  final logout = _createLogout(googleSignIn, facebookSignIn, firebaseAuth);
  return combineTypedMiddleware([
    new MiddlewareBinding<ReduxState, DoGoogleLogIn>(logInWithGoogle),
    new MiddlewareBinding<ReduxState, DoFacebookLogIn>(logInWithFacebook),
    new MiddlewareBinding<ReduxState, InitAction>(onInit),
    new MiddlewareBinding<ReduxState, SignOutAction>(logout),
    new MiddlewareBinding<ReduxState, RegisterWithEmailAction>(
        registerWithEmail),
    new MiddlewareBinding<ReduxState, LogInWithEmailAction>(logInWithEmail),
  ]);
}

_createRegisterWithEmail(FirebaseAuth firebaseAuth) {
  return (Store<ReduxState> store, RegisterWithEmailAction action,
      NextDispatcher next) {
    _registerWithEmail(store, firebaseAuth, action.email, action.password);
  };
}

_registerWithEmail(Store<ReduxState> store, FirebaseAuth auth, String email,
    String password) async {
  FirebaseUser user = await auth.createUserWithEmailAndPassword(
      email: email, password: password);
  if (user != null) {
    await auth.updateProfile(new UserUpdateInfo()
      ..displayName = email.substring(0, email.indexOf('@')));
    user = await auth.currentUser();
    if (user != null) {
      store.dispatch(new OnLoggedInSuccessful(user));
    }
  }
}

_createLogInWithEmail(FirebaseAuth firebaseAuth) {
  return (Store<ReduxState> store, LogInWithEmailAction action,
      NextDispatcher next) {
//    firebaseAuth
//        .createUserWithEmailAndPassword(
//        email: action.email, password: action.password)
//        .then((firebaseUser) {
//      if (firebaseUser != null) {
//        store.dispatch(new OnLoggedInSuccessful(firebaseUser));
//      }
//    });
  };
}

_createLogout(GoogleSignIn googleSignIn, FacebookLogin facebookSignIn,
    FirebaseAuth firebaseAuth) {
  return (Store<ReduxState> store, SignOutAction action, NextDispatcher next) {
    Future.wait([
      googleSignIn.signOut(),
      firebaseAuth.signOut(),
      facebookSignIn.logOut(),
    ]).then((_) => new Future.delayed(new Duration(milliseconds: 300),
        () => store.dispatch(new OnSignedOutAction())));
    next(action);
  };
}

_createTryToLoginInBackground(FirebaseAuth firebaseAuth) {
  return (Store<ReduxState> store, InitAction action, NextDispatcher next) {
    next(action);

    firebaseAuth.currentUser().then((user) {
      if (user != null) {
        store.dispatch(new OnLoggedInSuccessful(user));
      }
    });

    store.dispatch(new LoadActiveLeagueNameFromSP());
  };
}

_createLogInWithGoogle(GoogleSignIn googleSignIn, FirebaseAuth firebaseAuth) {
  return (Store<ReduxState> store, DoGoogleLogIn action, NextDispatcher next) {
    _logInWithGoogle(googleSignIn, firebaseAuth).then((firebaseUser) =>
        store.dispatch(new OnLoggedInSuccessful(firebaseUser)));

    next(action);
  };
}

_createLogInWithFacebook(
    FacebookLogin facebookSignIn, FirebaseAuth firebaseAuth) {
  return (Store<ReduxState> store, DoFacebookLogIn action,
      NextDispatcher next) {
    _logInWithFacebook(facebookSignIn, firebaseAuth).then((firebaseUser) {
      if (firebaseUser != null) {
        store.dispatch(new OnLoggedInSuccessful(firebaseUser));
      }
    });
    next(action);
  };
}

Future<FirebaseUser> _logInWithFacebook(
    FacebookLogin facebookSignIn, FirebaseAuth firebaseAuth) async {
  final FacebookLoginResult result =
      await facebookSignIn.logInWithReadPermissions(['email']);

  switch (result.status) {
    case FacebookLoginStatus.loggedIn:
      final FacebookAccessToken accessToken = result.accessToken;
      print('''
         Logged in!
         
         Token: ${accessToken.token}
         User id: ${accessToken.userId}
         Expires: ${accessToken.expires}
         Permissions: ${accessToken.permissions}
         Declined permissions: ${accessToken.declinedPermissions}
         ''');
      return await firebaseAuth.signInWithFacebook(
          accessToken: accessToken.token);
    //await firebaseAuth.updateProfile(new UserUpdateInfo());
    //await facebookSignIn.
    case FacebookLoginStatus.cancelledByUser:
      print('Login cancelled by the user.');
      return null;
    case FacebookLoginStatus.error:
      print('Something went wrong with the login process.\n'
          'Here\'s the error Facebook gave us: ${result.errorMessage}');
      return null;
    default:
      return null;
  }
}

Future<FirebaseUser> _logInWithGoogle(
    GoogleSignIn googleSignIn, FirebaseAuth firebaseAuth) async {
  GoogleSignInAccount currentUser = googleSignIn.currentUser;
  if (currentUser == null) {
    currentUser = await googleSignIn.signInSilently();
  }
  if (currentUser == null) {
    currentUser = await googleSignIn.signIn();
  }
  if (await firebaseAuth.currentUser() == null) {
    GoogleSignInAuthentication credentials = await currentUser.authentication;
    await firebaseAuth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
    await firebaseAuth.updateProfile(new UserUpdateInfo()
      ..photoUrl = currentUser.photoUrl
      ..displayName = currentUser.displayName);
  }
  return await firebaseAuth.currentUser();
}
