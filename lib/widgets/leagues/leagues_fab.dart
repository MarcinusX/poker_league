import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class FoldingFloatingActionButton extends StatefulWidget {
  final Function() searchLeague;
  final Function() addLeague;

  FoldingFloatingActionButton(
      {@required this.searchLeague, @required this.addLeague});

  @override
  State<StatefulWidget> createState() {
    return new FabState();
  }
}

class FabOption {
  final String text;
  final Function() action;

  FabOption(this.text, this.action);
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
    Color backgroundColor = Theme.of(context).cardColor;
    Color foregroundColor = Theme.of(context).accentColor;

    final List<FabOption> options = [
      new FabOption("Search", widget.searchLeague),
      new FabOption("Create", widget.addLeague),
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
                  print("tapped " + options[index].text);
                  _controller.reverse();
                },
                child: new Chip(
                  label: new Text(options[index].text),
                  backgroundColor: foregroundColor,
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
  }
}
