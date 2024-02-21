library toast_practice;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum toastPosition { TOP, BOTTOM, CENTER }
enum toastAnimation { TOP, BOTTOM, RIGHT, LEFT }

typedef PositionBuilder = Widget Function(BuildContext context, Widget child);

///Queue
// List<_ToastEntry> overlayQueue = []; // 큐 list
// bool queueState = true; // 큐 실행 확인
// Timer? timer;
// OverlayEntry? entryQueue; // 큐에 들어갈 객체
//
// Queue<_ToastEntry> queue = Queue();

ToastManager toastManager = ToastManager();

class ToastView {

  // Queue<_ToastEntry> overlayQueue = Queue(); // 큐 객체 생성
  // bool queueState = true; // 큐 실행 확인
  // Timer? timer;
  // OverlayEntry? entryQueue; // 큐에 들어갈 객체



  //생성자
  ToastView();

  ///toast생성
  void createToast(
      {required Widget child,
      toastPosition? position,
      required BuildContext context,
      Duration duration = const Duration(seconds: 2), // 기본 설정
      PositionBuilder? positionBuilder,
      toastAnimation? animation
      }) {
    showToast(
        child, position, context, duration, positionBuilder, animation);
    print(toastManager.overlayQueue.length);

    if (toastManager.queueState) {// 큐가 실행 중인지 확인
      toastManager.startQueue(context); // toast 순차적으로 실행
    }
  }

  /// 오버레이 생성
  /// [child] custom 위젯
  /// [toastPosition]
  /// [positionBuilder]
  /// positionBuilder:  (context, child) {
  //           return Stack(
  //             alignment: Alignment.center,
  //             children: [
  //               Positioned(child: child,
  //                   top: 200,
  //                   left: 300),
  //             ],
  //           );
  //         }
  void showToast(
      Widget child,
      toastPosition? position,
      BuildContext context,
      duration,
      PositionBuilder? positionBuilder,
      toastAnimation? animation) {


    ///positionBuilder일때 stack처럼 쌓이게 하려면 큐에 담지말아야함.
    ///positionBuilder와 animation 속성 확인. null값에 따라 overlay에 담는게 달라짐.
    OverlayEntry newEntry = OverlayEntry(builder: (context) {
      Widget resultWidget;

      if (positionBuilder != null && animation == null) {// custom 위젯이 있으면 custom위젯 반환
        resultWidget = positionBuilder(context, child);
      } else if (positionBuilder == null && animation == null) {
        resultWidget = _getPositionWidget(child, position);
      } else if (positionBuilder != null && animation != null) {
        Widget child2 = positionBuilder(context, child);
        resultWidget = _AnimationToast(child2, animation);
      } else if (positionBuilder == null && animation != null) {
        Widget child2 = _getPositionWidget(child, position);
        resultWidget = _AnimationToast(child2, animation);
      }else{
        resultWidget = _getPositionWidget(child, position);
      }

      return resultWidget;
    });

    toastManager.overlayQueue.add(_ToastEntry(
        entry: newEntry, duration: duration)); // toast 하나가 만들어질때마다 큐에 담음
    //Overlay.of(context)?.insert(newEntry); // overlay 실행
    //return newEntry;
  }

  ///position
  Widget _getPositionWidget(Widget child, toastPosition? position) {
    Widget positionedWidget;
    switch (position) {
      case toastPosition.TOP:
        positionedWidget =
            Positioned(top: 50.0, child: child);
        break;
      case toastPosition.BOTTOM:
         positionedWidget =
            Positioned(bottom: 50.0, child: child);
        break;
      case toastPosition.CENTER:
        positionedWidget =
            Positioned(left: 24.0, right: 24.0, child: child);
        break;
      default:
        positionedWidget =
            Positioned(bottom: 50.0, child: child);
        break;
      //return Positioned(bottom: 50.0, left: 24.0, right: 24.0, child: child);
    }

    return Stack(
      alignment: Alignment.center,
      children: [positionedWidget],
    );
  }

  /// 순차적으로 큐에 담긴 오버레이 실행.
  /// 큐가 실행중이 아닐 때만 실행(중복실행 x)
  /// 큐가 비어있으면 실행 x
  /// []
  // void startQueue(BuildContext context) {
  //
  //   if (overlayQueue.isNotEmpty && entryQueue == null) {
  //     queueState = false; // 실행 여부
  //     //final toastEntry = overlayQueue.removeAt(0); // 큐 첫번째 push, 변수에 담음
  //     final toastEntry = overlayQueue.removeFirst();
  //     entryQueue = toastEntry.entry;
  //     Overlay.of(context)?.insert(entryQueue!); // 오버레이 실행
  //
  //     timer = Timer(toastEntry.duration, () {// duration 시간만큼 실행 후 오버레이 삭제
  //       entryQueue?.remove(); // 오버레이 닫음
  //       entryQueue = null;
  //       startQueue(context); // 재귀함수
  //     });
  //   } else if (overlayQueue.isEmpty) {
  //     // 큐가 비어있을 때 큐 실행 종료
  //     queueState = true;
  //   }
  // }
}

class ToastManager {
  Queue<_ToastEntry> overlayQueue = Queue(); // 큐 객체 생성
  bool queueState = true; // 큐 실행 확인
  Timer? timer;
  OverlayEntry? entryQueue; // 큐에 들어갈 객체



  void startQueue(BuildContext context) {
    if (overlayQueue.isNotEmpty && entryQueue == null) {
      queueState = false; // 실행 여부
      final toastEntry = overlayQueue.removeFirst(); // 큐 첫번째 push, 변수에 담음
      entryQueue = toastEntry.entry;
      Overlay.of(context)?.insert(entryQueue!); // 오버레이 실행

      timer = Timer(toastEntry.duration, () {
        // duration 시간만큼 실행 후 오버레이 삭제
        entryQueue?.remove(); // 오버레이 닫음
        entryQueue = null;
        startQueue(context); // 재귀함수
      });
    } else if (overlayQueue.isEmpty) {
      // 큐가 비어있을 때 큐 실행 종료
      queueState = true;
    }
  }

  void enqueue(_ToastEntry toastEntry, BuildContext context) {
    overlayQueue.add(toastEntry);
    if (queueState) {
      startQueue(context);
    }
  }
}

/// Queue Object
class _ToastEntry {
  final OverlayEntry entry;
  final Duration duration;

  _ToastEntry({
    required this.entry,
    required this.duration,
  });
}

/// Animation
class _AnimationToast extends StatefulWidget {
  _AnimationToast(this.child, this.animation, {Key? key}) : super(key: key);

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


  ///animation 동작 정의
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    topAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    bottomAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));
    //
    // centerAnimation =
    //     Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0))
    //         .animate(CurvedAnimation(
    //             parent: _animationController!, curve: Curves.easeInCubic));

    rightAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    leftAnimation =
        Tween<Offset>(begin: const Offset(-1, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    _animationController.forward();
  }

  Animation<Offset> AnimationType(toastAnimation animation) {
    switch (animation) {
      case toastAnimation.TOP:
        return topAnimation;
      case toastAnimation.BOTTOM:
        return bottomAnimation;
      // case toastAnimation.CENTER:
      //   return centerAnimation;
      case toastAnimation.RIGHT:
        return rightAnimation;
      case toastAnimation.LEFT:
        return leftAnimation;
    }
  }

  @override
  void dispose() {
    if (_animationController.isAnimating) {// 애니메이션 중인지 확인
      _animationController.stop();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SlideTransition(
        position: AnimationType(widget.animation), child: widget.child);
  }
}
