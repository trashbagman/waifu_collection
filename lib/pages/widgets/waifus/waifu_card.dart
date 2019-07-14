import '../../../models/waifu.dart';
import '../../../scoped-models/main.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class WaifuCard extends StatelessWidget {
  final Waifu waifu;

  WaifuCard(this.waifu);

  Widget _buildTitle(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Container(
        margin: EdgeInsets.only(top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                waifu.name,
                softWrap: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: deviceWidth > 700.0 ? 26.0 : 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Flexible(
              child: SizedBox(
                width: 10,
              ),
            ),
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  waifu.rating.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildCardButtons(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: Icon(
                    Icons.info,
                  ),
                  onPressed: () {
                    model.selectWaifu(waifu.id);
                    Navigator.pushNamed<bool>(context, '/waifu/' + waifu.id)
                        .then((_) => model.toggleWaifuFavoriteStatus(true));
                  }),
              IconButton(
                color: Colors.yellow,
                icon: Icon(waifu.isFavorated ? Icons.star : Icons.star_border),
                onPressed: () {
                  model.selectWaifu(waifu.id);
                  model.toggleWaifuFavorate();
                  model.toggleWaifuFavoriteStatus(true);
                },
              ),
            ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
            tag: waifu.id,
            child: FadeInImage(
              image: NetworkImage(waifu.image),
              height: 300.0,
              fit: BoxFit.cover,
              placeholder: AssetImage('assets/chika.jpg'),
            ),
          ),
          _buildTitle(context),
          _buildCardButtons(context)
        ],
      ),
    );
  }
}
