import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';

class _ViewModel {
  final List<String> availableLeagueNames;
  final Function(String) onLeagueChosen;

  _ViewModel({this.availableLeagueNames, this.onLeagueChosen});
}

class LeaguesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, _ViewModel>(
      converter: (store) {
        return new _ViewModel(
          availableLeagueNames: store.state.availableLeagueNames,
          onLeagueChosen: (leagueName) =>
              store.dispatch(new SetActiveLeagueAction(leagueName)),
        );
      },
      builder: (context, viewModel) {
        if (viewModel.availableLeagueNames.isEmpty) {
          return new Center(
            child: new Text("Emptyy"),
          );
        } else {
          return new ListView.builder(
            itemCount: viewModel.availableLeagueNames.length,
            itemExtent: 50.0,
            itemBuilder: (context, index) {
              return new ListTile(
                title: new Text(viewModel.availableLeagueNames[index]),
                onTap: () =>
                    viewModel.onLeagueChosen(
                        viewModel.availableLeagueNames[index]),
              );
            },
          );
        }
      },
    );
  }
}
