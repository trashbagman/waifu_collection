import '../pages/widgets/ui_elements/logout_list_tile.dart';
import '../scoped-models/main.dart';
import 'package:flutter/material.dart';
import './waifu_create.dart';
import './waifu_list.dart';

class ManageWaifusPage extends StatelessWidget {
  final MainModel model;
  ManageWaifusPage(this.model);

  Widget _buildSidebarMenu(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose'),
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('All Waifus'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          Divider(),
          LogoutListTile(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          drawer: _buildSidebarMenu(context),
          appBar: AppBar(
            title: Text('Manage Waifus'),
            elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0: 4.0,
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.create),
                  text: 'Create Waifus',
                ),
                Tab(
                  icon: Icon(Icons.list),
                  text: 'My Waifus',
                )
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[ProductCreatePage(), WaifuListPage(model)],
          )),
    );
  }
}
