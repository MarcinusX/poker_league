import 'package:poker_league/logic/reducers/active_session_reducer.dart';
import 'package:poker_league/logic/reducers/main_page_reducer.dart';
import 'package:poker_league/logic/reducers/players_reducer.dart';
import 'package:poker_league/logic/reducers/sessions_reducer.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

ReduxState reduce(ReduxState state, action) {
  MainPageState mainPageState = reduceMainPageState(state, action);
  List<Player> players = reducePlayers(state, action);
  List<Session> sessions = reduceSessions(state, action);
  Session activeSession = reduceActiveSession(state, action);

  return new ReduxState(
    mainPageState: mainPageState,
    players: players,
    sessions: sessions,
    activeSession: activeSession,
  );
}
