import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/models/player.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String PLAYERS = "players";
const String LEAGUES = "leagues";
const String LEAGUES_PLAYERS = "players";
const String SESSIONS = "sessions";
const String PLAYER_SESSIONS = "playerSessions";
const String BUYINS = "buyIns";
const String LEAGUES_IN_PLAYER = "leagues";

List<Middleware<ReduxState>> createMiddleware({
  @required FirebaseDatabase database,
  @required GoogleSignIn googleSignIn,
  @required FirebaseAuth firebaseAuth,
}) {
  final logIn = _createLogIn(googleSignIn, firebaseAuth);
  final onLoginSuccess = _createOnLogInSuccess(database);
  final onInit = _createTryToLoginInBackground(firebaseAuth);
  final createLeague = _createCreateLeague(database);
  final setActiveLeague = _createSetActiveLeague();
  final loadActiveLeague = _createLoadActiveLeague();
  final onActiveLeagueProvided = _createOnActiveLeagueProvided(database);
  final addSession = _createAddSession(database);
  final buyIn = _createBuyIn(database);
  final checkout = _createCheckout(database);
  final addPlayerToLeague = _createAddPlayerToLeague(database);
  final addPlayerToSession = _createAddPlayerToSession(database);
  final removePlayerFromSession = _createRemovePlayerFromSession(database);
  final finishSession = _createFinishSession(database);
  final findLeagueName = _createFindLeagueName(database);
  final tryJoiningLeague = _createTryJoiningLeague(database);
  return combineTypedMiddleware([
    new MiddlewareBinding<ReduxState, DoLogIn>(logIn),
    new MiddlewareBinding<ReduxState, OnLoggedInSuccessful>(onLoginSuccess),
    new MiddlewareBinding<ReduxState, InitAction>(onInit),
    new MiddlewareBinding<ReduxState, CreateLeagueAction>(createLeague),
    new MiddlewareBinding<ReduxState, SetActiveLeagueAction>(setActiveLeague),
    new MiddlewareBinding<ReduxState, LoadActiveLeagueNameFromSP>(
        loadActiveLeague),
    new MiddlewareBinding<ReduxState, OnActiveLeagueNameProvided>(
        onActiveLeagueProvided),
    new MiddlewareBinding<ReduxState, AddPlayerToLeague>(addPlayerToLeague),
    new MiddlewareBinding<ReduxState, AddSession>(addSession),
    new MiddlewareBinding<ReduxState, DoBuyIn>(buyIn),
    new MiddlewareBinding<ReduxState, DoCheckout>(checkout),
    new MiddlewareBinding<ReduxState, AddPlayerToSession>(addPlayerToSession),
    new MiddlewareBinding<ReduxState, RemovePlayerFromSession>(
        removePlayerFromSession),
    new MiddlewareBinding<ReduxState, EndSessionAction>(finishSession),
    new MiddlewareBinding<ReduxState, FindLeagueToJoinAction>(findLeagueName),
    new MiddlewareBinding<ReduxState, TryJoiningLeagueAction>(tryJoiningLeague),
  ]);
}

_createTryJoiningLeague(FirebaseDatabase database) {
  return (Store<ReduxState> store, TryJoiningLeagueAction action,
      NextDispatcher next) {
    if (action.password == action.league.password) {
      store.dispatch(new AddPlayerToLeague(new Player(
          uid: store.state.firebaseUser.uid,
          name: store.state.firebaseUser.displayName), action.league.name));
      store.dispatch(new FindLeagueToJoinAction(action.league.name));
    } else {
      store.dispatch(new OnJoiningLeagueFailedAction());
    }
  };
}

_createFindLeagueName(FirebaseDatabase database) {
  return (Store<ReduxState> store, FindLeagueToJoinAction action,
      NextDispatcher next) {
    String leagueName = action.leagueName;
    database
        .reference()
        .child("$LEAGUES/$leagueName")
        .once()
        .then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value == null) {
        store.dispatch(new OnFindLeagueResultAction(leagueName, null));
      } else {
        store.dispatch(new OnFindLeagueResultAction(
            leagueName, new League.fromMap(dataSnapshot.value)));
      }
    });
  };
}

