import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/session.dart';

List<Session> reduceSessions(ReduxState state, action) {
  List<Session> newSessions = new List<Session>.from(state.sessions);
  if (action is AddSession) {
    newSessions.add(action.session);
  }
  return newSessions;
}
