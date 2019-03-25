import 'package:flutter/material.dart';
import 'package:date_utils/date_utils.dart';

class CalendarTile extends StatelessWidget {
  final VoidCallback onDateSelected;
  final DateTime date;
  final String dayOfWeek;
  final bool isDayOfWeek;
  final bool isSelected;
  final TextStyle dayOfWeekStyles;
  final TextStyle dateStyles;
  final Widget child;
  final bool hasEvent;

  CalendarTile({
    this.onDateSelected,
    this.date,
    this.child,
    this.dateStyles,
    this.dayOfWeek,
    this.dayOfWeekStyles,
    this.isDayOfWeek: false,
    this.isSelected: false,
    this.hasEvent: false
  });

  Widget renderDateOrDayOfWeek(BuildContext context) {
    if (isDayOfWeek) {
      return FlatButton(
        onPressed: null,
        child: Container(
          alignment: Alignment.center,
          child: Text(
            dayOfWeek,
          ),
        ),
      );
    } else {
      return FlatButton(
        onPressed: onDateSelected,
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                )
              : BoxDecoration(),
          alignment: Alignment.center,
          child: Text(
            Utils.formatDay(date).toString(),
            style: isSelected ? Theme.of(context).primaryTextTheme.body1 : dateStyles,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return InkWell(
        child: child,
        onTap: onDateSelected,
      );
    }
    return Container(
      child: renderDateOrDayOfWeek(context),
    );
  }
}
