import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:tuple/tuple.dart';

typedef Widget DateWidgetGenerator(DateTime dateTime);
typedef Widget ContentWidgetGenerator<E>(E data);

class TimeLine<E> extends StatelessWidget {
  final List<Tuple2<DateTime, E>> items;
  final DateWidgetGenerator dateWidgetGenerator;
  final ContentWidgetGenerator<E> contentWidgetGenerator;

  TimeLine(
      {@required this.items,
      @required this.dateWidgetGenerator,
      @required this.contentWidgetGenerator}) {
    items.sort((tuple1, tuple2) => tuple1.item1.compareTo(tuple2.item1));
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: items.map((tuple) {
        return new Row(
          children: <Widget>[
            dateWidgetGenerator(tuple.item1),
            new CustomPaint(
              size: new Size(32.0, 32.0),
              painter: new MyPainter(
                isStart: items.first == tuple,
                isEnd: items.last == tuple,
              ),
            ),
            new Expanded(
              child: contentWidgetGenerator(tuple.item2),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class MyPainter extends CustomPainter {
  final bool isStart;
  final bool isEnd;
  final Color pointColor;
  final Color lineColor;

  MyPainter(
      {this.isStart = false,
      this.isEnd = false,
      this.lineColor = Colors.purple,
      this.pointColor = Colors.purple});

  @override
  void paint(Canvas canvas, Size size) {
    double middleWidth = size.width / 2;
    double middleHeight = size.height / 2;
    canvas.drawLine(
      new Offset(middleWidth, isStart ? middleHeight : 0.0),
      new Offset(middleWidth, isEnd ? middleHeight : size.height),
      new Paint()
        ..color = lineColor
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(new Offset(middleWidth, middleHeight), 5.0,
        new Paint()..color = pointColor);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
