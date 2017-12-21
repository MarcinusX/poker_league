import 'package:poker_league/logic/reducers/active_session_reducer.dart' as session_reducer;
import 'package:poker_league/logic/reducers/main_page_reducer.dart' as main_page_reducer;
import 'package:poker_league/logic/reducers/players_reducer.dart' as players_reducer;
import 'package:poker_league/logic/reducers/sessions_reducer.dart' as sessions_reducer;
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

import 'firebase_reducer.dart' as firebase_reducer;

ReduxState reduce(ReduxState state, action) {
  MainPageState mainPageState = main_page_reducer.reduce(state, action);
  List<Player> players = players_reducer.reduce(state, action);
  List<Session> sessions = sessions_reducer.reduce(state, action);
  Session activeSession = session_reducer.reduce(state, action);
  FirebaseState firebaseState = firebase_reducer.reduce(state, action);

  return new ReduxState(
    mainPageState: mainPageState,
    players: players,
    sessions: sessions,
    activeSession: activeSession,
      firebaseState: firebaseState
  );
}
