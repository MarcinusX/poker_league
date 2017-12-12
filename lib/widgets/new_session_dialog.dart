import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

class NewSessionDialog extends StatefulWidget {
  final List<Player> availablePlayers;

  NewSessionDialog({this.availablePlayers});

  @override
  State<NewSessionDialog> createState() {
    return new NewSessionDialogState();
  }
}

class NewSessionDialogState extends State<NewSessionDialog> {
  TextEditingController _textController;
  DateTime _dateTime = new DateTime.now();
  List<Player> chosenPlayers = [];
  Player activePlayer;

  @override
  void initState() {
    super.initState();
    _textController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    List<Player> playersAbleToAdd = widget.availablePlayers
        .where((player) => !chosenPlayers.contains(player))
        .toList();
    if (activePlayer == null && playersAbleToAdd.isNotEmpty) {
      activePlayer = playersAbleToAdd.first;
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("New session"),
        actions: [
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(new Session(
                dateTime: _dateTime,
                location: _textController.text,
                players: chosenPlayers)),
            child: new Text(
              "CREATE",
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      body: new SingleChildScrollView(
        child: new Column(
          children: [
            new ListTile(
              leading: new Icon(Icons.today, color: Colors.grey[500]),
              title: new Text(new DateFormat('EEEE, MMMM d').format(_dateTime)),
              onTap: () =>
                  _showDatePicker(context, _dateTime).then((DateTime dateTime) {
                    if (dateTime != null) {
                      setState(() => _dateTime = dateTime);
                    }
                  }),
            ),
            new Divider(),
            new Padding(
              padding: new EdgeInsets.symmetric(horizontal: 4.0),
              child: new TextField(
                decoration: new InputDecoration(
                    labelText: "Location", icon: new Icon(Icons.map)),
                controller: _textController,
              ),
            ),
            new Divider(),
            new ListView(
              children: chosenPlayers.map((player) {
                return new ListTile(
                  title: new Text(player.name),
                  trailing: new IconButton(
                    icon: new Icon(Icons.delete),
                    onPressed: () =>
                        setState(() => chosenPlayers.remove(player)),
                  ),
                );
              }).toList(),
              shrinkWrap: true,
            ),
            (playersAbleToAdd.isEmpty
                ? new Container()
                : new ListTile(
                    title: new DropdownButtonHideUnderline(
                      child: new DropdownButton<Player>(
                        value: activePlayer,
                        items: playersAbleToAdd.map((Player player) {
                          return new DropdownMenuItem<Player>(
                            value: player,
                            child: new Text(player.name),
                          );
                        }).toList(),
                        onChanged: (player) =>
                            setState(() => activePlayer = player),
                      ),
                    ),
                    trailing: new IconButton(
                      icon: new Icon(Icons.add),
                      onPressed: () => setState(() {
                            chosenPlayers.add(activePlayer);
                            activePlayer = null;
                          }),
                    ),
                  ))
          ],
        ),
      ),
    );
  }
}

Future<DateTime> _showDatePicker(BuildContext context, DateTime date) async {
  return showDatePicker(
      context: context,
      initialDate: date,
      firstDate: date.subtract(const Duration(days: 14)),
      lastDate: date.add(const Duration(days: 14)));
}
