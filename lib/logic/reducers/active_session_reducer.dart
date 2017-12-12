import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/session.dart';

Session reduceActiveSession(ReduxState state, action) {
  Session newSession = state.activeSession;
  if (action is ChooseSession) {
    newSession = action.session;
  } else if (action is DoBuyIn) {
    newSession.playerSessions[action.player].buyIns.add(action.buyIn);
  } else if (action is DoCheckout) {
    newSession.playerSessions[action.player].checkout = action.checkout;
  }
  return newSession;
}
