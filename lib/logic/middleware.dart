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
  @required SharedPreferences sharedPrefs,
}) {
  final logIn = _createLogIn(googleSignIn, firebaseAuth);
  final onLoginSuccess = _createOnLogInSuccess(firestore);
  final onInit = _createTryToLoginInBackground(firebaseAuth);
  final createLeague = _createCreateLeague(firestore);
  final setActiveLeague = _createSetActiveLeague(sharedPrefs);
  return combineTypedMiddleware([
    new MiddlewareBinding<ReduxState, DoLogIn>(logIn),
    new MiddlewareBinding<ReduxState, OnLoggedInSuccessful>(onLoginSuccess),
    new MiddlewareBinding<ReduxState, InitAction>(onInit),
    new MiddlewareBinding<ReduxState, CreateLeagueAction>(createLeague),
    new MiddlewareBinding<ReduxState, SetActiveLeagueAction>(setActiveLeague)
  ]);
}

_createSetActiveLeague(SharedPreferences sharedPrefs) {
  return (Store<ReduxState> store, SetActiveLeagueAction action,
      NextDispatcher next) {
    sharedPrefs.setString("ActiveLeague", action.leagueName);
    store.dispatch(new LoadActiveLeagueNameFromSP());
    next(action);
  };
}

Future _createLeague(Firestore firestore, String userUid, String displayName,
    CreateLeagueAction action) async {
  String leagueName = action.league.name;
  await firestore
      .document("leagues/$leagueName")
      .setData(action.league.toJson());
  await firestore
      .collection("leagues/$leagueName/players")
      .add(new Player(uid: userUid, name: displayName).toJson());
}

_createCreateLeague(Firestore firestore) {
  return (Store<ReduxState> store, CreateLeagueAction action,
      NextDispatcher next) {
    _createLeague(
        firestore,
        store.state.firebaseState.user.uid,
        store.state.firebaseState.googleSignIn.currentUser.displayName,
        action).then((nil) {
      store.dispatch(new SetActiveLeagueAction(action.league.name));
    });
    next(action);
  };
}

_createTryToLoginInBackground(FirebaseAuth firebaseAuth) {
  return (Store<ReduxState> store, action, NextDispatcher next) {
    next(action);

    store.state.firebaseState.firebaseAuth.currentUser().then((user) {
      if (user != null) {
        store.dispatch(new OnLoggedInSuccessful(user));
      }
    });
  };
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

  if (action is SetActiveLeagueAction) {
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
