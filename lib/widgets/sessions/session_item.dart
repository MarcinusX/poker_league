import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poker_league/models/session.dart';

class SessionItem extends StatelessWidget {
  final Session session;

  SessionItem(this.session);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      title: new Text(
        new DateFormat('EEEE, MMMM d').format(session.dateTime),
        style: Theme.of(context).textTheme.headline,
      ),
    );
  }
}
