import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';
import 'package:poker_league/widgets/home/home_page.dart';
import 'package:poker_league/widgets/leagues/leagues_fab.dart';
import 'package:poker_league/widgets/leagues/leagues_page.dart';
import 'package:poker_league/widgets/main/drawer.dart';
import 'package:poker_league/widgets/players/player_dialog.dart'
as playerDialog;
import 'package:poker_league/widgets/players/players_page.dart';
import 'package:poker_league/widgets/sessions/new_session_dialog.dart';
import 'package:poker_league/widgets/sessions/sessions_list_page.dart';

class ViewModel {
  final MainPageState mainPageState;
  final Function(MainPageState) changePage;
  final Function(BuildContext) openNewSessionDialog;
  final Function(BuildContext) openNewPlayerDialog;

  ViewModel({
    @required this.mainPageState,
    @required this.changePage,
    @required this.openNewPlayerDialog,
    @required this.openNewSessionDialog,});
}

final Map<MainPageState, Widget> pages = {
  MainPageState.HOME: new HomePage(),
  MainPageState.SESSIONS: new SessionsListPage(),
  MainPageState.PLAYERS: new PlayersPage(),
  MainPageState.LEAGUES: new LeaguesPage(),
};

class MainPage extends StatelessWidget {
  String _initTitle(MainPageState page) {
    if (page == MainPageState.SESSIONS) {
      return "Sessions";
    } else if (page == MainPageState.PLAYERS) {
      return "Players";
    } else if (page == MainPageState.LEAGUES) {
      return "My leagues";
    } else {
      return "Poker League";
    }
  }

  Widget _initFab(BuildContext context, MainPageState page, ViewModel vm) {
    switch (page) {
      case MainPageState.HOME:
        return null;
      case MainPageState.SESSIONS:
        return new FloatingActionButton(
          onPressed: () => vm.openNewSessionDialog(context),
          child: new Icon(Icons.add),
          key: new Key("Fab_Sessions"),
        );
      case MainPageState.PLAYERS:
        return new FloatingActionButton(
          onPressed: () => vm.openNewPlayerDialog(context),
          child: new Icon(Icons.add),
          key: new Key("Fab_Players"),
        );
      case MainPageState.LEAGUES:
        return new FoldingFloatingActionButton();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(converter: (store) {
      return new ViewModel(
        mainPageState: store.state.mainPageState,
        changePage: (state) => store.dispatch(new ChangeMainPage(state)),
        openNewPlayerDialog: (context) {
          playerDialog.openNewPlayerDialog(context).then((String name) {
            if (name != null) {
              Player player = new Player(name: name);
              store.dispatch(new AddPlayerToLeague(player));
            }
          });
        },
        openNewSessionDialog: (context) {
          _openNewSessionDialog(
              context, store.state?.activeLeague?.players ?? [])
              .then((Session session) {
            if (session != null) {
              store.dispatch(new AddSession(session));
            }
          });
        },
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
            new Offstage(
              offstage: viewModel.mainPageState != MainPageState.LEAGUES,
              child: pages[MainPageState.LEAGUES],
            ),
          ],
        ),
        floatingActionButton:
        _initFab(context, viewModel.mainPageState, viewModel),
      );
    });
  }
}

//Sessions FloatingActionButton
Future<Session> _openNewSessionDialog(BuildContext context,
    List<Player> availablePlayers) async {
  return Navigator.of(context).push(new MaterialPageRoute(
    builder: (BuildContext context) {
      return new NewSessionDialog(
        availablePlayers: availablePlayers,
      );
    },
    fullscreenDialog: true,
  ));
}
