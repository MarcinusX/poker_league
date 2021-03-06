import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/league.dart';

@immutable
class ViewModel {
  final String leagueName;
  final League league;
  final bool isLeagueValid;
  final bool didPasswordFail;
  final String currentPlayerUid;

  final Function(String) findLeague;
  final Function(String, League) tryJoiningLeague;

  ViewModel({
    @required this.leagueName,
    @required this.league,
    @required this.isLeagueValid,
    @required this.findLeague,
    @required this.currentPlayerUid,
    @required this.tryJoiningLeague,
    @required this.didPasswordFail,
  });
}

class JoinLeaguePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new JoinLeaguePageState();
  }
}

class JoinLeaguePageState extends State<JoinLeaguePage> {
  TextEditingController _nameController;
  TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(
      converter: (store) {
        return new ViewModel(
          leagueName: store.state.joinLeaguePageState.chosenLeagueName,
          league: store.state.joinLeaguePageState.league,
          isLeagueValid: store.state.joinLeaguePageState.isLeagueValidated,
          currentPlayerUid: store.state.firebaseUser.uid,
          didPasswordFail: store.state.joinLeaguePageState.didPasswordFail,
          findLeague: (leagueName) =>
              store.dispatch(new FindLeagueToJoinAction(leagueName)),
          tryJoiningLeague: (password, league) =>
              store.dispatch(new TryJoiningLeagueAction(league, password)),
        );
      },
      onInit: (store) {
        _nameController = new TextEditingController();
        _passwordController = new TextEditingController();
      },
      onDispose: (store) {
        _nameController.dispose();
        _passwordController.dispose();
      },
      builder: (context, vm) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Join league"),
          ),
          body: new SingleChildScrollView(
            child: _buildBody(context, vm),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ViewModel vm) {
    if (vm.league == null) {
      return _leagueSearchWidget(context, vm);
    } else {
      return _leagueFoundWidget(context, vm);
    }
  }

  Widget _leagueFoundWidget(BuildContext context, ViewModel vm) {
    return new Center(
      child: new Column(
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.all(16.0),
            child: new Text(
              vm.league.name,
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .headline,
            ),
          ),
          new Text(
            "Players:",
            style: Theme
                .of(context)
                .textTheme
                .subhead
                .copyWith(color: Colors.grey),
          ),
          new Column(
            children: vm.league.players
                .map((p) =>
            new Text(
              p.name,
              style: Theme
                  .of(context)
                  .textTheme
                  .body1
                  .copyWith(
                  color: Colors.grey,
                  fontWeight: p.uid == vm.currentPlayerUid
                      ? FontWeight.bold
                      : FontWeight.normal),
            ))
                .toList(),
          ),
          _inputPasswordWidget(context, vm),
        ],
      ),
    );
  }

  Widget _inputPasswordWidget(BuildContext context, ViewModel vm) {
    if (vm.league.players.any((p) => p.uid == vm.currentPlayerUid)) {
      return new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Text(
          "You are a member of this league.",
          style:
          Theme
              .of(context)
              .textTheme
              .subhead
              .copyWith(color: Colors.green),
        ),
      );
    } else {
      return new Column(
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: new TextField(
              obscureText: true,
              decoration: new InputDecoration(
                  labelText: "League password",
                  icon: new Icon(Icons.lock),
                  errorText: (vm.didPasswordFail ?? false)
                      ? "Incorrect password"
                      : null),
              controller: _passwordController,
            ),
          ),
          new Padding(
            padding: new EdgeInsets.all(16.0),
            child: new RaisedButton(
              color: Theme
                  .of(context)
                  .primaryColor,
              onPressed: () {
                vm.tryJoiningLeague(_passwordController.text, vm.league);
              },
              child: new Text(
                "JOIN LEAGUE",
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.white),
              ),
            ),
          )
        ],
      );
    }
  }

  Widget _leagueSearchWidget(BuildContext context, ViewModel vm) {
    bool isAnyText = _nameController.text.isNotEmpty;
    return new Column(
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: new TextField(
            decoration: new InputDecoration(
              labelText: "League name",
              icon: new Icon(Icons.subject),
              errorText: (vm.isLeagueValid ?? true)
                  ? null
                  : "League with that name does not exist",
            ),
            controller: _nameController,
            onChanged: (string) => setState(() {}),
          ),
        ),
        new Padding(
          padding: new EdgeInsets.all(16.0),
          child: new RaisedButton(
            color: Theme
                .of(context)
                .primaryColor,
            onPressed:
            isAnyText ? () => vm.findLeague(_nameController.text) : null,
            child: new Text(
              "FIND LEAGUE",
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }
}
