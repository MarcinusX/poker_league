import 'package:firebase_database/firebase_database.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

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
        players = snapshot.value["players"].keys
            .map(
              (key) =>
          new Player.fromFirebaseDynamic(snapshot.value["players"][key])
            ..key = key,
        )
            .toList() {
    print(players);
  }

  dynamic toJson() {
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
    };
  }
}
