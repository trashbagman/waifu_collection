import '../../../scoped-models/main.dart';
import '../../../models/waifu.dart';
import '../../../pages/widgets/waifus/waifu_card.dart';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

class Waifus extends StatelessWidget {
  Widget _buildWaifuList(List<Waifu> waifus) {
    Widget waifuCards;
    List<Waifu> reversedWaifus = waifus.reversed.toList();
    if (waifus.length > 0) {
      waifuCards = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            WaifuCard(reversedWaifus[index]),
        itemCount: waifus.length,
      );
    } else {
      waifuCards = Center(
        child: Text(''),
      );
    }
    return waifuCards;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return _buildWaifuList(model.displayedWaifus);
    });
  }
}
