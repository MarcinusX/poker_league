import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

class SessionItem extends StatelessWidget {
  final Session session;
  final Player currentPlayer;

  SessionItem({
    @required this.session,
    @required this.currentPlayer,
  });

  @override
  Widget build(BuildContext context) {
    bool hasPlayerAttended =
    session.playerSessions.keys.contains(currentPlayer);
    int balance = session.playerSessions[currentPlayer]?.balance;
    return new ListTile(
      title: new Text("Session of " +
          new DateFormat('EEEE, MMMM d').format(session.dateTime)),
      subtitle: hasPlayerAttended
          ? null
          : new Text("You did not attend this session."),
      trailing: (session.isFinished
          ? new BalanceIcon(balance)
          : new Column(children: [
        new Icon(Icons.whatshot),
        new Text(
          "Session in on",
          style: Theme
              .of(context)
              .textTheme
              .caption,
        )
      ])
      ),
    );
  }
}

class BalanceIcon extends StatelessWidget {
  final int balance;

  BalanceIcon(this.balance);

  @override
  Widget build(BuildContext context) {
    if (balance == null) {
      return new Container();
    }
    String sign;
    Color color;
    IconData iconData;
    if (balance > 0) {
      sign = "+";
      color = Colors.green;
      iconData = Icons.trending_up;
    } else if (balance == 0) {
      sign = "";
      color = Colors.grey;
      iconData = Icons.trending_flat;
    } else {
      sign = "";
      color = Colors.red;
      iconData = Icons.trending_down;
    }
    return new Row(
      children: <Widget>[
        new Text(
          "$sign$balance",
          style: Theme
              .of(context)
              .textTheme
              .headline
              .copyWith(color: color),
        ),
        new Icon(
          iconData,
          color: color,
        ),
      ],
    );
  }
}
