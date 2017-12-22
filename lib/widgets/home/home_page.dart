import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/widgets/main/main_page.dart';

class _ViewModel {
  final bool areThereAnyLeagues;

  _ViewModel({this.areThereAnyLeagues});
}

class HomePage extends StatelessWidget implements FabActionProvider {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, _ViewModel>(
      converter: (store) {
        return new _ViewModel(
          areThereAnyLeagues: store.state.availableLeagues.isNotEmpty,
        );
      },
      builder: (context, viewModel) {
        if (!viewModel.areThereAnyLeagues) {
          return new Column(
            children: <Widget>[
              new Text("Looks you are not part of any league!"),
              new RaisedButton(onPressed: () {},
                child: new Text("Create new league!"),),
              new Text("or"),
              new RaisedButton(onPressed: null,
                child: new Text("Join other league!"),),
            ],
          );
        } else {
          return new Center(child: new Text("Home"));
        }
      },
    );

  }

  @override
  get onFabPressed => null;
}
