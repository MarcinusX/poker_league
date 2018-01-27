import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/checkout_actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';
import 'package:poker_league/widgets/sessions/session/numeric_slider.dart';

class ViewModel {
  final CheckoutState checkoutState;

  final Function(int) changeTotalCheckout;
  final Function(int) changeCashCheckout;
  final Function(Player, int) changeDebtCheckout;

  ViewModel(
      {this.checkoutState,
      this.changeTotalCheckout,
      this.changeCashCheckout,
      this.changeDebtCheckout});
}

class CheckoutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(converter: (store) {
      return new ViewModel(
        checkoutState: store.state.checkoutState,
        changeTotalCheckout: (int) =>
            store.dispatch(new ChangeTotalCheckout(int)),
        changeCashCheckout: (int) =>
            store.dispatch(new ChangeCashCheckout(int)),
        changeDebtCheckout: (player, int) =>
            store.dispatch(new ChangeDebtCheckout(player, int)),
      );
    }, builder: (context, vm) {
      {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text("Checkout: " + vm.checkoutState.player.name),
            actions: [
              new FlatButton(
                onPressed: (vm.checkoutState.leftResources == 0
                    ? () => Navigator.of(context).pop(
                          new Checkout(
                              cashValue:
                                  vm.checkoutState.cashCheckoutSlider.value,
                              debtValues: new Map.fromIterable(
                                  vm.checkoutState.checkoutsFromDebtsSliders
                                      .keys,
                                  key: (player) => player,
                                  value: (player) => vm
                                      .checkoutState
                                      .checkoutsFromDebtsSliders[player]
                                      .value)),
                        )
                    : null),
                child: new Text("CONFIRM",
                    style: Theme
                        .of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Colors.white)),
              )
            ],
          ),
          body: new SingleChildScrollView(
            child: new Padding(
              padding: new EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
              child: new Column(
                children: <Widget>[
                  new Text("Total checkout"),
                  new NumericSlider(
                    valueChanged: (newValue) =>
                        vm.changeTotalCheckout(newValue),
                    minValue: vm.checkoutState.totalCheckoutSlider.minValue,
                    value: vm.checkoutState.totalCheckoutSlider.value,
                    maxValue: vm.checkoutState.totalCheckoutSlider.maxValue,
                  ),
                  new Divider(),
                  (vm.checkoutState.totalCheckoutSlider.value == 0
                      ? new Container()
                      : new Column(
                          children: [
                            new Text("Cash"),
                            new NumericSlider(
                              valueChanged: (newValue) =>
                                  vm.changeCashCheckout(newValue),
                              minValue:
                                  vm.checkoutState.cashCheckoutSlider.minValue,
                              value: vm.checkoutState.cashCheckoutSlider.value,
                              maxValue:
                                  vm.checkoutState.cashCheckoutSlider.maxValue,
                            ),
                            new Divider(),
                          ],
                        )),
                  new ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          (vm.checkoutState.totalCheckoutSlider.value == 0
                              ? 0
                              : vm.checkoutState.playerDebts.length),
                      itemBuilder: (BuildContext context, int index) {
                        Player player =
                            vm.checkoutState.playerDebts.keys.toList()[index];
//                        int debt = vm.checkoutState.playerDebts[player];
                        return new Column(
                          children: [
                            new Text("Debt from " + player.name),
                            new NumericSlider(
                              valueChanged: (newValue) =>
                                  vm.changeDebtCheckout(player, newValue),
                              minValue: vm.checkoutState
                                  .checkoutsFromDebtsSliders[player].minValue,
                              value: vm.checkoutState
                                  .checkoutsFromDebtsSliders[player].value,
                              maxValue: vm.checkoutState
                                  .checkoutsFromDebtsSliders[player].maxValue,
                            ),
                          ],
                        );
                      }),
                ],
                mainAxisSize: MainAxisSize.min,
              ),
            ),
          ),
        );
      }
    });
  }
}

//new ListTile(
//title: new Text("Total: $_totalCheckout"),
//onTap: () {
//showDialog<int>(
//context: context,
//child: new NumberPickerDialog.integer(
//minValue: 0,
//maxValue: widget.session.total,
//initialIntegerValue: _totalCheckout))
//    .then((value) => setState(() => _totalCheckout = value));
//},
//),
