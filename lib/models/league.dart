import 'package:firebase_database/firebase_database.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

List<Player> parsePlayersToList(Map<String, dynamic> playersMap) {
  return playersMap?.keys
      ?.map((key) =>
  new Player.fromFirebaseDynamic(playersMap[key])
    ..key = key)
      ?.toList() ??
      [];
}

Map<String, Player> parsePlayersToMap(Map<String, dynamic> playersMap) {
  return new Map.fromIterable(playersMap?.keys ?? [],
      key: (key) => key,
      value: (key) =>
      new Player.fromFirebaseDynamic(playersMap[key])
        ..key = key);
}

Map<String, Session> parseSessionsToMap(Map<String, dynamic> sessionsMap,
    Map<String, Player> playersInLeague) {
  return new Map.fromIterable(sessionsMap?.keys ?? [],
      key: (key) => key,
      value: (key) =>
      new Session.fromJson(sessionsMap[key], playersInLeague)
        ..key = key);
}

class League {
  List<Player> players;
  Map<String, Session> sessions;
  String name;
  String password;

  League(this.name, this.password)
      : players = [],
        sessions = {};

  League.fromSnapshot(DataSnapshot snapshot)
      : name = snapshot.value["name"],
        password = snapshot.value["password"],
        players = parsePlayersToList(snapshot.value["players"]),
        sessions = parseSessionsToMap(
          snapshot.value["sessions"],
          parsePlayersToMap(snapshot.value["players"]),
        );

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "password": password,
      "players": new Map.fromIterable(
        players,
        key: (player) => player.key,
        value: (player) => player.toJson(),
      ),
      "sessions": new Map.fromIterables(
          sessions.keys, sessions.values.map((session) => session.toString())),
      //TODO: Look at it
    };
  }
}
