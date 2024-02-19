import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

void showToast() {
  // Toast를 표시하는 로직을 구현합니다.
  print('Toast가 표시되었습니다.'); // 테스트용으로 콘솔에 출력합니다.
}

// enum Toast{
// LENGTH_SHORT,
//
// LENGTH_LONG
// }
//
// class FlutterToast{
//
//
// }
//
// typedef PositionedToastBuilder = Widget Function(BuildContext context, Widget child);
//
// void showToast({
//   required Widget child,
//   PositionedToastBuilder? positionedToastBuilder,
// }) {
//   Widget newChild = _ToastStateFul(child);
//
//   OverlayEntry newEntry = OverlayEntry(builder: (context){
//     if (positionedToastBuilder != null) return positionedToastBuilder(context, newChild);
//     return _getPostionWidgetBasedOnGravity(newChild);
//   });
//
// }
// _getPostionWidgetBasedOnGravity(Widget child){
//   return Positioned(top: 100, left:24, right: 24, child: child);
// }
//
// class _ToastStateFul extends StatefulWidget{
//   _ToastStateFul(this.child);
//
//   final Widget child;
//
//   @override
//   ToastStateFulState createState() => ToastStateFulState();
// }
//
// class ToastStateFulState extends State<_ToastStateFul> with SingleTickerProviderStateMixin{
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
//
// }


