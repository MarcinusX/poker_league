import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/models/session.dart';

ReduxState reduce(ReduxState state, action) {
  print(action.runtimeType);
  ReduxState newState = state;
  if (action is ChangeMainPage) {
    newState = state.copyWith(mainPageState: action.mainPageState);
  } else if (action is OnActiveLeagueUpdated) {
    League newLeague = action.league;
    Session newSession = newLeague.sessions[state.activeSession?.key];
    newState = state.copyWith(
      activeLeague: newLeague,
      activeSession: newSession,
    );
  } else if (action is OnActiveLeagueNameProvided) {
    newState = state.copyWith(activeLeagueName: action.leagueName);
  } else if (action is ChooseSession) {
    newState = state.copyWith(activeSession: action.session);
  } else if (action is OnLoggedInSuccessful) {
    newState = state.copyWith(firebaseUser: action.firebaseUser);
  } else if (action is LeagueAddedToUser) {
    if (!state.availableLeagueNames.contains(action.leagueName)) {
      newState = state.copyWith(
        availableLeagueNames: new List.from(state.availableLeagueNames)
          ..add(action.leagueName),
      );
    }
  }
  newState = newState.copyWith(
    sessionPageState: reduceSessionPageState(state, action),
    joinLeaguePageState: reduceJoinPageState(state, action),
  );
  return newState;
}

JoinLeaguePageState reduceJoinPageState(ReduxState state, action) {
  if (action is OnFindLeagueResultAction) {
    return new JoinLeaguePageState(
      chosenLeagueName: action.requestedLeagueName,
      league: action.league,
    );
  } else if (action is PrepareJoinLeaguePageAction) {
    return new JoinLeaguePageState();
  }
  return state.joinLeaguePageState;
}

SessionPageState reduceSessionPageState(ReduxState state, action) {
  if (action is ChooseSession) {
    return new SessionPageState.withSession(
        state.sessionPageState, action.session);
  } else if (action is OnActiveLeagueUpdated) {
    if (state.activeSession != null) {
      return new SessionPageState.withSession(
          state.sessionPageState, state.activeSession);
    }
  } else if (action is AddPlayerToSession) {
    return new SessionPageState(
      playersExpanded: new Map.from(state.sessionPageState.playersExpanded)
        ..[action.player] = false,
    );
  } else if (action is SessionSetExpandedAction) {
    return new SessionPageState(
      playersExpanded: new Map.from(state.sessionPageState.playersExpanded)
        ..[action.player] = action.isExpanded,
    );
  }

  return state.sessionPageState;
}
