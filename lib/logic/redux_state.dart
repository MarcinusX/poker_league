import 'package:meta/meta.dart';
import 'package:poker_league/models/player.dart';
import 'package:poker_league/models/session.dart';

@immutable
class ReduxState {
  final MainPageState mainPageState;
  final List<Player> players;
  final List<Session> sessions;
  final Session activeSession;

  ReduxState(
      {this.mainPageState, this.players, this.sessions, this.activeSession});
}

@immutable
class MainPageState {
  final int selectedIndex;

  MainPageState({this.selectedIndex});

  MainPageState copyWith({int selectedIndex}) {
    return new MainPageState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
