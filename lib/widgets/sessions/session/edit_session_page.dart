import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

class ViewModel {
  final Session session;
  final List<Player> playersAbleToAdd;
  final Function(Player) removePlayerFromSession;
  final Function(Player) addPlayterToSession;
  final Player playerToBeAdded;

  ViewModel(
      {this.session,
      this.playersAbleToAdd,
      this.removePlayerFromSession,
      this.addPlayterToSession,
      this.playerToBeAdded});
}

class EditSessionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new EditSessionPageState();
  }
}

class EditSessionPageState extends State<EditSessionPage> {
  Player playerToBeAdded;

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(
      converter: (store) {
        List<Player> allPlayers = store.state.activeLeague.players;
        List<Player> chosenPlayers =
            store.state.activeSession.playerSessions.keys.toList();
        List<Player> availablePlayers =
            allPlayers.where((p) => !chosenPlayers.contains(p)).toList();
        return new ViewModel(
          session: store.state.activeSession,
          playersAbleToAdd: availablePlayers,
          removePlayerFromSession: (player) =>
              store.dispatch(new RemovePlayerFromSession(player)),
          addPlayterToSession: (player) =>
              store.dispatch(new AddPlayerToSession(player)),
        );
      },
      builder: (BuildContext context, ViewModel vm) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Edit session"),
          ),
          body: new SingleChildScrollView(
            child: new Column(
              children: [
                new ListView(
                  children: vm.session.playerSessions.keys.map((player) {
                    bool hasBoughtIn =
                        vm.session.playerSessions[player].buyIns.isNotEmpty;
                    return new ListTile(
                      title: new Text(player.name),
                      trailing: (hasBoughtIn
                          ? new Padding(
                        padding: new EdgeInsets.only(right: 16.0),
                        child: new Text(
                            vm.session.playerSessions[player].balance
                                .toString()),
                      )
                          : new IconButton(
                              icon: new Icon(Icons.delete),
                              onPressed: () =>
                                  vm.removePlayerFromSession(player),
                            )),
                    );
                  }).toList(),
                  shrinkWrap: true,
                ),
                (vm.playersAbleToAdd.isEmpty
                    ? new Container()
                    : new ListTile(
                        title: new DropdownButtonHideUnderline(
                          child: new DropdownButton<Player>(
                            value: playerToBeAdded,
                            hint: new Text("Pick player to be added"),
                            items: vm.playersAbleToAdd.map((Player player) {
                              return new DropdownMenuItem<Player>(
                                value: player,
                                child: new Text(player.name),
                              );
                            }).toList(),
                            onChanged: (player) =>
                                setState(() => playerToBeAdded = player),
                          ),
                        ),
                        trailing: new IconButton(
                          icon: new Icon(Icons.add),
                          onPressed: (playerToBeAdded == null
                              ? null
                              : () =>
                              setState(() {
                                vm.addPlayterToSession(playerToBeAdded);
                                playerToBeAdded = null;
                              })),
                        ),
                      ))
              ],
            ),
          ),
        );
      },
    );
  }
}
