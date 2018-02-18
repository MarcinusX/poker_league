import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/logic/redux_state.dart';

@immutable
class ViewModel {
  final String leagueName;
  final bool isLeagueValidated;

  ViewModel({this.leagueName, this.isLeagueValidated});
}

class JoinLeagueDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new JoinLeagueDialogState();
  }
}

class JoinLeagueDialogState extends State<JoinLeagueDialog> {
  TextEditingController _nameController;
  TextEditingController _passwordController;
  String leagueName;

  @override
  void initState() {
    super.initState();
    _nameController = new TextEditingController();
    _passwordController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(converter: (store) {
      return new ViewModel();
    }, builder: (context, vm) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Join league"),
        ),
        body: new Column(
          children: <Widget>[
            new Padding(
              padding:
              new EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: new TextField(
                obscureText: true,
                decoration: new InputDecoration(
                    labelText: "League password", icon: new Icon(Icons.lock)),
                controller: _passwordController,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _leagueSearchWidget(BuildContext context, ViewModel vm) {
    return new Column(
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: new TextField(
            decoration: new InputDecoration(
                labelText: "League name", icon: new Icon(Icons.subject)),
            controller: _nameController,
          ),
        ),
        new RaisedButton(
          onPressed: () {},
          child: new Text("Find league"),
        )
      ],
    );
  }
}
