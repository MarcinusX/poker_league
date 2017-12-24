import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/widgets/main/main_page.dart';
import 'package:poker_league/widgets/players/league_player_item.dart';

class ViewModel {
  final List<Player> players;
  final Function(Player) addPlayer;
  final Function(BuildContext) openNewPlayerDialog;

  ViewModel({this.players, this.addPlayer, this.openNewPlayerDialog});
}

class FabContainer {
  Function(BuildContext) onFabPressed;
}

class PlayersPage extends StatelessWidget implements FabActionProvider {
  //just to make it final
  final FabContainer fabContainer = new FabContainer();

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(
      converter: (store) {
        return new ViewModel(
            players: store.state.activeLeague.players,
            openNewPlayerDialog: (context) {
              _openNewPlayerDialog(context).then((String name) {
                if (name != null) {
                  Player player = new Player(name: name);
                  store.dispatch(new AddPlayerToLeague(player));
                }
              });
            });
      },
      builder: (context, viewModel) {
        fabContainer.onFabPressed = viewModel.openNewPlayerDialog;
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

  @override
  get onFabPressed => fabContainer.onFabPressed;
}

Future<String> _openNewPlayerDialog(BuildContext context) async {
  final TextEditingController _controller = new TextEditingController();
  List<FlatButton> actions = [
    new FlatButton(
      child: new Text('Cancel'),
      onPressed: () => Navigator.of(context).pop(),
    ),
    new FlatButton(
      child: new Text('Add'),
      onPressed: () => Navigator.of(context).pop(_controller.text),
    ),
  ];
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    child: new AlertDialog(
      title: new Text('Add a player to the league'),
      content: new TextField(
        decoration: new InputDecoration(labelText: "Player's name"),
        controller: _controller,
      ),
      actions: actions,
    ),
  );
}
