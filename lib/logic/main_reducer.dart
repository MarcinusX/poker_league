import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/models/session.dart';

ReduxState reduce(ReduxState state, action) {
  ReduxState newState;
  if (action is ChangeMainPage) {
    newState = state.copyWith(mainPageState: action.mainPageState);
  } else if (action is OnActiveLeagueUpdated) {
    League newLeague = new League.fromSnapshot(action.event.snapshot);
    Session newSession = newLeague.sessions[state.activeSession?.key];
    newState =
        state.copyWith(activeLeague: newLeague, activeSession: newSession);
  } else if (action is OnActiveLeagueNameProvided) {
    newState = state.copyWith(activeLeagueName: action.leagueName);
  } else if (action is ChooseSession) {
    newState = state.copyWith(activeSession: action.session);
  } else if (action is InitAction) {
    newState = state.copyWith(
        firebaseState: state.firebaseState.copyWith(
          firebaseDatabase: action.firebaseDatabase,
          firebaseAuth: action.firebaseAuth,
          googleSignIn: action.googleSignIn,
        ));
  } else if (action is OnLoggedInSuccessful) {
    newState = state.copyWith(
        firebaseState: state.firebaseState.copyWith(user: action.firebaseUser));
  } else if (action is LeagueAddedToUserAction) {
    if (!state.availableLeagues.contains(action.event.snapshot.key)) {
      newState = state.copyWith(
          availableLeagues: new List.from(state.availableLeagues)
            ..add(action.event.snapshot.key));
    }
  } else {
    newState = state;
  }
  return newState;
}
