library toast_practice;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum toastPosition { TOP, BOTTOM, CENTER }
typedef PositionBuilder = Widget Function(BuildContext context, Widget child);

class toast {
  //static void showToast(String msg,BuildContext context){}
}


class ToastView {

  static int addOne(int value) => value + 1;

  OverlayEntry? _overlayEntry;

  ToastView();

  void createToast({
    required Widget child,
    toastPosition? position,
    required BuildContext context,
    Duration duration = const Duration(seconds: 2),  /// 기본 설정
    PositionBuilder? positionBuilder,


  }) async {
    _overlayEntry = showToast(child, position, context, positionBuilder);

    ///일정 시간 후에 OverlayEntry를 제거
    Future.delayed(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  static OverlayEntry showToast(
      Widget child, toastPosition? position, BuildContext context,PositionBuilder? positionBuilder) {
    print('Toast!!!!!');

    OverlayEntry newEntry = OverlayEntry(builder: (context) {
      if(positionBuilder != null){print('custom'); return positionBuilder(context, child);} /// custom 위젯이 있으면 custom위젯 반환
      print('no custom');
      return _getPositionWidget(child, position);
    });

    Overlay.of(context)?.insert(newEntry);
    return newEntry;
  }
}

_getPositionWidget(Widget child, toastPosition? position) {
  switch (position) {
    case toastPosition.TOP:
      return Positioned(top: 50.0, left: 24.0, right: 24.0, child: child);
    case toastPosition.BOTTOM:
      return Positioned(bottom: 50.0, left: 24.0, right: 24.0, child: child);
    case toastPosition.CENTER:
      return Positioned(top: 50.0, bottom: 50.0, left: 24.0, right: 24.0, child: child);
    default:
      return Positioned(bottom: 50.0, left: 24.0, right: 24.0, child: child);
  }
}
