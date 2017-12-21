import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

class InitAction {
  final FirebaseDatabase firebaseDatabase;
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  InitAction({this.firebaseDatabase, this.firebaseAuth, this.googleSignIn});
}

class DoLogIn {
}

class OnLoggedInSuccessful {
  final FirebaseUser firebaseUser;

  OnLoggedInSuccessful(this.firebaseUser);
}

class ChangeMainPage {
  final MainPageState mainPageState;

  ChangeMainPage(this.mainPageState);
}

class AddPlayerToLeague {
  final Player player;

  AddPlayerToLeague(this.player);
}

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
  final Checkout checkout;

  DoCheckout(this.player, this.checkout);
}