import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';

String reduce(ReduxState state, action) {
  if (action is OnActiveLeagueNameProvided) {
    return action.leagueName;
  } else {
    return state.activeLeagueName;
  }
}
