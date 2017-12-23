import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/league.dart';

League reduce(ReduxState state, action) {
  League newLeague = state.activeLeague;
  if (action is OnActiveLeagueUpdated) {
    newLeague = new League.fromSnapshot(action.event.snapshot);
  }
  return newLeague;
}
