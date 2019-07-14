import 'package:first_app/pages/widgets/ui_elements/logout_list_tile.dart';
import 'package:first_app/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';
import 'widgets/waifus/waifus.dart';

class HomePage extends StatefulWidget {
  final MainModel model;
  HomePage(this.model);


  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>{
  @override
  void initState() {
    widget.model.fetchWaifus();
    super.initState();
  }

  Widget _buildWaifuList(){
    return ScopedModelDescendant(builder: (BuildContext context, Widget child, MainModel model){
      Widget content = Center(child: Text('No Waifus Yet'));
      if (model.displayedWaifus.length > 0 && !model.isloading){
        content = Waifus();
      }
      else if(model.isloading){
        content = Center(child: CircularProgressIndicator());
      }
      return RefreshIndicator(onRefresh: model.fetchWaifus, child: content,) ;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              AppBar(automaticallyImplyLeading: false, title: Text('Choose'), elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0: 4.0,),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Manage Waifus'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/admin');
                },
              ),
              Divider(),
              LogoutListTile(),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Waifu Collection'),
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0: 4.0,
          actions: <Widget>[
            ScopedModelDescendant<MainModel>(builder:
                (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: model.displayFavorates ? Icon(Icons.star) : Icon(Icons.star_border),
                onPressed: () {
                  model.toggleFavorate();
                },
              );
            })
          ],
        ),
        body: _buildWaifuList());
  }
}