_createFinishSession(FirebaseDatabase database) {
  return (Store<ReduxState> store, EndSessionAction action,
      NextDispatcher next) {
    String activeLeagueName = store.state.activeLeagueName;
    String activeSessionKey = store.state.activeSession.key;
    database
        .reference()
        .child(
        "$LEAGUES/$activeLeagueName/$SESSIONS/$activeSessionKey/isFinished")
        .set(true);
  };
}

_createRemovePlayerFromSession(FirebaseDatabase database) {
  return (Store<ReduxState> store, RemovePlayerFromSession action,
      NextDispatcher next) {
    String activeLeagueName = store.state.activeLeagueName;
    String activeSessionKey = store.state.activeSession.key;
    String playerKey = action.player.key;
    database
        .reference()
        .child(
        "$LEAGUES/$activeLeagueName/$SESSIONS/$activeSessionKey/$PLAYER_SESSIONS/$playerKey")
        .remove();
  };
}

_createAddPlayerToSession(FirebaseDatabase database) {
  return (Store<ReduxState> store, AddPlayerToSession action,
      NextDispatcher next) {
    String activeLeagueName = store.state.activeLeagueName;
    String activeSessionKey = store.state.activeSession.key;
    String playerKey = action.player.key;
    database
        .reference()
        .child(
        "$LEAGUES/$activeLeagueName/$SESSIONS/$activeSessionKey/$PLAYER_SESSIONS/$playerKey")
        .set({"player": playerKey});
  };
}

_createAddPlayerToLeague(FirebaseDatabase database) {
  return (Store<ReduxState> store, AddPlayerToLeague action,
      NextDispatcher next) {
    _addPlayerToLeague(database, action.player, action.leagueName).then((
        leagueName) {
      if (action.player.uid != null) {
        //it means that you are using your own account
        store.dispatch(new SetActiveLeagueAction(leagueName));
      }
    });
    next(action);
  };
}

Future<String> _addPlayerToLeague(FirebaseDatabase database, Player player,
    String leagueName) async {
  await database
      .reference()
      .child("$LEAGUES/$leagueName/$LEAGUES_PLAYERS")
      .push()
      .set(player.toJson());
  if (player.uid != null) {
    String playerUid = player.uid;
    await database
        .reference()
        .child("$PLAYERS/$playerUid/$LEAGUES_IN_PLAYER/$leagueName")
        .set(leagueName);
  }
  return leagueName;
}

_createBuyIn(FirebaseDatabase database) {
  return (Store<ReduxState> store, DoBuyIn action, NextDispatcher next) {
    String leagueName = store.state.activeLeagueName;
    String sessionKey = store.state.activeSession.key;
    String playerKey = action.player.key;
    database
        .reference()
        .child("$LEAGUES/$leagueName/$SESSIONS/$sessionKey/"
        "$PLAYER_SESSIONS/$playerKey/$BUYINS")
        .push()
        .set(action.buyIn.toJson());

    next(action);
  };
}

_createCheckout(FirebaseDatabase database) {
  return (Store<ReduxState> store, DoCheckout action, NextDispatcher next) {
    String leagueName = store.state.activeLeagueName;
    String sessionKey = store.state.activeSession.key;
    String playerKey = action.player.key;
    DatabaseReference playerSessionRef = database.reference().child(
        "$LEAGUES/$leagueName/$SESSIONS/$sessionKey/$PLAYER_SESSIONS/$playerKey");
    playerSessionRef.child("checkout").set(action.checkout);
    playerSessionRef
        .child("checkoutDateTime")
        .set(new DateTime.now().millisecondsSinceEpoch);

    next(action);
  };
}

