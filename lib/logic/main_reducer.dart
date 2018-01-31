import 'dart:math' as math;

import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/league.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

import 'checkout_actions.dart';

ReduxState reduce(ReduxState state, action) {
  print(action.runtimeType);
  ReduxState newState = state;
  if (action is ChangeMainPage) {
    newState = state.copyWith(mainPageState: action.mainPageState);
  } else if (action is OnActiveLeagueUpdated) {
    League newLeague = action.league;
    Session newSession = newLeague.sessions[state.activeSession?.key];
    newState = state.copyWith(
      activeLeague: newLeague,
      activeSession: newSession,
    );
  } else if (action is OnActiveLeagueNameProvided) {
    newState = state.copyWith(activeLeagueName: action.leagueName);
  } else if (action is ChooseSession) {
    newState = state.copyWith(activeSession: action.session);
  } else if (action is OnLoggedInSuccessful) {
    newState = state.copyWith(
        firebaseState: state.firebaseState.copyWith(user: action.firebaseUser));
  } else if (action is LeagueAddedToUser) {
    if (!state.availableLeagueNames.contains(action.leagueName)) {
      newState = state.copyWith(
        availableLeagueNames: new List.from(state.availableLeagueNames)
          ..add(action.leagueName),
      );
    }
  }
  newState = newState.copyWith(
    checkoutState: reduceCheckoutState(state, action),
    sessionPageState: reduceSessionPageState(state, action),
  );
  return newState;
}

SessionPageState reduceSessionPageState(ReduxState state, action) {
  if (action is ChooseSession) {
    return new SessionPageState.withSession(
        state.sessionPageState, action.session);
  } else if (action is OnActiveLeagueUpdated) {
    if (state.activeSession != null) {
      return new SessionPageState.withSession(
          state.sessionPageState, state.activeSession);
    }
  } else if (action is SessionSetExpandedAction) {
    return new SessionPageState(
      playersExpanded: new Map.from(state.sessionPageState.playersExpanded)
        ..[action.player] = action.isExpanded,
    );
  }

  return state.sessionPageState;
}

CheckoutState reduceCheckoutState(ReduxState state, action) {
  if (action is InitCheckout) {
    Player player = action.player;
    Session session = action.session;
    //TODO: Subtract checkouted debt buyins
    Map<Player, int> playerDebts = new Map<Player, int>.fromIterable(
        session.playerSessions.values.where((ps) => ps.debtBuyIn != 0),
        key: (PlayerSession ps) => ps.player,
        value: (PlayerSession ps) => ps.debtBuyIn);
    CheckoutSliderState totalCheckoutState =
    new CheckoutSliderState(minValue: 0, value: 0, maxValue: session.total);
    CheckoutSliderState cashCheckoutState = new CheckoutSliderState();
    Map<Player, CheckoutSliderState> checkoutsInDebts = new Map.fromIterable(
        playerDebts.keys,
        key: (player) => player,
        value: (player) => new CheckoutSliderState());
    return new CheckoutState(
      player: player,
      session: session,
      playerDebts: playerDebts,
      totalCheckoutSlider: totalCheckoutState,
      cashCheckoutSlider: cashCheckoutState,
      checkoutsFromDebtsSliders: checkoutsInDebts,
    );
  } else if (action is ChangeTotalCheckout) {
    CheckoutState newState = state.checkoutState.copyWith(
        totalCheckout: state.checkoutState.totalCheckoutSlider
            .copyWith(value: action.value));
    return updateMaxValuesOfNonTotalSliders(newState, ignoreTotal: true);
  } else if (action is ChangeCashCheckout) {
    CheckoutState newState = state.checkoutState.copyWith(
        cashCheckout: state.checkoutState.cashCheckoutSlider
            .copyWith(value: action.value));
    return updateMaxValuesOfNonTotalSliders(newState, ignoreCash: true);
  } else if (action is ChangeDebtCheckout) {
    CheckoutState newState = state.checkoutState.copyWith(
        checkoutsFromDebts:
        new Map.from(state.checkoutState.checkoutsFromDebtsSliders)
          ..[action.player] = state
              .checkoutState.checkoutsFromDebtsSliders[action.player]
              .copyWith(value: action.value));
    return updateMaxValuesOfNonTotalSliders(newState);
  } else {
    return state.checkoutState;
  }
}

CheckoutState updateMaxValuesOfNonTotalSliders(CheckoutState oldState,
    {bool ignoreTotal = false, bool ignoreCash = false, Player ignoreDebt}) {
  int leftResources = oldState.leftResources;
  print(leftResources);
  CheckoutSliderState totalSlider = oldState.totalCheckoutSlider;
  CheckoutSliderState cashSlider = oldState.cashCheckoutSlider;
  Map<Player, CheckoutSliderState> debts = oldState.checkoutsFromDebtsSliders;
  if (!ignoreTotal) {
    totalSlider = oldState.totalCheckoutSlider
        .copyWith(minValue: oldState.moneyDeclaredToCheckout);
  }
  if (!ignoreCash) {
    cashSlider = oldState.cashCheckoutSlider
        .copyWith(maxValue: leftResources + oldState.cashCheckoutSlider.value);
  }
  debts = new Map<Player, CheckoutSliderState>.fromIterable(
      oldState.checkoutsFromDebtsSliders.keys,
      key: (key) => key,
      value: (key) =>
          oldState.checkoutsFromDebtsSliders[key].copyWith(
              maxValue: math.min(
                  leftResources + oldState.checkoutsFromDebtsSliders[key].value,
                  oldState.playerDebts[key])));
  return oldState.copyWith(
      totalCheckout: totalSlider,
      checkoutsFromDebts: debts,
      cashCheckout: cashSlider);
}
