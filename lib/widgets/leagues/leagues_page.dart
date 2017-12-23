import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/widgets/main/main_page.dart';

class _ViewModel {
  final List<String> availableLeagueNames;

  _ViewModel({this.availableLeagueNames});
}

class LeaguesPage extends StatelessWidget implements FabActionProvider {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, _ViewModel>(
      converter: (store) {
        return new _ViewModel(
          availableLeagueNames: store.state.availableLeagues,
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
              );
            },
          );
        }
      },
    );
  }

  @override
  get onFabPressed => null;
}
