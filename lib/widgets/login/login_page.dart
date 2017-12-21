import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';

class LoginPageViewModel {
  final Function() loginWithGoogle;
  final bool hasFirebaseUser;

  LoginPageViewModel({this.loginWithGoogle, this.hasFirebaseUser});
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, LoginPageViewModel>(
      converter: (store) {
        return new LoginPageViewModel(
          loginWithGoogle: () => store.dispatch(new DoLogIn()),
          hasFirebaseUser: store.state.firebaseState.user != null,
        );
      },
      builder: (BuildContext buildContext, LoginPageViewModel viewModel) {
        if (viewModel.hasFirebaseUser) {
          new Future.delayed(Duration.ZERO,
              () => Navigator.pushReplacementNamed(buildContext, "Main"));
        }
        return new Scaffold(
          body: new Stack(
            fit: StackFit.expand,
            children: <Widget>[
//              new Image.asset(
//                'assets/poker_case.jpg',
//                fit: BoxFit.cover,
//              ),
              new Center(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new RaisedButton(
                      color: Colors.red,
                      onPressed: () {
                        viewModel.loginWithGoogle();
                      },
                      child: new Text("Log in with Google"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
