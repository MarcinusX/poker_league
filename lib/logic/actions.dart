import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

// ===== INIT ======

class InitAction {
  final FirebaseDatabase firebaseDatabase;
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  InitAction({this.firebaseDatabase, this.firebaseAuth, this.googleSignIn});
}

// ===== NAVIGATION =====

class ChangeMainPage {
  final MainPageState mainPageState;

  ChangeMainPage(this.mainPageState);
}

// ===== USER ======

class DoLogIn {
}

class OnLoggedInSuccessful {
  final FirebaseUser firebaseUser;

  OnLoggedInSuccessful(this.firebaseUser);
}

class LeagueAddedToUser {
  final String leagueName;

  LeagueAddedToUser(this.leagueName);
}

// ===== ACTIVE LEAGUE NAME =====

class SetActiveLeagueAction {
  final String leagueName;

  SetActiveLeagueAction(this.leagueName);
}

class LoadActiveLeagueNameFromSP {
}

class OnActiveLeagueNameProvided {
  final String leagueName;

  OnActiveLeagueNameProvided(this.leagueName);
}

// ===== ACTIVE LEAGUE =====

class OnActiveLeagueUpdated {
  final League league;

  OnActiveLeagueUpdated(this.league);
}

class CreateLeagueAction {
  final League league;

  CreateLeagueAction(this.league);
}

class AddPlayerToLeague {
  final Player player;

  AddPlayerToLeague(this.player);
}

// ===== SESSION =====

class AddSession {
  final Session session;

  AddSession(this.session);
}

class ChooseSession {
  final Session session;

  ChooseSession(this.session);
}

class DoBuyIn {
  final Player player;
  final BuyIn buyIn;

  DoBuyIn(this.player, this.buyIn);
}

class DoCheckout {
  final Player player;
  final int checkout;

  DoCheckout(this.player, this.checkout);
}

class AddPlayerToSession {
  final Player player;

  AddPlayerToSession(this.player);
}

class RemovePlayerFromSession {
  final Player player;

  RemovePlayerFromSession(this.player);
}

class SessionSetExpandedAction {
  final Player player;
  final bool isExpanded;

  SessionSetExpandedAction(this.player, this.isExpanded);
}

class EndSessionAction {
}

class FindLeagueToJoinAction {
  final String leagueName;

  FindLeagueToJoinAction(this.leagueName);
}

class OnFindLeagueResultAction {
  final String requestedLeagueName;
  final League league;

  OnFindLeagueResultAction(this.requestedLeagueName, this.league);
}