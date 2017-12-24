import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';

List<String> reduce(ReduxState state, action) {
  List<String> newList = new List.from(state.availableLeagues);
  if (action is LeagueAddedToUserAction) {
    if (!newList.contains(action.event.snapshot.key)) {
      newList.add(action.event.snapshot.key);
    }
  }
  return newList;
}
