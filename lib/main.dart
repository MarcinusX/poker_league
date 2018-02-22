import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/main_reducer.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/widgets/login/login_page.dart';
import 'package:poker_league/widgets/main/main_page.dart';
import 'package:redux/redux.dart';

import 'logic/middleware.dart' as middleware;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  final Store store = new Store<ReduxState>(
    reduce,
    initialState: new ReduxState(),
    middleware: middleware.createMiddleware(
        database: FirebaseDatabase.instance,
        googleSignIn: new GoogleSignIn(),
        firebaseAuth: FirebaseAuth.instance),
  );

  @override
  Widget build(BuildContext context) {
    LoginPage loginPage = new LoginPage();
    store.dispatch(new InitAction());
    return new StoreProvider(
      store: store,
      child: new MaterialApp(
        title: 'Poker League',
        theme: new ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        routes: {
          "Login": (context) => loginPage,
          "Main": (context) => new MainPage(),
        },
        home: loginPage,
      ),
    );
  }
}
