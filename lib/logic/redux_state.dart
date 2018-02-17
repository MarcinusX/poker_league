import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

@immutable
class ReduxState {
  final MainPageState mainPageState;
  final SessionPageState sessionPageState;

  final FirebaseUser firebaseUser;
  final Session activeSession;
  final League activeLeague;
  final String activeLeagueName;
  final List<String> availableLeagueNames;

  ReduxState({this.mainPageState = MainPageState.HOME,
    this.sessionPageState = const SessionPageState(),
    this.firebaseUser,
    this.activeSession,
    this.activeLeague,
    this.availableLeagueNames = const [],
    this.activeLeagueName,});

  ReduxState copyWith({
    MainPageState mainPageState,
    SessionPageState sessionPageState,
    FirebaseUser firebaseUser,
    Session activeSession,
    League activeLeague,
    List<String> availableLeagueNames,
    String activeLeagueName,
  }) {
    return new ReduxState(
      mainPageState: mainPageState ?? this.mainPageState,
      sessionPageState: sessionPageState ?? this.sessionPageState,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      activeSession: activeSession ?? this.activeSession,
      activeLeague: activeLeague ?? this.activeLeague,
      availableLeagueNames: availableLeagueNames ?? this.availableLeagueNames,
      activeLeagueName: activeLeagueName ?? this.activeLeagueName,
    );
  }

  Player get currentPlayer =>
      activeLeague?.players?.singleWhere((p) =>
      p?.uid == firebaseUser.uid);
}

class SessionPageState {
  final Map<Player, bool> playersExpanded;

  const SessionPageState({this.playersExpanded = const {}});

  SessionPageState.withSession(SessionPageState old, Session session)
      : playersExpanded = new Map.fromIterable(
    session.playerSessions.keys,
    key: (player) => player,
    value: (player) => old.playersExpanded[player] ?? false,
  );

  SessionPageState copyWith({Map<Player, bool> playersExpanded}) {
    return new SessionPageState(
      playersExpanded: playersExpanded ?? this.playersExpanded,
    );
  }
}

enum MainPageState {
  HOME,
  SESSIONS,
  PLAYERS,
  LEAGUES,
}
