import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';

class ViewModel {
  final MainPageState mainPageState;
  final Function(MainPageState) changePage;

  ViewModel({this.mainPageState, this.changePage});
}

class ListItem {
  final MainPageState page;
  final String name;
  final IconData icon;

  ListItem({this.page, this.name, this.icon});
}

class MyDrawer extends StatelessWidget {
  final List<ListItem> items = [
    new ListItem(page: MainPageState.HOME, name: "Home", icon: Icons.home),
    new ListItem(
        page: MainPageState.SESSIONS, name: "Sessions", icon: Icons.list),
    new ListItem(
        page: MainPageState.PLAYERS, name: "Players", icon: Icons.people),
  ];

  final ListItem leaguesItem = new ListItem(
      page: MainPageState.LEAGUES, name: "Leagues", icon: Icons.whatshot);

  Widget _mapListItemToWidget(
      BuildContext context, ViewModel viewModel, ListItem item) {
    Color color =
        (viewModel.mainPageState == item.page) ? Colors.blue : Colors.black;
    Text text = new Text(
      item.name,
      style: Theme.of(context).textTheme.body2.copyWith(color: color),
    );
    return new ListTile(
        title: text,
        leading: new Icon(
          item.icon,
          color: color,
        ),
        onTap: () {
          viewModel.changePage(item.page);
          Navigator.pop(context);
        });
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<ReduxState, ViewModel>(
      converter: (store) {
        return new ViewModel(
          mainPageState: store.state.mainPageState,
          changePage: (state) => store.dispatch(new ChangeMainPage(state)),
        );
      },
      builder: (context, viewModel) {
        return new Drawer(
          child: new ListView(
            children: [
              new DrawerHeader(
                child: new Text("Header"),
              )
            ]
              ..addAll(items.map(
                  (item) => _mapListItemToWidget(context, viewModel, item)))
              ..add(new Divider())
              ..add(_mapListItemToWidget(context, viewModel, leaguesItem)),
          ),
        );
      },
    );
  }
}
