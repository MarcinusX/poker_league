
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:meta/meta.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';
import 'package:poker_league/widgets/sessions/session/session_page.dart';
import 'package:poker_league/widgets/sessions/session_item.dart';

class ViewModel {
  final Player currentPlayer;
  final List<Session> sessions;
  final Function(Session) chooseSession;

  ViewModel({
    @required this.currentPlayer,
    @required this.sessions,
    @required this.chooseSession,
  });
}

class SessionsListPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(
      converter: (store) {
        List<Session> sessions =
            store.state.activeLeague?.sessions?.values?.toList() ?? [];
        sessions..sort((s1, s2) => s2.dateTime.compareTo(s1.dateTime));
        return new ViewModel(
          currentPlayer: store.state.currentPlayer,
          sessions: sessions,

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
        return new ListView.builder(
          itemCount: viewModel.sessions.length,
          itemBuilder: (BuildContext context, int index) {
            return new InkWell(
              child: new SessionItem(
                session: viewModel.sessions[index],
                currentPlayer: viewModel.currentPlayer,
              ),
              onTap: () => viewModel.chooseSession(viewModel.sessions[index]),
            );
          },
        );
      },
    );
  }
}
