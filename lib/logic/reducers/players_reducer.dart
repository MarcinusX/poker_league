import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';

List<Player> reducePlayers(ReduxState state, action) {
  List<Player> players = new List<Player>.from(state.players);
  if (action is AddPlayerToLeague) {
    players.add(action.player);
  } else if (action is DoBuyIn) {
    players.singleWhere((player) => player == action.player).leagueBalance -=
        action.buyIn.value;
  } else if (action is DoCheckout) {
    players.singleWhere((player) => player == action.player).leagueBalance +=
        action.checkout.total;
  }
  return players;
}
