import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/widgets/leagues/join_league_page.dart';
import 'package:poker_league/widgets/leagues/new_league_dialog.dart';

class _FabOption {
  final String text;
  final Function(BuildContext) action;

  _FabOption(this.text, this.action);
}

class _ViewModel {
  final Function(BuildContext) openNewLeagueDialog;
  final Function(BuildContext) openJoinLeagueDialog;

  _ViewModel({
    @required this.openNewLeagueDialog,
    @required this.openJoinLeagueDialog,
  });
}

class FoldingFloatingActionButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new FabState();
  }
}

class FabState extends State<FoldingFloatingActionButton>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, _ViewModel>(
      converter: (store) {
        return new _ViewModel(
          openNewLeagueDialog: (BuildContext context) {
            Navigator
                .push(
                context,
                new MaterialPageRoute<League>(
                    builder: (context) {
                      return new NewLeagueDialog();
                    },
                    fullscreenDialog: true))
                .then((League league) {
              if (league != null) {
                store.dispatch(new CreateLeagueAction(league));
              }
            });
          },
          openJoinLeagueDialog: (context) {
            store.dispatch(new PrepareJoinLeaguePageAction());
            Navigator.push(context, new MaterialPageRoute<League>(
              builder: (context) {
                return new JoinLeaguePage();
              },
            ));
          },
        );
      },
      builder: (context, vm) {
        Color backgroundColor = Theme
            .of(context)
            .accentColor;

        final List<_FabOption> options = [
          new _FabOption("Join", vm.openJoinLeagueDialog),
          new _FabOption("Create", vm.openNewLeagueDialog),
        ];
        return new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: new List.generate(options.length, (int index) {
              Widget child = new Container(
                height: 60.0,
                alignment: FractionalOffset.topRight,
                child: new ScaleTransition(
                  scale: new CurvedAnimation(
                    parent: _controller,
                    curve: new Interval(0.0, 1.0 - index / options.length / 2.0,
                        curve: Curves.easeInOut),
                  ),
                  child: new GestureDetector(
                    onTap: () {
                      options[index].action(context);
                      _controller.reverse();
                    },
                    child: new Chip(
                      label: new Text(options[index].text),
                      backgroundColor: backgroundColor,
                      labelStyle: Theme
                          .of(context)
                          .textTheme
                          .subhead
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              );
              return child;
            }).toList()
              ..add(
                new FloatingActionButton(
                  key: const Key("Fab_Leagues"),
                  child: new AnimatedBuilder(
                    animation: _controller,
                    builder: (BuildContext context, Widget child) {
                      return new Transform(
                        transform: new Matrix4.rotationZ(
                            _controller.value * 0.5 * math.PI),
                        alignment: FractionalOffset.center,
                        child: new Icon(
                            _controller.isDismissed ? Icons.add : Icons.close),
                      );
                    },
                  ),
                  onPressed: () {
                    if (_controller.isDismissed) {
                      _controller.forward();
                    } else {
                      _controller.reverse();
                    }
                  },
                ),
              ));
      },
    );
  }
}
