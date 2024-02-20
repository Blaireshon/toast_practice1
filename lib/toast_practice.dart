library toast_practice;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum toastPosition { TOP, BOTTOM, CENTER }
enum toastAnimation { TOP, BOTTOM, CENTER, RIGHT, LEFT}

typedef PositionBuilder = Widget Function(BuildContext context, Widget child);

/// queue
OverlayEntry? _entry; // 큐에 들어갈 객체
List<_ToastEntry> _overlayQueue = []; // 큐 list
Timer? _timer;
bool queueState = true; // 큐 실행 확인



class ToastView {
  static int addOne(int value) => value + 1;



  ToastView();


  // OverlayEntry? _overlayEntry;

  void createToast({
    required Widget child,
    toastPosition? position,
    required BuildContext context,
    Duration duration = const Duration(seconds: 2),// 기본 설정
    PositionBuilder? positionBuilder,
    toastAnimation? animation,

  }) {
    showToast(child, position, context, duration, positionBuilder, animation);
    //print(_overlayQueue.length);

    if (queueState) {// 큐가 실행 중인지 확인
      startQueue(context); // toast 순차적으로 실행
    }
  }

  /// 오버레이 생성
  showToast(Widget child, toastPosition? position, BuildContext context, duration, PositionBuilder? positionBuilder,toastAnimation? animation) {

    OverlayEntry newEntry = OverlayEntry(builder: (context) {

      // if (positionBuilder != null) {
      //   return positionBuilder(context, child);} // custom 위젯이 있으면 custom위젯 반환
      // return _getPositionWidget(child, position);
         // 애니메이션 안했을때
      if (positionBuilder != null && animation == null) {// custom 위젯이 있으면 custom위젯 반환
        return positionBuilder(context, child);
      }else if(positionBuilder == null && animation == null) {
        return _getPositionWidget(child, position);
      }else if(positionBuilder != null && animation != null){
        print('positionBuilder != null && animation != null '+ animation.toString());

      }else if(positionBuilder == null && animation != null){
        Widget child2 = _getPositionWidget(child, position);
        return _getAnimationWidget(child2, animation);
      }// 애니메이션 했을때

      return _getPositionWidget(child, position);
    });
    _overlayQueue.add(_ToastEntry(entry: newEntry, duration: duration)); // toast 하나가 만들어질때마다 큐에 담음
    //Overlay.of(context)?.insert(newEntry); // overlay 실행
    //return newEntry;
  }

  /// enum position
  _getPositionWidget(Widget child, toastPosition? position) {
    switch (position) {
      case toastPosition.TOP:
        return Positioned(top: 50.0, left: 24.0, right: 24.0, child: child);
      case toastPosition.BOTTOM:
        return Positioned(bottom: 50.0, left: 24.0, right: 24.0, child: child);
      case toastPosition.CENTER:
        return Positioned(
            top: 50.0, bottom: 50.0, left: 24.0, right: 24.0, child: child);
      default:
        return Positioned(bottom: 50.0, left: 24.0, right: 24.0, child: child);
    }
  }

  _getAnimationWidget(Widget child, toastAnimation? animation){

    return _AnimationToast(child, animation!); // AnimationToast 인스턴스 생성
   // AnimationToastState toastState = animationToast.createState();

    // switch(animation){
    //   case toastAnimation.TOP:
    //     return SlideTransition(position: toastState.topAnimation, child: child);
    //   case toastAnimation.BOTTOM:
    //     return SlideTransition(position: toastState.bottomAnimation, child: child);
    //   case toastAnimation.CENTER:
    //     return SlideTransition(position: toastState.centerAnimation, child: child);
    //   case toastAnimation.RIGHT:
    //     return SlideTransition(position: toastState.rightAnimation, child: child);
    //   case toastAnimation.LEFT:
    //     return SlideTransition(position: toastState.leftAnimation, child: child);
    //   default:
    //     return SlideTransition(position: toastState.topAnimation, child: child);
    //
    // }
  }

  /// 순차적으로 큐에 담긴 오버레이 실행.
  /// 큐가 실행중이 아닐 때만 실행(중복실행 x)
  /// 큐가 비어있으면 실행 x
  void startQueue(BuildContext context) {
    if (_overlayQueue.isNotEmpty && _entry == null) {
      queueState = false; // 실행 여부
      final toastEntry = _overlayQueue.removeAt(0); // 큐 첫번째 push, 변수에 담음
      _entry = toastEntry.entry;
      Overlay.of(context)?.insert(_entry!); // 오버레이 실행

      _timer = Timer(toastEntry.duration, () { // duration 시간만큼 실행 후 오버레이 삭제
        _entry?.remove(); // 오버레이 닫음
        _entry = null;
        startQueue(context); // 재귀함수
      });
    } else if (_overlayQueue.isEmpty) {
      // 큐가 비어있을 때 큐 실행 종료
      queueState = true;
    }
  }
}

/// 큐에 담을 객체
class _ToastEntry {
  final OverlayEntry entry;
  final Duration duration;

  _ToastEntry({
    required this.entry,
    required this.duration,
  });
}


/// 애니메이션 for [ToastView]
class _AnimationToast extends StatefulWidget {
  _AnimationToast(this.child, this.animation, {Key? key}): super(key: key);

  final Widget child;
  final toastAnimation animation;

  @override
  AnimationToastState createState() => AnimationToastState();
}
class AnimationToastState extends State<_AnimationToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<Offset> topAnimation;
  late Animation<Offset> bottomAnimation;
  late Animation<Offset> centerAnimation;
  late Animation<Offset> rightAnimation;
  late Animation<Offset> leftAnimation;


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));

    topAnimation = Tween<Offset>(begin: const Offset(0,0), end: const Offset(0,-1))
        .animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInCubic));

    bottomAnimation = Tween<Offset>(begin: const Offset(0,0), end: const Offset(0,1))
        .animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInCubic));

    centerAnimation = Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0))
        .animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInCubic));

    rightAnimation = Tween<Offset>(begin: const Offset(0,0), end: const Offset(1,0))
        .animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInCubic));

    leftAnimation = Tween<Offset>(begin: const Offset(0,0), end: const Offset(-1,0))
        .animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInCubic));

    _animationController.forward();

  }

  @override
  void dispose() {
    if (_animationController.isAnimating) { // 애니메이션 중인지 확인
      _animationController.stop();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SlideTransition(position: topAnimation, child: widget.child);
  }


}

