import 'package:date_utils/date_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/event.dart';
import 'package:flutter_calendar/event_list.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

typedef DayBuilder(BuildContext context, DateTime day);

class Calendar extends StatefulWidget {
  /// 日期选中回调
  final Function(DateTime, List<Event>) onDateSelected;

  /// 日期范围回调
  final ValueChanged<Tuple2<DateTime, DateTime>> onSelectedRangeChange;

  /// 是否展开
  final bool isExpanded;
  final DayBuilder dayBuilder;
  final DateTime initialCalendarDateOverride;

  /// 切换展开与否的widget
  final Widget toggleExpanded;

  /// 今天的背景色
  final Color todayColor;

  /// 选中的背景色
  final Color selectedColor;

  /// 普通字体色
  final Color normalColor;

  /// 有事件时的标记widget
  final Widget markedDateWidget;

  /// 事件
  final EventList<Event> events;

  /// 头部标题样式
  final TextStyle headerTitleStyle;

  Calendar(
      {this.onDateSelected,
      this.onSelectedRangeChange,
      this.isExpanded: false,
      this.dayBuilder,
      this.initialCalendarDateOverride,
      this.toggleExpanded,
      this.todayColor,
      this.selectedColor,
      this.normalColor,
      this.markedDateWidget,
      this.events,
      this.headerTitleStyle});

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  List<DateTime> selectedMonthsDays;
  Iterable<DateTime> selectedWeeksDays;
  DateTime _selectedDate = DateTime.now();
  DateTime _today = DateTime.now();
  String currentMonth;
  String displayMonth;

  DateTime get selectedDate => _selectedDate;

  void initState() {
    super.initState();
    if (widget.initialCalendarDateOverride != null) _selectedDate = widget.initialCalendarDateOverride;
    selectedMonthsDays = Utils.daysInMonth(_selectedDate);
    var firstDayOfCurrentWeek = Utils.firstDayOfWeek(_selectedDate);
    var lastDayOfCurrentWeek = Utils.lastDayOfWeek(_selectedDate);
    selectedWeeksDays = Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList().sublist(0, 7);
    displayMonth = DateFormat.yMMM("zh_CN").format(_selectedDate);
  }

