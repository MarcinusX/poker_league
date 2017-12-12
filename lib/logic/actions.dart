import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

class ChangePageIndex {
  final int index;

  ChangePageIndex(this.index);
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
