import 'package:flutter/material.dart';
import 'package:poker_league/models/league.dart';

class LeagueDialog extends StatelessWidget {
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("New league"),
        actions: [
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(
                new League(_nameController.text, _passwordController.text)),
            child: new Text("CREATE"),
          ),
        ],
      ),
      body: new Column(
        children: <Widget>[
          new TextField(
            decoration: new InputDecoration(labelText: "League name"),
            controller: _nameController,
          ),
          new TextField(
            decoration: new InputDecoration(labelText: "League password"),
            controller: _passwordController,
          )
        ],
      ),
    );
  }
}
