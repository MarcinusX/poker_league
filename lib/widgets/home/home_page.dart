import 'package:flutter/material.dart';
import 'package:poker_league/widgets/main/main_page.dart';

class HomePage extends StatelessWidget implements FabActionProvider {
  @override
  Widget build(BuildContext context) {
    return new Center(child: new Text("Home"));
  }

  @override
  get onFabPressed => null;
}
