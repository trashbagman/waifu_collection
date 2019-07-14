import '../models/waifu.dart';
import '../pages/widgets/waifus/waifu_FAB.dart';

import 'package:flutter/material.dart';


class WaifuDetailsPage extends StatelessWidget {
  final Waifu waifu;
  WaifuDetailsPage(this.waifu);
/*
  _confirmationDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('This action cannot be undone.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Continue'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                },
              )
            ],
          );
        });
  }
*/
  Widget _buildWaifuName(String name) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10.0),
      child: Text(
        'Name: ' + name,
        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWaifuRating(double rating) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(bottom: 5.0),
      child: Text(
        'Rating: ' + rating.toString(),
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildWaifuSeries(String series) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(5.0),
      child: Text(
        'Series: ' + series,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWaifuDescription(String description) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(10.0),
      child: Text(
        description,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
        //appBar: AppBar(
        //  title: Text(waifu.name + " Details Page"),
        //),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 256.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(waifu.name,),
                background: Hero(
                  tag: waifu.id,
                  child: FadeInImage(
                    image: NetworkImage(waifu.image),
                    height: 300.0,
                    fit: BoxFit.cover,
                    placeholder: AssetImage('assets/chika.jpg'),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _buildWaifuName(waifu.name),
                _buildWaifuSeries(waifu.series),
                _buildWaifuRating(waifu.rating),
                _buildWaifuDescription(waifu.description),
              ]),
            ),
          ],
        ),
        floatingActionButton: WaifuFAB(waifu),
      ),
    );
  }
}
