import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/auth_middleware.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:redux/redux.dart';
import 'package:test/test.dart';

class StoreMock extends Mock implements Store<ReduxState> {}

class FirebaseAuthMock extends Mock implements FirebaseAuth {}

class FirebaseUserMock extends Mock implements FirebaseUser {}

ReduxState reducerMock(ReduxState state, action) => state;

void main() {
  test('Successful register with email aciton calls OnLoginSuccess', () {
    //given
    bool onLoggedInSuccessfulCalled = false;
    var reducer = (ReduxState state, action) {
      if (action is OnLoggedInSuccessful) {
        onLoggedInSuccessfulCalled = true;
      }
      return state;
    };
    Store store = _initRegisterStore(reducer);

    //when
    Future future = new Future(() =>
        store
            .dispatch(
            new RegisterWithEmailAction("email@sss.com", "password")));

    //then
    future.then((_) =>
        expectAsync0(() {
      expect(onLoggedInSuccessfulCalled, true);
        }));
  });
  test('Register with email aciton calls firebaseAuth method', () {
    //given
    FirebaseAuth auth = _initRegisterAuth();
    Store store = new Store<ReduxState>(reducerMock,
        middleware: createAuthMiddleware(
            googleSignIn: null, firebaseAuth: auth, facebookSignIn: null));
    //when
    Future future = new Future(() =>
        store
            .dispatch(
            new RegisterWithEmailAction("email@sss.com", "password")));
    //then
    future.then((_) {
      expectAsync0(() {
        verify(auth.createUserWithEmailAndPassword(
            email: "email@sss.com", password: "password"))
            .called(1);
      });
    });
  });

}

_initRegisterAuth() {
  FirebaseAuth auth = new FirebaseAuthMock();
  when(auth.createUserWithEmailAndPassword(email: any, password: any))
      .thenReturn(new FirebaseUserMock());
  when(auth.updateProfile(any)).thenReturn(new FirebaseUserMock());
  return auth;
}

Store _initRegisterStore(reducer) {
  FirebaseAuth auth = _initRegisterAuth();
  return new Store<ReduxState>(reducer,
      middleware: createAuthMiddleware(
          googleSignIn: null, firebaseAuth: auth, facebookSignIn: null));
}
