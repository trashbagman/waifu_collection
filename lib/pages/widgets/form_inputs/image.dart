import 'dart:io';
import '../../../models/waifu.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final Function setImage;
  final Waifu waifu;

  ImageInput(this.setImage, this.waifu);

  @override
  State<StatefulWidget> createState() {
    return ImageInputState();
  }
}

class ImageInputState extends State<ImageInput> {
  File _imageFile;

  void getImage(BuildContext context, ImageSource source) {
    ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
      setState(() {
        _imageFile = image;
      });
      widget.setImage(image);
      Navigator.pop(context);
    });
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: 150,
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Pick an Image',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  FlatButton(
                    textColor: Theme.of(context).accentColor,
                    child: Text('Use Camera'),
                    onPressed: () {
                      getImage(context, ImageSource.camera);
                    },
                  ),
                  FlatButton(
                    textColor: Theme.of(context).accentColor,
                    child: Text('Use Gallary'),
                    onPressed: () {
                      getImage(context, ImageSource.gallery);
                    },
                  ),
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).accentColor;
    Widget previewImage = Text('Please select an image');
    if (_imageFile != null) {
      previewImage = Image.file(
        _imageFile,
        fit: BoxFit.cover,
        height: 300,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
      );
    } else if (widget.waifu != null) {
      previewImage = Image.network(
        widget.waifu.image,
        fit: BoxFit.cover,
        height: 300,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
      );
    }

    return Column(
      children: <Widget>[
        OutlineButton(
            borderSide: BorderSide(color: buttonColor, width: 2.0),
            onPressed: () {
              _openImagePicker(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.camera_alt,
                  color: buttonColor,
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text(
                  'Add Image',
                  style: TextStyle(color: buttonColor),
                ),
              ],
            )),
        SizedBox(
          height: 10.0,
        ),
        previewImage,
      ],
    );
  }
}
