import 'dart:io';

import '../pages/widgets/ui_elements/adaptive_progress_indicator.dart';
import '../models/waifu.dart';
import '../pages/widgets/form_inputs/image.dart';
import '../scoped-models/main.dart';
import './widgets/helpers/ensure-visible.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:scoped_model/scoped_model.dart';

class ProductCreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductCreateState();
  }
}

class _ProductCreateState extends State<ProductCreatePage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'series': null,
    'description': null,
    'rating': null,
    'image': null
  };

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final _titleFocusNode = FocusNode();
  final _seriesFocusNode = FocusNode();
  final _ratingFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _nameTextController = TextEditingController();
  final _ratingTextController = TextEditingController();
  final _seriesTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();

  Widget _buildTitleTextField(Waifu waifu) {
    if (waifu == null && _nameTextController.text.trim() == '') {
      _nameTextController.text = '';
    } else if (waifu != null && _nameTextController.text.trim() == '') {
      _nameTextController.text = waifu.name;
    } else if (waifu != null && _nameTextController.text.trim() != '') {
      _nameTextController.text = _nameTextController.text;
    } else if (waifu == null && _nameTextController.text.trim() != '') {
      _nameTextController.text = _nameTextController.text;
    } else {
      _nameTextController.text = '';
    }
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(labelText: 'Name'),
        controller: _nameTextController,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Name is Required';
          }
          return null;
        },
        //initialValue: waifu == null ? '' : waifu.name,
        onSaved: (String value) {
          _formData['title'] = value;
        },
      ),
    );
  }

  Widget _buildSeriesTextField(Waifu waifu) {
    if (waifu == null && _seriesTextController.text.trim() == '') {
      _seriesTextController.text = '';
    } else if (waifu != null && _seriesTextController.text.trim() == '') {
      _seriesTextController.text = waifu.series;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _seriesFocusNode,
      child: TextFormField(
        focusNode: _seriesFocusNode,
        controller: _seriesTextController,
        decoration: InputDecoration(labelText: 'Series'),
        //initialValue: waifu == null ? '' : waifu.series,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Series is required, if OC, type Original Character ^-^';
          }
          return null;
        },
        onSaved: (String value) {
          _formData['series'] = value;
        },
      ),
    );
  }

  Widget _buildRatingTextField(Waifu waifu) {
    if (waifu == null && _ratingTextController.text.trim() == '') {
      _ratingTextController.text = '';
    } else if (waifu != null && _ratingTextController.text.trim() == '') {
      _ratingTextController.text = waifu.rating.toString();
    }
    return EnsureVisibleWhenFocused(
      focusNode: _ratingFocusNode,
      child: TextFormField(
        decoration: InputDecoration(labelText: 'Rating'),
        keyboardType: TextInputType.number,
        controller: _ratingTextController,
        validator: (String value) {
          if (value.isEmpty) {
            return "Rating is required";
          } else if (!RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$')
              .hasMatch(value)) {
            return "Input not valid";
          }
          return null;
        },
        //initialValue: waifu == null ? '' : waifu.rating.toString(),
        onSaved: (String value) {
          if (double.parse(value.replaceFirst(RegExp(r','), '.')) > 10.0) {
            _ratingTextController.text = '10.0';
          } else {
            _ratingTextController.text = value.replaceFirst(RegExp(r','), '.');
          }
        },
      ),
    );
  }

  Widget _buildDescriptionTextField(Waifu waifu) {
    if (waifu == null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = '';
    } else if (waifu != null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = waifu.description;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
        maxLines: 4,
        keyboardType: TextInputType.multiline,
        controller: _descriptionTextController,
        decoration: InputDecoration(labelText: 'Description'),
        //initialValue: waifu == null ? '' : waifu.description,
        onSaved: (String value) {
          setState(() {
            _formData['description'] = value;
          });
        },
      ),
    );
  }

  double _getPaddingWidth(double deviceWidth) {
    double targetWidth;
    if (deviceWidth > 550) {
      targetWidth = deviceWidth * 0.75;
      return deviceWidth - targetWidth;
    } else {
      targetWidth = deviceWidth * 0.97;
      return deviceWidth - targetWidth;
    }
  }

  Widget _submitButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      Widget submitButton;
      if (model.selectedWaifuIndex == null) {
        submitButton = RaisedButton(
          child: Text('Create'),
          onPressed: () => _submitForm(model.addProduct, model.updateProduct,
              model.selectWaifu, model.selectedWaifuIndex),
        );
      } else {
        submitButton = RaisedButton(
          child: Text('Save'),
          onPressed: () => _submitForm(model.addProduct, model.updateProduct,
              model.selectWaifu, model.selectedWaifuIndex),
        );
      }
      return model.isloading
          ? Center(
              child: AdaptiveProgressIndicator())
          : submitButton;
    });
  }

  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectedWaifu,
      [int selectedProductIndex]) {
    if (!_formkey.currentState.validate() ||
        (_formData['image'] == null && selectedProductIndex == -1)) {
      return;
    }
    _formkey.currentState.save();
    if (selectedProductIndex == -1) {
      addProduct(
              _nameTextController.text,
              _seriesTextController.text,
              double.parse(_ratingTextController.text),
              _descriptionTextController.text,
              _formData['image'])
          .then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/home')
              .then((_) => setSelectedWaifu(null));
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('OwO Sometwing Went Wwong OwO'),
                content: Text('Pwease Twy Agwain (´･ω･`) Sowwy Senpai'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Okway'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        }
      });
    } else {
      updateProduct(
              _nameTextController.text,
              _seriesTextController.text,
              double.parse(_ratingTextController.text),
              _descriptionTextController.text,
              _formData['image'])
          .then((_) => Navigator.pushReplacementNamed(context, '/home')
              .then((_) => setSelectedWaifu(null)));
    }
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  Widget _buildPageContent(BuildContext context, Waifu selectedWaifu) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: EdgeInsets.all(_getPaddingWidth(deviceWidth)),
        child: Form(
          key: _formkey,
          child: ListView(
            children: <Widget>[
              _buildTitleTextField(selectedWaifu),
              _buildSeriesTextField(selectedWaifu),
              _buildRatingTextField(selectedWaifu),
              _buildDescriptionTextField(selectedWaifu),
              SizedBox(
                height: 20.0,
              ),
              ImageInput(_setImage, selectedWaifu),
              SizedBox(
                height: 10.0,
              ),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return model.selectedWaifuIndex == -1
          ? _buildPageContent(context, model.selectedWaifu)
          : Scaffold(
              appBar: AppBar(
                elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0: 4.0,
                title: Text('Edit Waifu'),
              ),
              body: _buildPageContent(context, model.selectedWaifu),
            );
    });
  }
}
