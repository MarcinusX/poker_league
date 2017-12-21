import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

class League {
  final List<Player> players = [];
  final List<Session> sessions = [];
  final String name;
  final String password;

  League(this.name, this.password);
}
