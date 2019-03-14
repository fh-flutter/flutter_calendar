import 'package:flutter/material.dart';
import 'package:flutter_calendar/flutter_calendar.dart';

main() {
  runApp(CalendarViewApp());
}

class CalendarViewApp extends StatelessWidget {
  void handleNewDate(date) {
    print("handleNewDate $date");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Calendar'),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(
            horizontal: 5.0,
            vertical: 10.0,
          ),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Text('The Default Calendar:'),
              Calendar(
                onDateSelected: (date) => handleNewDate(date),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
