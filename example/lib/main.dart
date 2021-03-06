import 'package:flutter/material.dart';
import 'package:flutter_calendar/event.dart';
import 'package:flutter_calendar/event_list.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

main() {
  runApp(CalendarViewApp());
}

class CalendarViewApp extends StatefulWidget {
  @override
  _CalendarViewAppState createState() => _CalendarViewAppState();
}

class _CalendarViewAppState extends State<CalendarViewApp> {
  bool _weekFormat = false;

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
                isExpanded: _weekFormat,
                toggleExpanded: IconButton(
                  icon: Icon(
                    _weekFormat ? Icons.calendar_today : Icons.calendar_view_day,
                    color: Color(0xFF609EFE),
                  ),
                  onPressed: () {
                    setState(() {
                      _weekFormat = !_weekFormat;
                    });
                  },
                ),
                events: EventList<Event>(events: {
                  DateTime(2019, 3, 22): [Event(date: DateTime(2019, 3, 22), title: 'ceshi')]
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
