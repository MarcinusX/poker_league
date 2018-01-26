import 'package:poker_league/models/player.dart';

class Session {
  String key;
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

  Session.fromJson(Map<String, dynamic> map, Map<String, Player> players)
      : key = map["key"],
        dateTime = new DateTime.fromMillisecondsSinceEpoch(map["dateTime"]),
        location = map["location"],
        isFinished = map["isFinished"],
        playerSessions = new Map.fromIterable(
          map["playerSessions"].keys,
          key: (key) => players[key],
          value: (key) =>
          new PlayerSession.fromJson(map["playerSessions"][key], players),
        );

  dynamic toJson() {
    return {
      "key": key,
      "dateTime": dateTime.millisecondsSinceEpoch,
      "location": location,
      "isFinished": isFinished,
      "playerSessions": new Map.fromIterable(playerSessions.keys,
          key: (Player key) => key.key,
          value: (Player key) => playerSessions[key].toJson())
    };
  }

  int get cash => playerSessions.values
      .fold(0, (sum, ps) => sum + ps.cashBuyIn - ps.cashCheckout);

  int get debt => playerSessions.values
      .fold(0, (sum, ps) => sum + ps.debtBuyIn - ps.debtCheckout);

  int get total => cash + debt;
}

class BuyIn {
  String key;
  final int value;
  final bool isCash;

  BuyIn.fromJson(Map<String, dynamic> map)
      : key = map["key"],
        value = map["value"],
        isCash = map["isCash"];

  BuyIn(this.value, {this.isCash = true});

  dynamic toJson() {
    return {
      "key": key,
      "value": value,
      "isCash": isCash,
    };
  }
}

class Checkout {
  String key;
  final int cashValue;
  final Map<Player, int> debtValues;

  Checkout({this.cashValue, this.debtValues});

  Checkout.fromJson(Map<String, dynamic> map, Map<String, Player> players)
      : key = map["key"],
        cashValue = map["cashValue"],
        debtValues = new Map.fromIterable(
          map["debtValues"]?.keys ?? [],
          key: (id) => players[id],
          value: (id) => map["debtValues"][id],
        );

  dynamic toJson() {
    return {
      "key": key,
      "cashValue": cashValue,
      "debtValues": new Map.fromIterable(
        debtValues.keys,
        key: (Player key) => key.key,
        value: (Player key) => debtValues[key],
      ),
    };
  }

  int get total => (cashValue ?? 0) + debtTotal;

  int get debtTotal => (debtValues == null || debtValues.isEmpty)
      ? 0
      : debtValues.values.reduce((a, b) => a + b);
}

class PlayerSession {
  Player player;
  List<BuyIn> buyIns;
  Checkout checkout;

  PlayerSession(this.player) : buyIns = [];

  PlayerSession.fromJson(Map<String, dynamic> map, Map<String, Player> players)
      : player = players[map["player"]],
        buyIns = map["buyIns"]?.keys?.map(
              (String key) =>
          new BuyIn.fromJson(map["buyIns"][key])
            ..key = key,
        )?.toList() ??
            [],
        checkout = map["checkout"] == null
            ? null
            : new Checkout.fromJson(map["checkout"], players);

  dynamic toJson() {
    return {
      "player": player.key,
      "buyIns": new Map.fromIterable(
        buyIns,
        key: (buyIn) => buyIn.key,
        value: (buyIn) => buyIn.toJson(),
      ),
      "checkout": checkout?.toJson(),
    };
  }

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
