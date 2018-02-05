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

  Map<String, dynamic> toJson() {
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

  int get cashBuyIns =>
      playerSessions.values.fold(0, (sum, ps) => sum + ps.cashBuyIn);

  int get debtBuyIns =>
      playerSessions.values.fold(0, (sum, ps) => sum + ps.debtBuyIn);

  int get buyIns => cashBuyIns + debtBuyIns;

  int get checkouts =>
      playerSessions.values.fold(0, (sum, ps) => sum + (ps.checkout ?? 0));

  int get totalOnBoard => buyIns - checkouts;
}

class BuyIn {
  String key;
  final DateTime dateTime;
  final int value;
  final bool isCash;

  BuyIn.fromJson(Map<String, dynamic> map)
      : key = map["key"],
        value = map["value"],
        isCash = map["isCash"],
        dateTime = new DateTime.fromMillisecondsSinceEpoch(map["dateTime"]);

  BuyIn(this.value, this.dateTime, {this.isCash = true});

  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "value": value,
      "isCash": isCash,
      "dateTime": dateTime.millisecondsSinceEpoch,
    };
  }
}

class PlayerSession {
  Player player;
  List<BuyIn> buyIns;
  int checkout;
  DateTime checkoutDate;

  PlayerSession(this.player) : buyIns = [];

  PlayerSession.fromJson(Map<String, dynamic> map, Map<String, Player> players)
      : player = players[map["player"]],
        buyIns = map["buyIns"]
            ?.keys
            ?.map(
              (String key) =>
          new BuyIn.fromJson(map["buyIns"][key])
            ..key = key,
        )
            ?.toList() ??
            [],
        checkout = map["checkout"],
        checkoutDate = (map.containsKey("checkoutDateTime")
            ? new DateTime.fromMillisecondsSinceEpoch(map["checkoutDateTime"])
            : null);

  dynamic toJson() {
    return {
      "player": player.key,
      "buyIns": new Map.fromIterable(
        buyIns,
        key: (buyIn) => buyIn.key,
        value: (buyIn) => buyIn.toJson(),
      ),
      "checkout": checkout,
      "checkoutDateTime": checkoutDate?.millisecondsSinceEpoch,
    };
  }

  int get buyIn => buyIns.fold(0, (sum, buyIn) => sum + buyIn.value);

  int get cashBuyIn =>
      buyIns
          .where((buyIn) => buyIn.isCash)
          .fold(0, (sum, buyIn) => sum + buyIn.value);

  int get debtBuyIn =>
      buyIns
          .where((buyIn) => !buyIn.isCash)
          .fold(0, (sum, buyIn) => sum + buyIn.value);

  int get balance => (checkout ?? 0) - buyIn;
}
