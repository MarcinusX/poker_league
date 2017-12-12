import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/widgets/players_page.dart';
import 'package:poker_league/widgets/sessions_list_page.dart';

class ViewModel {
  final int selectedIndex;
  final Function(int) changeSelectedIndex;

  ViewModel({this.selectedIndex, this.changeSelectedIndex});
}

final List<FabActionProvider> pages = [
  new SessionsListPage(),
  new PlayersPage(),
];

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(converter: (store) {
      return new ViewModel(
        selectedIndex: store.state.mainPageState.selectedIndex,
        changeSelectedIndex: (index) =>
            store.dispatch(new ChangePageIndex(index)),
      );
    }, builder: (context, viewModel) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Poker league"),
        ),
        body: new Stack(
          children: <Widget>[
            new Offstage(
              offstage: viewModel.selectedIndex != 0,
              child: pages[0],
            ),
            new Offstage(
              offstage: viewModel.selectedIndex != 1,
              child: pages[1],
            ),
          ],
        ),
        bottomNavigationBar: new BottomNavigationBar(
          items: [
            new BottomNavigationBarItem(
              icon: new Icon(Icons.view_list),
              title: new Text("Sessions"),
            ),
            new BottomNavigationBarItem(
              icon: new Icon(Icons.people),
              title: new Text("Players"),
            ),
          ],
          currentIndex: viewModel.selectedIndex,
          onTap: (index) => viewModel.changeSelectedIndex(index),
        ),
        floatingActionButton: new FloatingActionButton(
          onPressed: () => pages[viewModel.selectedIndex].onFabPressed(context),
          child: new Icon(Icons.add),
          key: new Key("Fab" + viewModel.selectedIndex.toString()),
        ),
      );
    });
  }
}

abstract class FabActionProvider implements Widget {
  Function(BuildContext) get onFabPressed;
}
