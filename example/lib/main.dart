import 'package:flutter/material.dart';
import 'package:flutter_calendar/event.dart';
import 'package:flutter_calendar/event_list.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('zh', 'CN'), // Simplified Chinese
        const Locale('en', 'US'), // English
      ],
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
              Calendar(
                  onDateSelected: (date, events) => handleNewDate(date),
                  todayColor: Colors.blue,
                  selectedColor: Color(0xFFC9CFD9),
                  events: EventList<Event>(events: {
                    DateTime(2019, 3, 22): [Event(date: DateTime(2019, 3, 22), title: 'ceshi')]
                  }),
                  markedDateWidget: Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        decoration:
                            BoxDecoration(color: Color(0xFFFF8239), borderRadius: BorderRadius.all(Radius.circular(4))),
                        height: 5.0,
                        width: 5.0,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
