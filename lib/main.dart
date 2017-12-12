import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/reducers/main_reducer.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/widgets/main_page.dart';
import 'package:redux/redux.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  final Store store = new Store(
    reduce,
    initialState: new ReduxState(
      mainPageState: new MainPageState(
        selectedIndex: 0,
      ),
      players: [],
      sessions: [],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        title: 'Poker League',
        theme: new ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        home: new MainPage(),
      ),
    );
  }
}
