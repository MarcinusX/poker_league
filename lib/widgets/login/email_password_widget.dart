import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/logic/redux_state.dart';

class EmailPasswordWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new EmailPasswordWidgetState();
  }
}

@immutable
class ViewModel {
  final Function(String, String) onLogInClick;

  ViewModel({this.onLogInClick});
}

class EmailPasswordWidgetState extends State<EmailPasswordWidget>
    with TickerProviderStateMixin {
  AnimationController _controller;
  String login;
  String password;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey = new GlobalKey<
      FormFieldState<String>>();

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(
      converter: (store) {
        return new ViewModel(
          onLogInClick: null,
        );
      },
      builder: (BuildContext context, ViewModel vm) {
        return new AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget child) {
              return new Transform(
                transform: new Matrix4.rotationY(_controller.value * math.PI),
                alignment: Alignment.center,
                child: _controller.value < 0.5
                    ? _buildFront(context, vm)
                    : new Transform(
                        transform:
                            new Matrix4.rotationY(_controller.value * math.PI),
                        alignment: Alignment.center,
                        child: _buildBack(context, vm)),
              );
            });
      },
    );
  }

  Widget _buildFront(BuildContext context, ViewModel vm) {
    return new Column(
      children: <Widget>[
        _buildInputs(context, vm),
        _buildRegisterButton(context, vm),
        new Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("Already have an account?"),
              new FlatButton(
                onPressed: () => _controller.forward(),
                child: new Text(
                  "Log in",
                  style: Theme
                      .of(context)
                      .textTheme
                      .button
                      .copyWith(color: Colors.purple),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBack(BuildContext context, ViewModel vm) {
    return new Column(
      children: <Widget>[
        _buildInputs(context, vm),
        _buildLogInButton(context, vm),
        new Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text("Don't have an account?"),
              new FlatButton(
                onPressed: () {
                  _controller.reverse();
                },
                child: new Text(
                  "Register",
                  style: Theme
                      .of(context)
                      .textTheme
                      .button
                      .copyWith(color: Colors.purple),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogInButton(BuildContext context, ViewModel vm) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new RaisedButton(
        onPressed: () => _handleSubmitted(vm),
        child: new Text(
          "LOG IN",
          style:
              Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),
        ),
        color: Colors.purple,
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context, ViewModel vm) {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new RaisedButton(
        onPressed: () {},
        child: new Text(
          "REGISTER",
          style:
              Theme.of(context).textTheme.subhead.copyWith(color: Colors.white),
        ),
        color: Colors.purple,
      ),
    );
  }

  Widget _buildInputs(BuildContext context, ViewModel vm) {
    return new Form(
      key: _formKey,
      child: new Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: new TextFormField(
              decoration: new InputDecoration(
                icon: new Icon(Icons.mail),
                hintText: "Email",
                border: new OutlineInputBorder(),
              ),
              validator: _validateEmail,
            ),
          ),
          new TextFormField(
            decoration: new InputDecoration(
              icon: new Icon(Icons.lock),
              hintText: "Password",
              border: new OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(ViewModel vm) {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
//      _autovalidate = true; // Start validating on every change.
//      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
//      showInSnackBar('${person.name}\'s phone number is ${person.phoneNumber}');
      //TODO: performRequest
    }
  }


  String _validateEmail(String email) {
    if (email.isEmpty) {
      return "Email is required";
    } else {
      return null;
    }
  }
}
