import 'dart:async';

import 'package:flutter/material.dart';

Future<String> openNewPlayerDialog(BuildContext context) async {
  final TextEditingController _controller = new TextEditingController();
  List<FlatButton> actions = [
    new FlatButton(
      child: new Text('Cancel'),
      onPressed: () => Navigator.of(context).pop(),
    ),
    new FlatButton(
      child: new Text('Add'),
      onPressed: () => Navigator.of(context).pop(_controller.text),
    ),
  ];
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    child: new AlertDialog(
      title: new Text('Add a player to the league'),
      content: new TextField(
        decoration: new InputDecoration(labelText: "Player's name"),
        controller: _controller,
      ),
      actions: actions,
    ),
  );
}
