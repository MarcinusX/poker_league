import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

middleware(Store<ReduxState> store, action, NextDispatcher next) {
  print(action.runtimeType);
  if (action is DoLogIn) {
    _logIn(store);
  } else if (action is OnLoggedInSuccessful) {
    DatabaseReference userReference = store.state.firebaseState.firebaseDatabase
        .reference()
        .child("players")
        .child(action.firebaseUser.uid);

    userReference
        .child("lastLogIn")
        .set(new DateTime.now().millisecondsSinceEpoch);

    userReference
        .child("leagues")
        .onChildAdded
        .listen((event) => store.dispatch(new LeagueAddedToUserAction(event)));
  } else if (action is CreateLeagueAction) {
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
          name: store.state.firebaseState.user.uid,
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
      store.dispatch(new OnActiveLeagueNameProvided(activeLeagueName));
    });
  } else if (action is OnActiveLeagueNameProvided) {
    String oldActiveLeagueName = store.state.activeLeague?.name;
    DatabaseReference mainReference =
    store.state.firebaseState.firebaseDatabase.reference();
    if (oldActiveLeagueName != null) {
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
  }
  next(action);
  if (action is InitAction) {
    _tryLogInInBackground(store);
  }
}

_tryLogInInBackground(Store<ReduxState> store) async {
  FirebaseUser user =
  await store.state.firebaseState.firebaseAuth.currentUser();
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
