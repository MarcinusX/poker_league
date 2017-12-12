import 'package:flutter/material.dart';
import 'package:poker_league/models/player.dart';

class LeaguePlayerItem extends StatelessWidget {
  final Player player;

  LeaguePlayerItem(this.player);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(
        player.name,
        style: Theme.of(context).textTheme.headline,
      ),
      trailing: new Text(
        player.leagueBalance.toString(),
        style: Theme.of(context).textTheme.subhead,
      ),
    );
  }
}