_createAddSession(FirebaseDatabase database) {
  return (Store<ReduxState> store, AddSession action, NextDispatcher next) {
    String activeLeagueName = store.state.activeLeagueName;
    database
        .reference()
        .child("$LEAGUES/$activeLeagueName/$SESSIONS")
        .push()
        .set(action.session.toJson());

    next(action);
  };
}

_createOnActiveLeagueProvided(FirebaseDatabase database) {
  return (Store<ReduxState> store, OnActiveLeagueNameProvided action,
      NextDispatcher next) {
    String oldActiveLeagueName = store.state.activeLeague?.name;
    String newLeagueName = action.leagueName;

    if (oldActiveLeagueName != null) {
      //TODO: clear listener
      database
          .reference()
          .child("$LEAGUES/$oldActiveLeagueName")
          .onValue
          .listen(null);
    }

    database
        .reference()
        .child("$LEAGUES/$newLeagueName")
        .onValue
        .listen(
            (event) =>
            store.dispatch(new OnActiveLeagueUpdated(
                new League.fromMap(event.snapshot.value))));

    next(action);
  };
}

_createLoadActiveLeague() {
  return (Store<ReduxState> store, LoadActiveLeagueNameFromSP action,
      NextDispatcher next) {
    SharedPreferences.getInstance().then((sharedPrefs) {
      String activeLeagueName = sharedPrefs.getString("ActiveLeague");
      if (activeLeagueName != null) {
        store.dispatch(new OnActiveLeagueNameProvided(activeLeagueName));
      }
    });

    next(action);
  };
}

_createSetActiveLeague() {
  return (Store<ReduxState> store, SetActiveLeagueAction action,
      NextDispatcher next) {
    SharedPreferences.getInstance().then((sharedPrefs) {
      sharedPrefs.setString("ActiveLeague", action.leagueName);
      store.dispatch(new LoadActiveLeagueNameFromSP());
    });

    next(action);
  };
}

Future _addLeague(FirebaseDatabase database, String userUid, String displayName,
    CreateLeagueAction action) async {
  String leagueName = action.league.name;
  await database
      .reference()
      .child("$LEAGUES/$leagueName")
      .set(action.league.toJson());
  _addPlayerToLeague(
      database, new Player(uid: userUid, name: displayName), leagueName);
}

_createCreateLeague(FirebaseDatabase database) {
  return (Store<ReduxState> store, CreateLeagueAction action,
      NextDispatcher next) {
    String uid = store.state.firebaseUser.uid;
    String name = store.state.firebaseUser.displayName;
    _addLeague(database, uid, name, action).then((nil) {
      store.dispatch(new SetActiveLeagueAction(action.league.name));
    });

    next(action);
  };
}

_createTryToLoginInBackground(FirebaseAuth firebaseAuth) {
  return (Store<ReduxState> store, action, NextDispatcher next) {
    next(action);

    firebaseAuth.currentUser().then((user) {
      if (user != null) {
        store.dispatch(new OnLoggedInSuccessful(user));
      }
    });

    store.dispatch(new LoadActiveLeagueNameFromSP());
  };
}

_createOnLogInSuccess(FirebaseDatabase database) {
  return (Store<ReduxState> store, OnLoggedInSuccessful action,
      NextDispatcher next) {
    String userId = action.firebaseUser.uid;
    database
        .reference()
        .child("$PLAYERS/$userId/lastLogin")
        .set(new DateTime.now().millisecondsSinceEpoch);
    database
        .reference()
        .child("$PLAYERS/$userId/$LEAGUES_IN_PLAYER")
        .onChildAdded
        .listen((event) =>
        store.dispatch(new LeagueAddedToUser(event.snapshot.key)));

    next(action);
  };
}

_createLogIn(GoogleSignIn googleSignIn, FirebaseAuth firebaseAuth) {
  return (Store<ReduxState> store, DoLogIn action, NextDispatcher next) {
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
    await firebaseAuth.updateProfile(new UserUpdateInfo()
      ..photoUrl = currentUser.photoUrl
      ..displayName = currentUser.displayName);
  }
  return await firebaseAuth.currentUser();
}
