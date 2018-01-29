import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Middleware<ReduxState>> createMiddleware({
  @required Firestore firestore,
  @required GoogleSignIn googleSignIn,
  @required FirebaseAuth firebaseAuth,
}) {
  final logIn = _createLogIn(googleSignIn, firebaseAuth);
  final onLoginSuccess = _createOnLogInSuccess(firestore);
  return combineTypedMiddleware([
    new MiddlewareBinding<ReduxState, DoLogIn>(logIn),
    new MiddlewareBinding<ReduxState, OnLoggedInSuccessful>(onLoginSuccess),
  ]);
}

_createOnLogInSuccess(Firestore firestore) {
  return (Store<ReduxState> store, action, NextDispatcher next) {
    String userId = store.state.firebaseState.user.uid;
    firestore
        .collection("users/$userId/leagues")
        .snapshots
        .listen((event) =>
        store.dispatch(new UserLeaguesUpdated(event.documents.map(
                (DocumentSnapshot documentSnapshot) =>
            documentSnapshot.documentID))));
    next(action);
  };
}

middleware(Store<ReduxState> store, action, NextDispatcher next) {
  print(action.runtimeType);

  if (action is CreateLeagueAction) {
    DatabaseReference mainReference =
    store.state.firebaseState.firebaseDatabase.reference();
    store.dispatch(new SetActiveLeagueAction(action.league.name));
    mainReference
        .child("leagues")
        .child(action.league.name)
        .set(action.league.toJson())
        .then((nil) {
      mainReference
          .child("leagues")
          .child(action.league.name)
          .child("players")
          .push()
          .set(
        new Player(
          uid: store.state.firebaseState.user.uid,
          name: store
              .state.firebaseState.googleSignIn.currentUser.displayName,
        )
            .toJson(),
      );
      mainReference
          .child("players")
          .child(store.state.firebaseState.user.uid)
          .child("leagues")
          .child(action.league.name)
          .set(action.league.name);
    });
  } else if (action is SetActiveLeagueAction) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("ActiveLeague", action.leagueName);
      store.dispatch(new LoadActiveLeagueNameFromSP());
    });
  } else if (action is LoadActiveLeagueNameFromSP) {
    SharedPreferences.getInstance().then((prefs) {
      String activeLeagueName = prefs.getString("ActiveLeague");
      if (activeLeagueName != null) {
        store.dispatch(new OnActiveLeagueNameProvided(activeLeagueName));
      }
    });
  } else if (action is OnActiveLeagueNameProvided) {
    String oldActiveLeagueName = store.state.activeLeague?.name;
    DatabaseReference mainReference = store.state.mainReference;
    if (oldActiveLeagueName != null) {
      //clear listener
      mainReference
          .child("leagues")
          .child(oldActiveLeagueName)
          .onValue
          .listen(null);
    }

    mainReference
        .child("leagues")
        .child(action.leagueName)
        .onValue
        .listen((event) {
      store.dispatch(new OnActiveLeagueUpdated(event));
    });
  } else if (action is AddPlayerToLeague) {
    store.state.mainReference
        .child("leagues")
        .child(store.state.activeLeagueName)
        .child("players")
        .push()
        .set(action.player.toJson());
  } else if (action is AddSession) {
    store.state.mainReference
        .child("leagues")
        .child(store.state.activeLeagueName)
        .child("sessions")
        .push()
        .set(action.session.toJson());
  } else if (action is DoBuyIn) {
    store.state.mainReference
        .child("leagues")
        .child(store.state.activeLeagueName)
        .child("sessions")
        .child(store.state.activeSession.key)
        .child("playerSessions")
        .child(action.player.key)
        .child("buyIns")
        .push()
        .set(action.buyIn.toJson());
  } else if (action is DoCheckout) {
    store.state.mainReference
        .child("leagues")
        .child(store.state.activeLeagueName)
        .child("sessions")
        .child(store.state.activeSession.key)
        .child("playerSessions")
        .child(action.player.key)
        .child("checkout")
        .set(action.checkout.toJson());
  }
  next(action);
  if (action is InitAction) {
    _tryLogInInBackground(store);
    store.dispatch(new LoadActiveLeagueNameFromSP());
  }
}

_tryLogInInBackground(Store<ReduxState> store) async {
  FirebaseUser user =
  await store.state.firebaseState.firebaseAuth.currentUser();
  if (user != null) {
    store.dispatch(new OnLoggedInSuccessful(user));
  }
}

_createLogIn(GoogleSignIn googleSignIn, FirebaseAuth firebaseAuth) {
  return (Store<ReduxState> store, action, NextDispatcher next) {
    _logIn(googleSignIn, firebaseAuth).then((firebaseUser) =>
        store.dispatch(new OnLoggedInSuccessful(firebaseUser)));
    next(action);
  };
}

Future<FirebaseUser> _logIn(GoogleSignIn googleSignIn,
    FirebaseAuth firebaseAuth) async {
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
  }
  return await firebaseAuth.currentUser();
}
