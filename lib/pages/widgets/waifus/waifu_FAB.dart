import 'package:first_app/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../../models/waifu.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:math' as math;

class WaifuFAB extends StatefulWidget {
  final Waifu waifu;

  WaifuFAB(this.waifu);

  @override
  State<StatefulWidget> createState() {
    return _WaifuFABState();
  }
}

class _WaifuFABState extends State<WaifuFAB> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, 0.9, curve: Curves.easeOut),
              ),
              child: FloatingActionButton(
                child: Icon(Icons.account_box),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Info'),
                          content: Text('Uploader: ' + widget.waifu.userEmail),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Okay'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      });
                },
                mini: true,
                heroTag: 'info',
              ),
            ),
          ),
          Container(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, 0.6, curve: Curves.easeOut),
              ),
              child: FloatingActionButton(
                child: Icon(Icons.mail),
                onPressed: () async {
                  String url = 'mailto:${widget.waifu.userEmail}';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                mini: true,
                heroTag: 'mail',
              ),
            ),
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
          ),
          Container(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Interval(0.0, 0.3, curve: Curves.easeOut),
              ),
              child: FloatingActionButton(
                onPressed: () {
                  model.toggleWaifuFavorate();
                  model.toggleWaifuFavoriteStatus(false);
                },
                child: Icon(model.selectedWaifu.isFavorated
                    ? Icons.star
                    : Icons.star_border),
                mini: true,
                heroTag: 'favorate',
              ),
            ),
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
          ),
          Container(
            child: FloatingActionButton(
              child: AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget child) {
                    return Transform(
                      alignment: FractionalOffset.center,
                      transform:
                          Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                      child: Icon(_controller.isDismissed
                          ? Icons.more_vert
                          : Icons.close),
                    );
                  }),
              onPressed: () {
                if (_controller.isDismissed) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
              heroTag: 'options',
            ),
            height: 70.0,
            width: 56.0,
          ),
        ]);
      },
    );
  }
}
