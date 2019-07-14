import './pages/widgets/helpers/custom-route.dart';
import './scoped-models/main.dart';
import './pages/waifu_details.dart';
import './pages/home.dart';
import './pages/auth.dart';
import './pages/manage_waifu.dart';
import './models/waifu.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;

  @override
  void initState() {
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
       _isAuthenticated = isAuthenticated; 
      });
     });
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        //home: AuthenticationPage(),
        routes: {
          '/': (BuildContext context) => !_isAuthenticated ? AuthenticationPage() : HomePage(_model),
          '/admin': (BuildContext context) => !_isAuthenticated ? AuthenticationPage() : ManageWaifusPage(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          if(!_isAuthenticated){
            return MaterialPageRoute<bool>(builder: (BuildContext context) => AuthenticationPage());
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'waifu') {
            final String waifuID = pathElements[2];
            final Waifu waifu = _model.allWaifus.firstWhere((Waifu waifu) {
              return waifu.id == waifuID;
            });
            return CustomRoute<bool>(
              builder: (BuildContext context) => !_isAuthenticated ? AuthenticationPage() : WaifuDetailsPage(waifu),
            );
          }
          return null;
        },
        //The 'looks like this page doesn't exist' page
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => !_isAuthenticated ? AuthenticationPage() : HomePage(_model),
          );
        },
      ),
    );
  }
}
