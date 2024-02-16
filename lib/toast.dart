import 'package:flutter/cupertino.dart';

class FlutterToast{

}
typedef PositionedToastBuilder = Widget Function(BuildContext context, Widget child);

void showToast({
  required Widget child,
  PositionedToastBuilder? positionedToastBuilder,
}) {
  Widget newChild = _ToastStateFul(child);

  OverlayEntry newEntry = OverlayEntry(builder: (context){
    if (positionedToastBuilder != null) return positionedToastBuilder(context, newChild);
    return _getPostionWidgetBasedOnGravity(newChild);
  });

}
_getPostionWidgetBasedOnGravity(Widget child){
  return Positioned(top: 100, left:24, right: 24, child: child);
}

class _ToastStateFul extends StatefulWidget{
  _ToastStateFul(this.child);

  final Widget child;

  @override
  ToastStateFulState createState() => ToastStateFulState();
}

class ToastStateFulState extends State<_ToastStateFul> with SingleTickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}


