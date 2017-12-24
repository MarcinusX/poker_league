import 'package:poker_league/logic/reducers/active_session_reducer.dart' as session_reducer;
import 'package:poker_league/logic/reducers/main_page_reducer.dart' as main_page_reducer;
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/models/session.dart';

import 'active_league_name_reducer.dart' as active_league_name_reducer;
import 'active_league_reducer.dart' as active_league_reducer;
import 'firebase_reducer.dart' as firebase_reducer;
import 'leagues_reducer.dart' as leagues_reducer;

ReduxState reduce(ReduxState state, action) {
  MainPageState mainPageState = main_page_reducer.reduce(state, action);
  //List<Player> players = players_reducer.reduce(state, action);
  //List<Session> sessions = sessions_reducer.reduce(state, action);
  Session activeSession = session_reducer.reduce(state, action);
  FirebaseState firebaseState = firebase_reducer.reduce(state, action);
  List<String> availableLeagues = leagues_reducer.reduce(state, action);
  String activeLeagueName = active_league_name_reducer.reduce(state, action);
  League activeLeague = active_league_reducer.reduce(state, action);

  return new ReduxState(
    mainPageState: mainPageState,
    //players: players,
    //sessions: sessions,
    activeSession: activeSession,
    firebaseState: firebaseState,
    availableLeagues: availableLeagues,
    activeLeagueName: activeLeagueName,
    activeLeague: activeLeague,
  );
}