  Widget get nameAndIconRow {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 16),
            child: Text(
              displayMonth,
              style: widget.headerTitleStyle ??
                  TextStyle(fontSize: 20.0, color: widget.todayColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          child: widget.toggleExpanded ?? null,
        ),
      ],
    );
  }

  Widget get calendarGridView {
    return Container(
      child: GestureDetector(
        onHorizontalDragStart: (gestureDetails) => beginSwipe(gestureDetails),
        onHorizontalDragUpdate: (gestureDetails) => getDirection(gestureDetails),
        onHorizontalDragEnd: (gestureDetails) => endSwipe(gestureDetails),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 7,
          padding: EdgeInsets.only(bottom: 0.0),
          children: calendarBuilder(),
        ),
      ),
    );
  }

  List<Widget> calendarBuilder() {
    List<Widget> dayWidgets = [];
    List<DateTime> calendarDays = widget.isExpanded ? selectedMonthsDays : selectedWeeksDays;
    Utils.weekdays.forEach(
      (day) {
        dayWidgets.add(
          calendarTile(
            isDayOfWeek: true,
            dayOfWeek: day,
          ),
        );
      },
    );

    bool isThisMonthDay = false;
    calendarDays.forEach(
      (day) {
        bool isPrevMonthDay = day.month < _selectedDate.month;
        bool isNextMonthDay = day.month > _selectedDate.month;
        isThisMonthDay = !isPrevMonthDay && !isNextMonthDay;
        DateTime _newDay = DateTime(day.year, day.month, day.day);
        dayWidgets.add(
          calendarTile(
              date: _newDay,
              isThisMonthDay: isThisMonthDay,
              isSelected: Utils.isSameDay(selectedDate, _newDay),
              hasEvent: widget.events != null && widget.events.getEvents(_newDay).isNotEmpty),
        );
      },
    );
    return dayWidgets;
  }

  TextStyle configureDateStyle(monthStarted, monthEnded) {
    TextStyle dateStyles;
    final TextStyle body1Style = Theme.of(context).textTheme.body1;

    if (widget.isExpanded) {
      final TextStyle body1StyleDisabled = body1Style.copyWith(
          color: Color.fromARGB(
        100,
        body1Style.color.red,
        body1Style.color.green,
        body1Style.color.blue,
      ));

      dateStyles = monthStarted && !monthEnded ? body1Style : body1StyleDisabled;
    } else {
      dateStyles = body1Style;
    }
    return dateStyles;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          nameAndIconRow,
          ExpansionCrossFade(
            collapsed: calendarGridView,
            expanded: calendarGridView,
            isExpanded: widget.isExpanded,
          ),
        ],
      ),
    );
  }

  void resetToToday() {
    _selectedDate = DateTime.now();
    var firstDayOfCurrentWeek = Utils.firstDayOfWeek(_selectedDate);
    var lastDayOfCurrentWeek = Utils.lastDayOfWeek(_selectedDate);
    var firstDateOfNewMonth = Utils.firstDayOfMonth(_selectedDate);
    var lastDateOfNewMonth = Utils.lastDayOfMonth(_selectedDate);
    setState(() {
      _selectedDate = _selectedDate;
      selectedWeeksDays = Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      selectedMonthsDays = Utils.daysInMonth(_selectedDate);
      displayMonth = DateFormat.yMMM("zh_CN").format(_selectedDate);
    });

    if (widget.isExpanded) {
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
    } else {
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
    }

    _launchDateSelectionCallback(_selectedDate);
  }

  void nextMonth() {
    setState(() {
      _selectedDate = Utils.nextMonth(_selectedDate);
      var firstDateOfNewMonth = Utils.firstDayOfMonth(_selectedDate);
      var lastDateOfNewMonth = Utils.lastDayOfMonth(_selectedDate);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = Utils.daysInMonth(_selectedDate);
      var firstDayOfCurrentWeek = Utils.firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = Utils.lastDayOfWeek(_selectedDate);
      selectedWeeksDays = Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList().sublist(0, 7);
      displayMonth = DateFormat.yMMM("zh_CN").format(_selectedDate);
    });
  }

  void previousMonth() {
    setState(() {
      _selectedDate = Utils.previousMonth(_selectedDate);
      var firstDateOfNewMonth = Utils.firstDayOfMonth(_selectedDate);
      var lastDateOfNewMonth = Utils.lastDayOfMonth(_selectedDate);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = Utils.daysInMonth(_selectedDate);
      var firstDayOfCurrentWeek = Utils.firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = Utils.lastDayOfWeek(_selectedDate);
      selectedWeeksDays = Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList().sublist(0, 7);
      displayMonth = DateFormat.yMMM("zh_CN").format(_selectedDate);
    });
  }

  void nextWeek() {
    setState(() {
      _selectedDate = Utils.nextWeek(_selectedDate);
      var firstDayOfCurrentWeek = Utils.firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = Utils.lastDayOfWeek(_selectedDate);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeeksDays = Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList().sublist(0, 7);
      selectedMonthsDays = Utils.daysInMonth(_selectedDate);
      displayMonth = DateFormat.yMMM("zh_CN").format(_selectedDate);
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void previousWeek() {
    setState(() {
      _selectedDate = Utils.previousWeek(_selectedDate);
      var firstDayOfCurrentWeek = Utils.firstDayOfWeek(_selectedDate);
      var lastDayOfCurrentWeek = Utils.lastDayOfWeek(_selectedDate);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeeksDays = Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList().sublist(0, 7);
      selectedMonthsDays = Utils.daysInMonth(_selectedDate);
      displayMonth = DateFormat.yMMM("zh_CN").format(_selectedDate);
    });
    _launchDateSelectionCallback(_selectedDate);
  }

  void updateSelectedRange(DateTime start, DateTime end) {
    var selectedRange = Tuple2<DateTime, DateTime>(start, end);
    if (widget.onSelectedRangeChange != null) {
      widget.onSelectedRangeChange(selectedRange);
    }
  }

  var gestureStart;
  var gestureDirection;

  void beginSwipe(DragStartDetails gestureDetails) {
    gestureStart = gestureDetails.globalPosition.dx;
  }

  void getDirection(DragUpdateDetails gestureDetails) {
    if (gestureDetails.globalPosition.dx < gestureStart) {
      gestureDirection = 'rightToLeft';
    } else {
      gestureDirection = 'leftToRight';
    }
  }

  void endSwipe(DragEndDetails gestureDetails) {
    if (gestureDirection == 'rightToLeft') {
      if (widget.isExpanded) {
        nextMonth();
      } else {
        nextWeek();
      }
    } else {
      if (widget.isExpanded) {
        previousMonth();
      } else {
        previousWeek();
      }
    }
  }

  void handleSelectedDateAndUserCallback(DateTime day) {
    var firstDayOfCurrentWeek = Utils.firstDayOfWeek(day);
    var lastDayOfCurrentWeek = Utils.lastDayOfWeek(day);
    setState(() {
      _selectedDate = day;
      selectedWeeksDays = Utils.daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek).toList();
      selectedMonthsDays = Utils.daysInMonth(day);
      displayMonth = DateFormat.yMMM("zh_CN").format(_selectedDate);
    });
    _launchDateSelectionCallback(day);
  }

  void _launchDateSelectionCallback(DateTime day) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected(day, widget.events.getEvents(day));
    }
  }

  Widget calendarTile(
      {DateTime date,
      bool hasEvent = false,
      bool isDayOfWeek = false,
      bool isSelected = false,
      String dayOfWeek = '',
      bool isThisMonthDay = false}) {
    List<Widget> _list = [];
    Color _color = Colors.grey;
    if (isDayOfWeek) {
      _color = widget.normalColor;
    } else {
      if (isSelected || isToday(date)) {
        _color = Colors.white;
      } else if (isThisMonthDay) {
        _color = widget.normalColor;
      }
    }

    Widget _day = Text(isDayOfWeek ? dayOfWeek : Utils.formatDay(date).toString(),
        style: TextStyle(color: _color), textAlign: TextAlign.center);
    if (isDayOfWeek) {
      _list.add(FlatButton(
        onPressed: null,
        child: _day,
        shape: CircleBorder(),
      ));
    } else {
      if (isToday(date)) {
        _list.add(RaisedButton(
//          elevation: 4.0,
            onPressed: isDayOfWeek ? null : () => handleSelectedDateAndUserCallback(date),
            child: _day,
            shape: CircleBorder(),
            color: widget.todayColor));
      } else {
        _list.add(FlatButton(
            onPressed: isDayOfWeek ? null : () => handleSelectedDateAndUserCallback(date),
            child: _day,
            shape: CircleBorder(),
            color: isSelected ? widget.selectedColor : null));
      }
      if (hasEvent && widget.markedDateWidget != null) {
        print('hasEvent');
        print(DateTime(2019, 3, 22));
        _list.add(widget.markedDateWidget);
      }
    }
    return Container(
      child: Stack(
        overflow: Overflow.visible,
        children: _list,
      ),
    );
  }

  bool isToday(DateTime date) {
//    print('today $_today');
//    print('date $date');
    return _today.year == date.year && _today.month == date.month && _today.day == date.day;
  }
}

class ExpansionCrossFade extends StatelessWidget {
  final Widget collapsed;
  final Widget expanded;
  final bool isExpanded;

  ExpansionCrossFade({this.collapsed, this.expanded, this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: AnimatedCrossFade(
        firstChild: collapsed,
        secondChild: expanded,
        crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
