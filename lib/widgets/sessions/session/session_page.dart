import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';
import 'package:poker_league/widgets/sessions/session/buy_in_dialog.dart';
import 'package:poker_league/widgets/sessions/session/checkout_dialog.dart';
import 'package:poker_league/widgets/sessions/session/edit_session_page.dart';
import 'package:poker_league/widgets/sessions/session/timeline.dart';
import 'package:tuple/tuple.dart';

class ViewModel {
  final Session session;
  final Map<Player, bool> arePlayersExpanded;

  final Function(Player, BuyIn) doBuyIn;
  final Function(Player, int) doCheckout;
  final Function(Player, bool) setExpanded;
  final Function(Player, BuyIn) updateBuyIn;
  final Function() endSession;

  ViewModel({
    @required this.session,
    @required this.doBuyIn,
    @required this.updateBuyIn,
    @required this.doCheckout,
    @required this.arePlayersExpanded,
    @required this.setExpanded,
    @required this.endSession,
  });
}

class SessionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(
      converter: (store) {
        return new ViewModel(
          session: store.state.activeSession,
          doBuyIn: (player, buyIn) =>
              store.dispatch(new DoBuyIn(player, buyIn)),
          updateBuyIn: (player, buyIn) =>
              store.dispatch(new UpdateBuyInAction(player, buyIn)),
          doCheckout: (player, checkout) =>
              store.dispatch(new DoCheckout(player, checkout)),
          arePlayersExpanded: store.state.sessionPageState.playersExpanded,
          setExpanded: (player, isExpanded) =>
              store.dispatch(new SessionSetExpandedAction(player, isExpanded)),
          endSession: () => store.dispatch(new EndSessionAction()),
        );
      },
      builder: (context, viewModel) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Session details"),
            actions: [
              (viewModel.session.isFinished
                  ? new Container()
                  : new IconButton(
                icon: new Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) =>
                    new EditSessionPage(),
                  ));
                },
              ))
            ],
          ),
          body: new ListView(
            children: [
              new Padding(
                padding: new EdgeInsets.all(12.0),
                child: _buildStatisticsCard(context, viewModel),
              ),
              new Padding(
                padding: new EdgeInsets.all(16.0),
                child: new ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    viewModel.setExpanded(
                        viewModel.session.playerSessions.keys.toList()[index],
                        !isExpanded);
                  },
                  children: viewModel.session.playerSessions.keys
                      .map((Player player) =>
                      _createExpansionPanel(context, viewModel, player))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Card _buildStatisticsCard(BuildContext context, ViewModel viewModel) {
    return new Card(
      child: new Padding(
        padding: new EdgeInsets.all(16.0),
        child: new DefaultTextStyle(
          style: Theme
              .of(context)
              .textTheme
              .subhead,
          child: new Column(children: [
            (viewModel.session.isFinished
                ? new Center(
                child: new Padding(
                  padding: new EdgeInsets.only(bottom: 8.0),
                  child: new Text(
                    "SESSION FINISHED",
                    style: Theme
                        .of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.grey),
                  ),
                ))
                : new Container()),
            new Row(children: [
              new Expanded(child: new Text("Cash buy ins")),
              new Text(viewModel.session.cashBuyIns.toString()),
            ]),
            new Divider(height: 4.0),
            new Row(children: [
              new Expanded(child: new Text("Debt buy ins")),
              new Text(viewModel.session.debtBuyIns.toString()),
            ]),
            new Divider(height: 4.0),
            new Row(children: [
              new Expanded(child: new Text("Checkouts")),
              new Text(viewModel.session.checkouts.toString()),
            ]),
            new Divider(height: 4.0),
            new Row(children: [
              new Expanded(child: new Text("Total on board")),
              new Text(viewModel.session.totalOnBoard.toString()),
            ]),
            new Divider(height: 4.0),
            (viewModel.session.totalOnBoard != 0 || viewModel.session.isFinished
                ? new Container()
                : new Center(
              child: new Padding(
                padding: new EdgeInsets.only(top: 8.0),
                child: new RaisedButton(
                  onPressed: () => viewModel.endSession(),
                  color: Colors.green,
                  child: new Text("END SESSION"),
                ),
              ),
            )),
          ]),
        ),
      ),
    );
  }

  ExpansionPanel _createExpansionPanel(BuildContext context,
      ViewModel viewModel, Player player) {
    PlayerSession currentPlayerSession =
    viewModel.session.playerSessions[player];

    return new ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        int balance = currentPlayerSession.balance;
        return new ListTile(
          title: new Text(player.name),
          subtitle: new Text("Balance: $balance"),
        );
      },
      isExpanded: viewModel.arePlayersExpanded[player],
      body: new Column(
        children: <Widget>[
          _createExpansionPanelMainBody(
              context, viewModel, currentPlayerSession),
          (viewModel.session.isFinished
              ? new Container()
              : _createBottomOfExpansionPanel(context, viewModel, player)),
        ],
      ),
    );
  }

  Widget _createExpansionPanelMainBody(BuildContext context,
      ViewModel viewModel, PlayerSession currentPlayerSession) {
    List<Tuple2> tuples = currentPlayerSession.buyIns.map((buyIn) {
      return new Tuple2(buyIn.dateTime,
          {"buyIn": buyIn, "playerSession": currentPlayerSession});
    }).toList();

    List<Tuple2> checkoutTuples = [];

    if (currentPlayerSession.checkout != null) {
      Tuple2 checkoutTuple = new Tuple2(currentPlayerSession.checkoutDate, {
        "playerSession": currentPlayerSession,
        "checkout": currentPlayerSession.checkout,
      });
      checkoutTuples.add(checkoutTuple);
    }

    return new Padding(
      padding: new EdgeInsets.symmetric(horizontal: 16.0),
      child: new Column(
        children: [
          _createBuyInTimeLine(context, tuples, checkoutTuples,
              currentPlayerSession.player, viewModel),
          _createCheckoutTimeLine(
              context, currentPlayerSession, checkoutTuples),
        ],
      ),
    );
  }

  Widget _createCheckoutTimeLine(BuildContext context,
      PlayerSession currentPlayerSession, List<Tuple2> checkoutTuples) {
    return new TimeLine(
      items: checkoutTuples,
      dateWidgetGenerator: (DateTime dateTime) {
        return new Text(
          new DateFormat(DateFormat.HOUR24_MINUTE).format(dateTime),
          style: Theme
              .of(context)
              .textTheme
              .caption,
        );
      },
      contentWidgetGenerator: (data) {
        int checkout = data["checkout"];
        return new Row(
          children: <Widget>[
            new Expanded(
              child: new RichText(
                text: new TextSpan(
                    text: "Checkout for ",
                    style: Theme
                        .of(context)
                        .textTheme
                        .subhead,
                    children: [
                      new TextSpan(
                        text: "$checkout",
                        style: Theme
                            .of(context)
                            .textTheme
                            .subhead
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ]),
              ),
            ),
            new Text(
              (checkout - currentPlayerSession.debtBuyIn >= 0
                  ? currentPlayerSession.balance.toString()
                  : "(" +
                  (currentPlayerSession.debtBuyIn - checkout).toString() +
                  ") " +
                  currentPlayerSession.balance.toString()),
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        );
      },
      pointColor:
      (currentPlayerSession.balance < 0) ? Colors.red : Colors.green,
      endlessStart: true,
    );
  }

  Widget _createBuyInTimeLine(BuildContext context, List<Tuple2> tuples,
      List<Tuple2> checkoutTuples, Player player, ViewModel vm) {
    return new TimeLine(
      endlessEnd: checkoutTuples.isNotEmpty,
      items: tuples,
      dateWidgetGenerator: (DateTime dateTime) {
        return new Text(
          new DateFormat(DateFormat.HOUR24_MINUTE).format(dateTime),
          style: Theme
              .of(context)
              .textTheme
              .caption,
        );
      },
      contentWidgetGenerator: (data) {
        BuyIn buyIn = data["buyIn"];
        Iterable<BuyIn> buyInsAtTime = (data["playerSession"] as PlayerSession)
            .buyIns
            .where((item) => !item.dateTime.isAfter(buyIn.dateTime));
        int balanceAtTime =
        buyInsAtTime.fold(0, (int, buyIn) => int + buyIn.value);
        int debtBalanceAtTime = buyInsAtTime.fold(
            0, (int, buyIn) => int + (buyIn.isCash ? 0 : buyIn.value));
        int buyInValue = buyIn.value;
        String buyInType = buyIn.isCash ? "cash" : "debt";
        return new GestureDetector(
          onTap: () {
            if (!vm.session.isFinished) {
              showDialog(context: context, child: new BuyInDialog.edit(buyIn))
                  .then((newBuyIn) {
                if (newBuyIn != null) {
                  vm.updateBuyIn(player, newBuyIn);
                }
              });
            }
          },
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: new RichText(
                  text: new TextSpan(
                      text: "Buy in for ",
                      style: Theme
                          .of(context)
                          .textTheme
                          .subhead,
                      children: [
                        new TextSpan(
                          text: "$buyInValue",
                          style: Theme
                              .of(context)
                              .textTheme
                              .subhead
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        new TextSpan(
                          text: " in $buyInType",
                          style: Theme
                              .of(context)
                              .textTheme
                              .subhead,
                        ),
                      ]),
                ),
              ),
              new Text(
                (debtBalanceAtTime == 0
                    ? "-$balanceAtTime"
                    : "($debtBalanceAtTime) -$balanceAtTime"),
                style: Theme
                    .of(context)
                    .textTheme
                    .subhead,
              )
            ],
          ),
        );
      },
    );
  }

  Widget _createBottomOfExpansionPanel(BuildContext context,
      ViewModel viewModel, Player player) {
    return new Column(children: <Widget>[
      new Divider(
        height: 2.0,
      ),
      new ButtonTheme.bar(
        child: new ButtonBar(
          children: <Widget>[
            new FlatButton(
              onPressed: () {
                showDialog(
                    context: context,
                    child: new CheckoutDialog(
                      initialValue:
                      viewModel.session.playerSessions[player].checkout ??
                          0,
                      maxValue: viewModel.session.totalOnBoard +
                          (viewModel.session.playerSessions[player].checkout ??
                              0),
                    )).then((checkout) {
                  if (checkout != null) {
                    viewModel.doCheckout(player, checkout);
                  }
                });
              },
              child: new Text("CHECKOUT"),
            ),
            new FlatButton(
              onPressed: () {
                showDialog(context: context, child: new BuyInDialog())
                    .then((buyIn) {
                  if (buyIn != null) {
                    viewModel.doBuyIn(player, buyIn);
                  }
                });
              },
              child: new Text("BUY IN"),
            )
          ],
        ),
      ),
    ]);
  }
}
