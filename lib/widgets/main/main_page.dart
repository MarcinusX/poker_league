import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/widgets/home/home_page.dart';
import 'package:poker_league/widgets/main/drawer.dart';
import 'package:poker_league/widgets/players_page.dart';
import 'package:poker_league/widgets/sessions_list_page.dart';

class ViewModel {
  final MainPageState mainPageState;
  final Function(MainPageState) changePage;

  ViewModel({this.mainPageState, this.changePage});
}

final Map<MainPageState, FabActionProvider> pages = {
  MainPageState.HOME: new HomePage(),
  MainPageState.SESSIONS: new SessionsListPage(),
  MainPageState.PLAYERS: new PlayersPage(),
};

class MainPage extends StatelessWidget {
  String _initTitle(MainPageState page) {
    if (page == MainPageState.SESSIONS) {
      return "Sessions";
    } else if (page == MainPageState.PLAYERS) {
      return "Players";
    } else {
      return "Poker League";
    }
  }

  FloatingActionButton _initFab(BuildContext context, MainPageState page) {
    if (pages[page].onFabPressed == null) {
      return null;
    } else {
      return new FloatingActionButton(
        onPressed: () => pages[page].onFabPressed(context),
        child: new Icon(Icons.add),
        key: new Key("Fab_" + page.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(converter: (store) {
      return new ViewModel(
        mainPageState: store.state.mainPageState,
        changePage: (state) => store.dispatch(new ChangeMainPage(state)),
      );
    }, builder: (context, viewModel) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(_initTitle(viewModel.mainPageState)),
        ),
        drawer: new MyDrawer(),
        body: new Stack(
          children: <Widget>[
            new Offstage(
              offstage: viewModel.mainPageState != MainPageState.HOME,
              child: pages[MainPageState.HOME],
            ),
            new Offstage(
              offstage: viewModel.mainPageState != MainPageState.SESSIONS,
              child: pages[MainPageState.SESSIONS],
            ),
            new Offstage(
              offstage: viewModel.mainPageState != MainPageState.PLAYERS,
              child: pages[MainPageState.PLAYERS],
            ),
          ],
        ),
        floatingActionButton: _initFab(context, viewModel.mainPageState),
      );
    });
  }
}

abstract class FabActionProvider implements Widget {
  Function(BuildContext) get onFabPressed;
}
