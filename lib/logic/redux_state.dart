import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/models/session.dart';

@immutable
class ReduxState {
  final MainPageState mainPageState;
  final FirebaseState firebaseState;
  final Session activeSession;
  final League activeLeague;
  final String activeLeagueName;
  final List<String> availableLeagues;

  ReduxState({
    this.mainPageState = MainPageState.HOME,
    this.firebaseState = const FirebaseState(),
    this.activeSession,
    this.activeLeague,
    this.availableLeagues = const [],
    this.activeLeagueName,
  });

  ReduxState copyWith({
    MainPageState mainPageState,
    FirebaseState firebaseState,
    Session activeSession,
    League activeLeague,
    List<String> availableLeagues,
    String activeLeagueName,
  }) {
    return new ReduxState(
      mainPageState: mainPageState ?? this.mainPageState,
      firebaseState: firebaseState ?? this.firebaseState,
      activeSession: activeSession ?? this.activeSession,
      activeLeague: activeLeague ?? this.activeLeague,
      availableLeagues: availableLeagues ?? this.availableLeagues,
      activeLeagueName: activeLeagueName ?? this.activeLeagueName,
    );
  }

  DatabaseReference get mainReference =>
      firebaseState.firebaseDatabase.reference();
}

class FirebaseState {
  final FirebaseDatabase firebaseDatabase;
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  final FirebaseUser user;

  const FirebaseState({
    this.firebaseAuth,
    this.googleSignIn,
    this.user,
    this.firebaseDatabase,
  });

  FirebaseState copyWith({
    FirebaseDatabase firebaseDatabase,
    FirebaseAuth firebaseAuth,
    GoogleSignIn googleSignIn,
    FirebaseUser user,
  }) {
    return new FirebaseState(
      firebaseAuth: firebaseAuth ?? this.firebaseAuth,
      googleSignIn: googleSignIn ?? this.googleSignIn,
      firebaseDatabase: firebaseDatabase ?? this.firebaseDatabase,
      user: user ?? this.user,
    );
  }
}

enum MainPageState {
  HOME,
  SESSIONS,
  PLAYERS,
  LEAGUES,
}
