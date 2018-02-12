import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:poker_league/logic/actions.dart';
import 'package:poker_league/logic/redux_state.dart';

class ViewModel {
  final MainPageState mainPageState;
  final Function(MainPageState) changePage;
  final FirebaseUser firebaseUser;
  final Function() logout;

  ViewModel({
    this.mainPageState,
    this.changePage,
    this.firebaseUser,
    this.logout,
  });
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

  Widget _mapListItemToWidget(BuildContext context, ViewModel viewModel,
      ListItem item) {
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
          firebaseUser: store.state.firebaseUser,
          mainPageState: store.state.mainPageState,
          changePage: (state) => store.dispatch(new ChangeMainPage(state)),
        );
      },
      builder: (context, viewModel) {
        return new Drawer(
          child: new ListView(
            children: [
              new DrawerHeader(
                decoration: const BoxDecoration(
                  image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: const AssetImage(
                      'assets/hand-AA.jpeg',
                    ),
                  ),
                ),
                child: new Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    new Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Padding(
                          padding: new EdgeInsets.only(bottom: 8.0),
                          child: new CircleAvatar(
                            radius: 24.0,
                            backgroundImage: new NetworkImage(
                                viewModel.firebaseUser.photoUrl),
                          ),
                        ),
                        new Padding(
                            padding: new EdgeInsets.symmetric(vertical: 8.0),
                            child: new Text(
                              viewModel.firebaseUser.displayName,
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .subhead
                                  .copyWith(color: Colors.white),
                            )),
                        new Text(
                          viewModel.firebaseUser.email,
                          style: Theme
                              .of(context)
                              .textTheme
                              .body1
                              .copyWith(color: Colors.white),
                        )
                      ],
                    )
                  ],
                ),
              )
            ]
              ..addAll(items.map(
                      (item) => _mapListItemToWidget(context, viewModel, item)))
              ..add(new Divider())..add(
                  _mapListItemToWidget(context, viewModel, leaguesItem)),
          ),
        );
      },
    );
  }
}
