import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

@immutable
class ReduxState {
  final MainPageState mainPageState;
  final SessionPageState sessionPageState;
  final JoinLeaguePageState joinLeaguePageState;

  final FirebaseUser firebaseUser;
  final Session activeSession;
  final League activeLeague;
  final String activeLeagueName;
  final List<String> availableLeagueNames;

  //animation flags
  final bool shouldSignOut;
  final bool shouldLogIn;

  ReduxState({
    this.mainPageState = MainPageState.HOME,
    this.sessionPageState = const SessionPageState(),
    this.firebaseUser,
    this.activeSession,
    this.activeLeague,
    this.availableLeagueNames = const [],
    this.activeLeagueName,
    this.joinLeaguePageState = const JoinLeaguePageState(),
    this.shouldLogIn,
    this.shouldSignOut,
  });

  ReduxState copyWith({
    MainPageState mainPageState,
    SessionPageState sessionPageState,
    FirebaseUser firebaseUser,
    Session activeSession,
    League activeLeague,
    List<String> availableLeagueNames,
    String activeLeagueName,
    JoinLeaguePageState joinLeaguePageState,
    bool shouldLogIn,
    bool shouldSignOut,
  }) {
    return new ReduxState(
      mainPageState: mainPageState ?? this.mainPageState,
      sessionPageState: sessionPageState ?? this.sessionPageState,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      activeSession: activeSession ?? this.activeSession,
      activeLeague: activeLeague ?? this.activeLeague,
      availableLeagueNames: availableLeagueNames ?? this.availableLeagueNames,
      activeLeagueName: activeLeagueName ?? this.activeLeagueName,
      joinLeaguePageState: joinLeaguePageState ?? this.joinLeaguePageState,
      shouldLogIn: shouldLogIn ?? this.shouldLogIn,
      shouldSignOut: shouldSignOut ?? this.shouldSignOut,
    );
  }

  Player get currentPlayer =>
      activeLeague?.players?.firstWhere((p) => p?.uid == firebaseUser.uid);
}

@immutable
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

@immutable
class JoinLeaguePageState {
  final String chosenLeagueName;
  final bool isLeagueValidated;
  final bool didPasswordFail;
  final League league;

  const JoinLeaguePageState({
    this.chosenLeagueName,
    this.isLeagueValidated,
    this.didPasswordFail,
    this.league,
  });

  JoinLeaguePageState copyWith({
    String chosenLeagueName,
    bool isLeagueValidated,
    bool didPasswordFail,
    League league,
  }) {
    return new JoinLeaguePageState(
        chosenLeagueName: chosenLeagueName ?? this.chosenLeagueName,
        isLeagueValidated: isLeagueValidated ?? this.isLeagueValidated,
        didPasswordFail: didPasswordFail ?? this.didPasswordFail,
        league: league ?? this.league);
  }
}

enum MainPageState {
  HOME,
  SESSIONS,
  PLAYERS,
  LEAGUES,
}
