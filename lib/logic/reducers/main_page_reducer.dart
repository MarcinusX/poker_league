import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';

MainPageState reduce(ReduxState state, action) {
  MainPageState newState = state.mainPageState;
  if (action is ChangeMainPage) {
    newState = action.mainPageState;
  }
  return newState;
}
