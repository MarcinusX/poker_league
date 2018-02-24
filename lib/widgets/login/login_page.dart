import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';

class LoginPageViewModel {
  final Function() loginWithGoogle;
  final Function() loginWithFacebook;
  final Function() onMovedFromLoginPage;
  final Function() signOut;
  final bool shouldLogIn;
  final bool shouldSignOut;

  LoginPageViewModel({
    @required this.loginWithGoogle,
    @required this.loginWithFacebook,
    @required this.shouldLogIn,
    @required this.onMovedFromLoginPage,
    @required this.shouldSignOut,
    @required this.signOut,
  });
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, LoginPageViewModel>(
      converter: (store) {
        return new LoginPageViewModel(
          signOut: () => store.dispatch(new SignOutAction()),
          loginWithGoogle: () => store.dispatch(new DoGoogleLogIn()),
          loginWithFacebook: () => store.dispatch(new DoFacebookLogIn()),
          onMovedFromLoginPage: () =>
              store.dispatch(new OnMovedFromLoginPageAction()),
          shouldLogIn: store.state.shouldLogIn ?? false,
          shouldSignOut: store.state.shouldSignOut ?? false,
        );
      },
      builder: (BuildContext buildContext, LoginPageViewModel viewModel) {
        if (viewModel.shouldSignOut) {
          new Future.delayed(Duration.ZERO, () {
            viewModel.signOut();
          });
        } else if (viewModel.shouldLogIn) {
          new Future.delayed(Duration.ZERO, () {
            Navigator.pushReplacementNamed(buildContext, "Main");
            viewModel.onMovedFromLoginPage();
          });
        }
        return new Scaffold(
          body: new Stack(
            fit: StackFit.expand,
            children: <Widget>[
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
                    new RaisedButton(
                      color: Colors.blue,
                      onPressed: () {
                        viewModel.loginWithFacebook();
                      },
                      child: new Text("Log in with Facebook"),
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
