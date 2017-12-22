import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

@immutable
class ReduxState {
  final MainPageState mainPageState;
  final FirebaseState firebaseState;
  final List<Player> players;
  final List<Session> sessions;
  final Session activeSession;
  final League activeLeague;
  final List<String> availableLeagues;

  ReduxState({this.mainPageState = MainPageState.HOME,
    this.firebaseState = const FirebaseState(),
    this.players = const [],
    this.sessions = const [],
    this.activeSession,
    this.activeLeague,
    this.availableLeagues = const []});
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
