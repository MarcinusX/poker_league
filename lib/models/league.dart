import 'package:firebase_database/firebase_database.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

class League {
  final Map<String, Player> players = {};
  final Map<String, Session> sessions = {};
  final String name;
  final String password;

  League(this.name, this.password);

  League.fromSnapshot(DataSnapshot snapshot)
      : name = snapshot.value["name"],
        password = snapshot.value["password"] {
    print(snapshot.value["players"]);
  }

  dynamic toJson() {
    return {
      "name": name,
      "password": password,
      "players": new Map.fromIterables(
          players.keys, players.values.map((player) => player.toJson())),
      "sessions": new Map.fromIterables(
          sessions.keys, sessions.values.map((session) => session.toString())),
    };
  }
}
