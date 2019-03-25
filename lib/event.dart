import 'package:flutter/material.dart';

class Event<T> {
  final DateTime date;
  final String title;
  final T data;

  Event({this.date, this.title, this.data}) : assert(date != null);

  @override
  bool operator ==(other) {
    return this.date == other.date &&
      this.title == other.title;
  }

  @override
  int get hashCode => hashValues(date, title);
}
