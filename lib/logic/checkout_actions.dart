import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

class InitCheckout {
  final Player player;
  final Session session;

  InitCheckout(this.player, this.session);
}

class ChangeTotalCheckout {
  final int value;

  ChangeTotalCheckout(this.value);
}

class ChangeCashCheckout {
  final int value;

  ChangeCashCheckout(this.value);
}

class ChangeDebtCheckout {
  final Player player;
  final int value;

  ChangeDebtCheckout(this.player, this.value);
}
