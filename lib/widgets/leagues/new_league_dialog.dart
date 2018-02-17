import 'package:flutter/material.dart';
import 'package:poker_league/models/league.dart';

class NewLeagueDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new NewLeagueDialogState();
  }
}

class NewLeagueDialogState extends State<NewLeagueDialog> {
  TextEditingController _nameController;
  TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = new TextEditingController();
    _passwordController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("New league"),
        actions: [
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(
                new League(_nameController.text, _passwordController.text)),
            child: new Text(
              "CREATE",
              style: new TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: new Column(
        children: <Widget>[
          new Padding(
            padding: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: new TextField(
              decoration: new InputDecoration(
                  labelText: "League name", icon: new Icon(Icons.subject)),
              controller: _nameController,
            ),
          ),
          new Padding(
            padding: new EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
  }
}
