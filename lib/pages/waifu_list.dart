import '../pages/waifu_create.dart';
import '../scoped-models/main.dart';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class WaifuListPage extends StatefulWidget {
  final MainModel model;
  WaifuListPage(this.model);
  @override
  State<StatefulWidget> createState() {
    return _WaifuListState();
  }
}

class _WaifuListState extends State<WaifuListPage> {
  @override
  initState() {
    widget.model.fetchWaifus(onlyForUser: true, clearExisting: true);
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        model.selectWaifu(model.allWaifus[index].id);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return ProductCreatePage();
        }));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: Key(model.allWaifus[index].name),
            background: Container(
              color: Colors.red,
            ),
            onDismissed: (DismissDirection direction) {
              if (direction == DismissDirection.endToStart) {
                model.selectWaifu(model.allWaifus[index].id);
                model.deleteProduct();
              }
            },
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                      backgroundImage:
                          NetworkImage(model.allWaifus[index].image)),
                  title: Text(model.allWaifus[index].name),
                  subtitle: Text(
                      'Rating: ${model.allWaifus[index].rating.toString()}'),
                  trailing: _buildEditButton(context, index, model),
                ),
                Divider(),
              ],
            ),
          );
        },
        itemCount: model.allWaifus.length,
      );
    });
  }
}
