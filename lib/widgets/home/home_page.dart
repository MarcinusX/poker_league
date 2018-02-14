import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/widgets/leagues/league_dialog.dart';

class _ViewModel {
  final bool areThereAnyLeagues;
  final Function(BuildContext) openNewLeagueDialog;
  final Function(League) pushCreatedLeague;

  _ViewModel({
    this.areThereAnyLeagues,
    this.openNewLeagueDialog,
    this.pushCreatedLeague,
  });
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, _ViewModel>(
      converter: (store) {
        return new _ViewModel(
            areThereAnyLeagues: store.state.availableLeagueNames.isNotEmpty,
            openNewLeagueDialog: (BuildContext context) {
              Navigator
                  .push(
                  context,
                  new MaterialPageRoute<League>(
                      builder: (context) {
                        return new LeagueDialog();
                      },
                      fullscreenDialog: true))
                  .then((League league) {
                if (league != null) {
                  store.dispatch(new CreateLeagueAction(league));
                }
              });
            });
      },
      builder: (context, viewModel) {
        if (!viewModel.areThereAnyLeagues) {
          return new Column(
            children: <Widget>[
              new Center(
                child: new Text(
                  "Looks you are not a part of any league...",
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead,
                  textAlign: TextAlign.center,
                ),
              ),
              new Container(
                margin: new EdgeInsets.symmetric(vertical: 16.0),
                child: new RaisedButton(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  onPressed: () => viewModel.openNewLeagueDialog(context),
                  child: new Text(
                    "Create new league!",
                    style: new TextStyle(color: Colors.white),
                  ),
                ),
              ),
              new Text(
                "or",
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead,
              ),
              new Container(
                margin: new EdgeInsets.symmetric(vertical: 16.0),
                child: new RaisedButton(
                  color: Theme
                      .of(context)
                      .primaryColor,
                  onPressed: null,
                  child: new Text(
                    "Join other league!",
                    style: new TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
          );
        } else {
          return new Center(child: new Text("Home"));
        }
      },
    );
  }
}
