import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';

MainPageState reduceMainPageState(ReduxState state, action) {
  MainPageState newState = state.mainPageState;
  if (action is ChangePageIndex) {
    newState = newState.copyWith(selectedIndex: action.index);
  }
  return newState;
}
