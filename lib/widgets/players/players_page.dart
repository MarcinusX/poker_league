
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/widgets/players/league_player_item.dart';

class ViewModel {
  final List<Player> players;

  ViewModel({this.players});
}

class PlayersPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(
      converter: (store) {
        return new ViewModel(
            players: store.state.activeLeague?.players ?? [],
        );
      },
      builder: (context, viewModel) {
        return new ListView.builder(
          itemCount: viewModel.players.length,
          itemBuilder: (BuildContext context, int index) {
            return new InkWell(
              child: new LeaguePlayerItem(viewModel.players[index]),
              onTap: () {},
            );
          },
        );
      },
    );
  }
}

