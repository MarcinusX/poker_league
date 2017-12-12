import 'package:poker_league/models/player.dart';

class Session {
  DateTime dateTime;
  String location;
  bool isFinished;
  Map<Player, PlayerSession> playerSessions;

  Session({this.dateTime, this.location, List<Player> players})
      : playerSessions = new Map.fromIterable(
          players,
          key: (player) => player,
          value: (player) => new PlayerSession(player),
        ),
        isFinished = false;

  int get cash => playerSessions.values
      .fold(0, (sum, ps) => sum + ps.cashBuyIn - ps.cashCheckout);

  int get debt => playerSessions.values
      .fold(0, (sum, ps) => sum + ps.debtBuyIn - ps.debtCheckout);

  int get total => cash + debt;
}

class BuyIn {
  final int value;
  final bool isCash;

  BuyIn(this.value, {this.isCash = true});
}

class Checkout {
  final int cashValue;
  final Map<Player, int> debtValues;

  int get total => (cashValue ?? 0) + debtTotal;

  int get debtTotal => (debtValues == null || debtValues.isEmpty)
      ? 0
      : debtValues.values.reduce((a, b) => a + b);

  Checkout({this.cashValue, this.debtValues});
}

class PlayerSession {
  Player player;
  List<BuyIn> buyIns;
  Checkout checkout;

  PlayerSession(this.player) : buyIns = [];

  int get buyIn => buyIns.fold(0, (sum, buyIn) => sum + buyIn.value);

  int get cashBuyIn =>
      buyIns.fold(0, (sum, buyIn) => sum + (buyIn.isCash ? buyIn.value : 0));

  int get debtBuyIn =>
      buyIns.fold(0, (sum, buyIn) => sum + (buyIn.isCash ? 0 : buyIn.value));

  int get cashCheckout => checkout?.cashValue ?? 0;

  int get debtCheckout => checkout?.debtTotal ?? 0;

  int get checkoutTotal => checkout?.total ?? 0;

  int get balance => checkoutTotal - buyIn;
}
