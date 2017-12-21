import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';

FirebaseState reduce(ReduxState state, action) {
  FirebaseState newState = state.firebaseState;
  if (action is InitAction) {
    newState = newState.copyWith(
      firebaseDatabase: action.firebaseDatabase,
      firebaseAuth: action.firebaseAuth,
      googleSignIn: action.googleSignIn,
    );
  } else if (action is OnLoggedInSuccessful) {
    newState = newState.copyWith(user: action.firebaseUser);
  }
  return newState;
}
