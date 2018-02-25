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
              new Image.asset(
                "assets/login_background.jpg",
                fit: BoxFit.fitHeight,
              ),
              new Container(color: const Color(0xB0FFFFFF)),
              new Center(
                child: new SingleChildScrollView(
                  child: new Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildMainBody(context, viewModel),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Column _buildMainBody(BuildContext context, LoginPageViewModel viewModel) {
    return new Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: new Text(
            "Poker League",
            style: Theme
                .of(context)
                .textTheme
                .display1,
          ),
        ),
        new Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: new TextField(
            decoration: new InputDecoration(
              icon: new Icon(Icons.mail),
              hintText: "Email",
              border: new OutlineInputBorder(),
            ),
          ),
        ),
        new TextField(
          decoration: new InputDecoration(
            icon: new Icon(Icons.lock),
            hintText: "Password",
            border: new OutlineInputBorder(),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new RaisedButton(
            onPressed: () {},
            child: new Text(
              "REGISTER",
              style: Theme
                  .of(context)
                  .textTheme
                  .subhead
                  .copyWith(color: Colors.white),
            ),
            color: Colors.purple,
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("Already have an account?"),
              new Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: new Text(
                  "Log in",
                  style: Theme
                      .of(context)
                      .textTheme
                      .subhead
                      .copyWith(color: Colors.purple),
                ),
              ),
            ],
          ),
        ),
        new Row(
          children: <Widget>[
            new Expanded(
                child: new Divider(
                  color: Colors.black,
                )),
            new Padding(
              padding: const EdgeInsets.all(16.0),
              child: new Text("or"),
            ),
            new Expanded(child: new Divider(color: Colors.black)),
          ],
        ),
        new Row(
          children: <Widget>[
            new Expanded(
              flex: 1,
              child: new Container(),
            ),
            new Expanded(
              flex: 4,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new OAuthLoginButton(
                      onPressed: () => viewModel.loginWithGoogle(),
                      text: "Continue with Google",
                      assetName: "assets/sign-in-google.png",
                      backgroundColor: Colors.red),
                  new Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: new OAuthLoginButton(
                        onPressed: () => viewModel.loginWithFacebook(),
                        text: "Continue with Facebook",
                        assetName: "assets/sign-in-facebook.png",
                        backgroundColor: Colors.blue[700]),
                  ),
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Container(),
            ),
          ],
        ),
      ],
    );
  }
}

class OAuthLoginButton extends StatelessWidget {
  final Function() onPressed;
  final String text;
  final String assetName;
  final Color backgroundColor;

  OAuthLoginButton({@required this.onPressed,
    @required this.text,
    @required this.assetName,
    @required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return new RaisedButton(
      color: backgroundColor,
      onPressed: onPressed,
      padding: new EdgeInsets.only(right: 8.0),
      child: new Row(
        children: <Widget>[
          new Image.asset(
            assetName,
            height: 36.0,
          ),
          new Expanded(
              child: new Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: new Text(
                  text,
                  style: Theme
                      .of(context)
                      .textTheme
                      .button
                      .copyWith(color: Colors.white),
                ),
              )),
        ],
      ),
    );
  }
}
