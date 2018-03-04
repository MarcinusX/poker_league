import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:validator/validator.dart' as validator;

class EmailPasswordWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new EmailPasswordWidgetState();
  }
}

@immutable
class ViewModel {
  final Function(String, String) logIn;
  final Function(String, String) register;

  ViewModel({
    @required this.logIn,
    @required this.register,
  });
}

class EmailPasswordWidgetState extends State<EmailPasswordWidget>
    with TickerProviderStateMixin {
  AnimationController _controller;
  bool _autovalidate = false;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
  new GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _emailFieldKey =
  new GlobalKey<FormFieldState<String>>();

  bool get isLoginPage => _controller.isCompleted;

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
          logIn: null,
          register: (email, pass) =>
              store.dispatch(new RegisterWithEmailAction(email, pass)),
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
                    ? buildRegisterPage(context, vm)
                    : new Transform(
                        transform:
                            new Matrix4.rotationY(_controller.value * math.PI),
                        alignment: Alignment.center,
                    child: _buildLoginPage(context, vm)),
              );
            });
      },
    );
  }

  Widget buildRegisterPage(BuildContext context, ViewModel vm) {
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
                onPressed: () => _reverse(),
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

  Widget _buildLoginPage(BuildContext context, ViewModel vm) {
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
                onPressed: () => _reverse(),
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
        onPressed: () => _handleLoginSubmitted(vm),
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
        onPressed: () => _handleRegisterSubmitted(vm),
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
      autovalidate: _autovalidate,
      child: new Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: new TextFormField(
              key: _emailFieldKey,
              decoration: new InputDecoration(
                icon: new Icon(Icons.mail),
                hintText: "Email",
                border: new OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),
          ),
          new TextFormField(
            key: _passwordFieldKey,
            decoration: new InputDecoration(
              icon: new Icon(Icons.lock),
              hintText: "Password",
              border: new OutlineInputBorder(),
            ),
            validator: _validatePassword,
          ),
        ],
      ),
    );
  }

  void _handleRegisterSubmitted(ViewModel vm) {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() => _autovalidate = true); // Start validating on every change.
    } else {
      form.save();
      String password = _passwordFieldKey.currentState.value;
      String email = _emailFieldKey.currentState.value;
      vm.register(email, password);
      //TODO: show info
    }
  }

  void _handleLoginSubmitted(ViewModel vm) {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      setState(() => _autovalidate = true); // Start validating on every change.
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
    } else if (!validator.isEmail(email)) {
      return "Invalid format";
    } else {
      return null;
    }
  }

  String _validatePassword(String password) {
    if (password
        .trim()
        .isEmpty) {
      return "Password is required";
    } else if (!isLoginPage && password
        .trim()
        .length < 6) {
      return "Password must contain 6 characters";
    } else {
      return null;
    }
  }

  _reverse() {
    if (isLoginPage) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
    _formKey.currentState.reset();
    _autovalidate = false;
  }
}
