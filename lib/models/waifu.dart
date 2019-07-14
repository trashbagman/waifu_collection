import 'package:flutter/material.dart';

class Waifu {
  final String id;
  final String name;
  final String series;
  final String description;
  final String image;
  final String imagePath;
  final double rating;
  final bool isFavorated;
  final String userEmail;
  final String userId;

  Waifu(
      {@required this.name,
      @required this.series,
      @required this.description,
      @required this.rating,
      @required this.image,
      @required this.userEmail,
      @required this.userId,
      @required this.id,
      @required this.imagePath,
      this.isFavorated = false,
      });
}
