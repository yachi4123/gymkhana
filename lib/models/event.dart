import 'package:flutter/material.dart';

class Event {
  final String title;
  final String description;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final String postedBy;
  final DateTime postedAt;
  final String location;
  final DateTime dateTime;

  Event({
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.videoUrls,
    required this.postedBy,
    required this.postedAt,
    required this.location,
    required this.dateTime,
  });
}
