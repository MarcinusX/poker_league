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
  final SessionPageState sessionPageState;

  final FirebaseState firebaseState;
  final Session activeSession;
  final League activeLeague;
  final String activeLeagueName;
  final List<String> availableLeagueNames;
  final CheckoutState checkoutState;

  ReduxState({this.mainPageState = MainPageState.HOME,
    this.sessionPageState = const SessionPageState(),
    this.firebaseState = const FirebaseState(),
    this.activeSession,
    this.activeLeague,
    this.availableLeagueNames = const [],
    this.activeLeagueName,
    this.checkoutState});

  ReduxState copyWith({
    MainPageState mainPageState,
    SessionPageState sessionPageState,
    FirebaseState firebaseState,
    Session activeSession,
    League activeLeague,
    List<String> availableLeagueNames,
    String activeLeagueName,
    CheckoutState checkoutState,
  }) {
    return new ReduxState(
      mainPageState: mainPageState ?? this.mainPageState,
      sessionPageState: sessionPageState ?? this.sessionPageState,
      firebaseState: firebaseState ?? this.firebaseState,
      activeSession: activeSession ?? this.activeSession,
      activeLeague: activeLeague ?? this.activeLeague,
      availableLeagueNames: availableLeagueNames ?? this.availableLeagueNames,
      activeLeagueName: activeLeagueName ?? this.activeLeagueName,
      checkoutState: checkoutState ?? this.checkoutState,
    );
  }

  Player get currentPlayer =>
      activeLeague?.players?.singleWhere((p) =>
      p?.uid == firebaseState.user.uid);
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

class FirebaseState {
  final GoogleSignIn googleSignIn;
  final FirebaseUser user;

  const FirebaseState({
    this.googleSignIn,
    this.user,
  });

  FirebaseState copyWith({
    FirebaseDatabase firebaseDatabase,
    FirebaseAuth firebaseAuth,
    GoogleSignIn googleSignIn,
    FirebaseUser user,
  }) {
    return new FirebaseState(
      googleSignIn: googleSignIn ?? this.googleSignIn,
      user: user ?? this.user,
    );
  }
}

class CheckoutSliderState {
  final int minValue;
  final int value;
  final int maxValue;

  CheckoutSliderState({this.minValue = 0, this.value = 0, this.maxValue = 0});

  CheckoutSliderState copyWith({int minValue, int value, int maxValue}) {
    return new CheckoutSliderState(
      minValue: minValue ?? this.minValue,
      value: value ?? this.value,
      maxValue: maxValue ?? this.maxValue,
    );
  }
}

class CheckoutState {
  final Player player;
  final Session session;
  final Map<Player, int> playerDebts;
  final Map<Player, CheckoutSliderState> checkoutsFromDebtsSliders;
  final CheckoutSliderState cashCheckoutSlider;
  final CheckoutSliderState totalCheckoutSlider;

  CheckoutState({this.checkoutsFromDebtsSliders,
    this.cashCheckoutSlider,
    this.totalCheckoutSlider,
    this.player,
    this.session,
    this.playerDebts}) {
//    if (playerDebts.isEmpty) {
//      playerDebts.addAll(new Map<Player, int>.fromIterable(
//          session.playerSessions.values.where((ps) => ps.debtBuyIn != 0),
//          key: (PlayerSession ps) => ps.player,
//          value: (PlayerSession ps) => ps.debtBuyIn));
//    }
//    if (checkoutsFromDebts.isEmpty) {
//      playerDebts.forEach(
//          (player, debt) => checkoutsFromDebts.putIfAbsent(player, () => 0));
//    }
  }

  int get moneyDeclaredToCheckout =>
      cashCheckoutSlider.value +
          (checkoutsFromDebtsSliders.isEmpty
              ? 0
              : checkoutsFromDebtsSliders.values
              .fold<int>(0, (a, b) => a + b.value));

  int get leftResources => totalCheckoutSlider.value - moneyDeclaredToCheckout;

  CheckoutState copyWith({Map<Player, CheckoutSliderState> checkoutsFromDebts,
    CheckoutSliderState cashCheckout,
    CheckoutSliderState totalCheckout}) {
    return new CheckoutState(
      checkoutsFromDebtsSliders:
      checkoutsFromDebts ?? this.checkoutsFromDebtsSliders,
      cashCheckoutSlider: cashCheckout ?? this.cashCheckoutSlider,
      totalCheckoutSlider: totalCheckout ?? this.totalCheckoutSlider,
      player: this.player,
      session: this.session,
      playerDebts: this.playerDebts,
    );
  }
}

enum MainPageState {
  HOME,
  SESSIONS,
  PLAYERS,
  LEAGUES,
}
