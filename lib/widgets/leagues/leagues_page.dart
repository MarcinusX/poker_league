import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';

class _ViewModel {
  final List<String> availableLeagueNames;
  final String activeLeagueName;
  final Function(String) onLeagueChosen;

  _ViewModel({@required this.availableLeagueNames,
    @required this.activeLeagueName,
    @required this.onLeagueChosen});
}

class LeaguesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, _ViewModel>(
      converter: (store) {
        return new _ViewModel(
          availableLeagueNames: store.state.availableLeagueNames,
          activeLeagueName: store.state.activeLeagueName,
          onLeagueChosen: (leagueName) =>
              store.dispatch(new SetActiveLeagueAction(leagueName)),
        );
      },
      builder: (context, vm) {
        if (vm.availableLeagueNames.isEmpty) {
          return new Center(
            child: new Text("Emptyy"),
          );
        } else {
          return new ListView(
            children: vm.availableLeagueNames.map((name) {
              return new RadioListTile(
                value: name,
                groupValue: vm.activeLeagueName,
                title: new Text(
                  name,
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(
                      fontWeight: name == vm.activeLeagueName
                          ? FontWeight.bold
                          : FontWeight.normal),
                ),
                subtitle: name == vm.activeLeagueName ? new Text(
                    "Current league") : null,
                onChanged: (val) => vm.onLeagueChosen(val),
              );
            }).toList(),
          );
        }
      },
    );
  }
}
