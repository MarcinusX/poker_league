import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';
import 'package:poker_league/widgets/main/main_page.dart';
import 'package:poker_league/widgets/sessions/new_session_dialog.dart';
import 'package:poker_league/widgets/sessions/session/session_page.dart';
import 'package:poker_league/widgets/sessions/session_item.dart';

class ViewModel {
  final List<Session> sessions;
  final Function(BuildContext) openNewSessionDialog;
  final Function(Session) chooseSession;

  ViewModel({this.sessions, this.openNewSessionDialog, this.chooseSession});
}

class FabContainer {
  Function(BuildContext) onFabPressed;
}

class SessionsListPage extends StatelessWidget implements FabActionProvider {
  //just to make it final
  final FabContainer fabContainer = new FabContainer();

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(
      converter: (store) {
        return new ViewModel(
          sessions: store.state.activeLeague?.sessions?.values?.toList() ?? [],
          openNewSessionDialog: (context) {
            _openNewSessionDialog(
                context, store.state?.activeLeague?.players ?? [])
                .then((Session session) {
              if (session != null) {
                store.dispatch(new AddSession(session));
              }
            });
          },
          chooseSession: (session) {
            store.dispatch(new ChooseSession(session));
            Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) {
                return new SessionPage();
              },
            ));
          },
        );
      },
      builder: (context, viewModel) {
        fabContainer.onFabPressed = viewModel.openNewSessionDialog;
        return new ListView.builder(
          itemCount: viewModel.sessions.length,
          itemBuilder: (BuildContext context, int index) {
            return new InkWell(
              child: new SessionItem(viewModel.sessions[index]),
              onTap: () => viewModel.chooseSession(viewModel.sessions[index]),
            );
          },
        );
      },
    );
  }

  @override
  get onFabPressed => fabContainer.onFabPressed;
}

Future<Session> _openNewSessionDialog(
    BuildContext context, List<Player> availablePlayers) async {
  return Navigator.of(context).push(new MaterialPageRoute(
        builder: (BuildContext context) {
          return new NewSessionDialog(
            availablePlayers: availablePlayers,
          );
        },
        fullscreenDialog: true,
      ));
}
