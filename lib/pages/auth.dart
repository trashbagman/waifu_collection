import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../scoped-models/main.dart';
import '../models/auth.dart';
import '../pages/widgets/ui_elements/adaptive_progress_indicator.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthenticationState();
  }
}

class _AuthenticationState extends State<AuthenticationPage>
    with TickerProviderStateMixin {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
    'acceptTerms': false,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  AnimationController _controller;
  Animation<Offset> _slideAnimation;

  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _slideAnimation = Tween<Offset>(begin: Offset(-6.0, 0.0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    super.initState();
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(value)) {
          return 'Email is invalid';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['email'] = value;
      },
    );
  }

  Widget _buildPasswordConfirmTextField() {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeIn),
      child: SlideTransition(
        position: _slideAnimation,
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            filled: true,
            fillColor: Colors.white,
          ),
          obscureText: true,
          validator: (String value) {
            if (value != _passwordTextController.text &&
                _authMode == AuthMode.Signup) {
              return 'This password doe not match the existing password';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        filled: true,
        fillColor: Colors.white,
      ),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password cannot be empty';
        } else if (value.length < 6) {
          return 'Password is too weak';
        }
        return null;
      },
      onSaved: (String value) {
        _formData['password'] = value;
      },
    );
  }

  /*Widget _buildAcceptTerms() {
    return SwitchListTile(
      value: _formData['acceptTerms'],
      onChanged: (bool value) {
        setState(() {
          _formData['acceptTerms'] = value;
        });
      },
      title: Text('Accept Terms'),
    );
  }
*/
  void _submitForm(Function authenticate) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    Map<String, dynamic> successInformation;

    successInformation = await authenticate(
        _formData['email'], _formData['password'], _authMode);

    if (successInformation['success']) {
      //Navigator.pushReplacementNamed(context, '/');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('An Error Occurred!'),
            content: Text(successInformation['message']),
            actions: <Widget>[
              FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    }
  }
 

  double _getLoginWidth(double deviceWidth) {
    double loginWidth;
    if (deviceWidth > 550.0) {
      loginWidth = deviceWidth * 0.75;
    } else {
      loginWidth = deviceWidth * 0.95;
    }
    return loginWidth;
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0: 4.0,
          title: Text('Login'),
        ),
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3), BlendMode.dstATop),
                  image: AssetImage('assets/background.png')),
            ),
            padding: EdgeInsets.all(20),
            child: Container(
              width: _getLoginWidth(deviceWidth),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        _buildEmailTextField(),
                        SizedBox(
                          height: 10,
                        ),
                        _buildPasswordTextField(),
                        SizedBox(
                          height: 10,
                        ),
                        _buildPasswordConfirmTextField(),
                        SizedBox(
                          height: 10,
                        ),
                        //_authMode == AuthMode.Signup
                        //    ? _buildAcceptTerms()
                        //    : Container(),
                        FlatButton(
                          child: Text(
                              'Switch to ${_authMode == AuthMode.Login ? 'SignUp' : 'Login'}'),
                          onPressed: () {
                            if (_authMode == AuthMode.Login) {
                              setState(() {
                                _authMode = AuthMode.Signup;
                              });
                              _controller.forward();
                            } else {
                              setState(() {
                                _authMode = AuthMode.Login;
                              });
                              _controller.reverse();
                            }
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ScopedModelDescendant<MainModel>(
                          builder: (BuildContext context, Widget child,
                              MainModel model) {
                            return model.isloading
                                ? AdaptiveProgressIndicator()
                                : RaisedButton(
                                    textColor: Colors.white,
                                    child: Text(_authMode == AuthMode.Login
                                        ? 'LOGIN'
                                        : 'SIGNUP'),
                                    onPressed: () =>
                                        _submitForm(model.authenticate),
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }
}
