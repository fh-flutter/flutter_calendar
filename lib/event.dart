import 'package:flutter/material.dart';

class Event {
  final DateTime date;
  final String title;

  Event({this.date, this.title}) : assert(date != null);

  @override
  bool operator ==(other) {
    return this.date == other.date &&
      this.title == other.title;
  }

  @override
  int get hashCode => hashValues(date, title);
}
