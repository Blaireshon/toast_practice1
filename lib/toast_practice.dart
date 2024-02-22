library toast_practice;

import 'dart:async';
import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 토스트 위치(고정값)
/// 위치 고정값으로 지정되어있음
/// [TOP] Positioned(top: 50.0, child: child);
/// [BOTTOM] Positioned(bottom: 50.0, child: child);
/// [CENTER] Positioned(bottom: 50.0, child: child);
/// For example,
// position: toastPosition.BOTTOM
enum toastPosition { TOP, BOTTOM, CENTER }


/// 토스트 위치(사용자 설정)
/// For example,
// toastView.createToast(
// child: toast,
// context: context,
// duration: const Duration(seconds: 3), //시간 설정
// positionBuilder:  (context, child) {
//    return Stack(
//      alignment: Alignment.center,
//      children: [
//        Positioned(child: child,
/// 원하는 위치 설정
//            top: 200,
//            left: 300),
//      ],
//    );
//  }
// );
typedef PositionBuilder = Widget Function(BuildContext context, Widget child);


/// 토스트 실행될 때 나타나는 방향 애니메이션
/// [TOP] Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0)) : 위에서 아래로
/// [BOTTOM] Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0)) : 아래에서 위로
/// [RIGHT] Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0)) : 화면 오른쪽에서 왼쪽으로
/// [LEFT] Tween<Offset>(begin: const Offset(-1, 0), end: const Offset(0, 0)) : 화면 왼쪽에서 오른쪽으로
/// For example,
//animation: toastAnimation.RIGHT
enum toastAnimation { TOP, BOTTOM, RIGHT, LEFT }

/// toast를 어떻게 보여줄지 설정
/// [LAYER] : toast를 여러개를 겹쳐서 보여줌
/// [STACK] : toast를 쌓아서 여러개를 보여줌
/// [NORMAL] : toast를 하나씩 보여줌.
enum toastpresentation {LAYER,STACK,NORMAL}


/// toast를 순차적으로 보여주는 클래스 인스턴스화/객체생성
/// [toastpresentation]의 [toastpresentation.NORMAL]일때 실행 됨
ToastManager toastManager = ToastManager();

/// toast를 생성하는 클래스
/// [createToast] : toast 생성
/// [showToast] : 생성된 toast를 OverlayEntry객체에 담고 Queue에 담음
/// [_getPositionWidget] : 사용자가 위치를 설정하지 않고 [toastPosition] 고정값으로 설정하면 이 함수를 통해 Stack 위젯 반환
/// --> return Stack
class ToastView {

  /// toast생성
  /// --> return void
  /// required [child] : toast내용이 들어가는 위젯
  /// [position] : [toastPosition] { TOP, BOTTOM, CENTER } 위치 고정값
  /// required [context]
  /// [duration] : toast가 화면에 띄어지는 시간
  /// [fadeDuration] : toast가 opacity값을 사용해서 사라지는 애니메이션의 시간 설정
  /// [positionBuilder] : toast 사용자 위치 설정
  /// [animation] : [toastAnimation] { TOP, BOTTOM, RIGHT, LEFT } toast 띄울 때 애니메이션 효과
  /// [toastpresentation]
   void createToast(
      {required Widget child,
      toastPosition? position,
      required BuildContext context,
      Duration duration = const Duration(seconds: 2), // 기본 설정
        Duration fadeDuration = const Duration(seconds: 0),
      PositionBuilder? positionBuilder,
      toastAnimation? animation,
        required toastpresentation presentation
      }) {

     /// 오버레이 생성 및 큐에 각 toast add
     /// --> return void
    showToast(
        child, position, context, duration, fadeDuration, positionBuilder, animation, presentation);
    print('length : ' + (toastManager.overlayQueue.length).toString());

    /// 큐가 실행 중인지 확인
    /// Bool [queueState] : true 큐 비었음, flase 큐에 실행될 toast객체가 담겨져 있고 하나씩 실행 중
    /// 큐가 실행 중(toastManager.queueState == false)이면 큐에 실행할 toast를 담기만 하고 중복으로 실행되지 않게 확인함
    if (toastManager.queueState) {
      // toast 순차적으로 실행
      toastManager.startQueue(context);
    }
  }


  /// 오버레이 생성 후 Queue add
   /// --> return void
  /// [child] : custom 위젯
  /// [position] : [toastPosition] { TOP, BOTTOM, CENTER } 위치 고정값
   /// [duration] : toast가 화면에 띄어지는 시간
   /// [fadeDuration] : toast가 opacity값을 사용해서 사라지는 애니메이션의 시간 설정
  /// [positionBuilder]
  // positionBuilder:  (context, child) {
  //           return Stack(
  //             alignment: Alignment.center,
  //             children: [
  //               Positioned(child: child,
  //                   top: 200,
  //                   left: 300),
  //             ],
  //           );
  //         }
   /// [animation] : [toastAnimation] { TOP, BOTTOM, RIGHT, LEFT } toast 띄울 때 애니메이션 효과
  void showToast(
      Widget child,
      toastPosition? position,
      BuildContext context,
      duration,
      fadeDuration,
      PositionBuilder? positionBuilder,
      toastAnimation? animation,
      toastpresentation presentation) {


    /// 오버레이 생성
    /// --> return OverlayEntry
    /// 사용자가 toast 커스텀을 어떻게 했는지에 따라 반환 위젯이 달라지고 그 위젯들은 오버레이 객체에 담겨 Queue를 통해 순차적으로 실행됨
    /// 1. [animation]이나 [fadeDuration]을 통해 애니메이션 효과를 줄 때 [_AnimationToast]를 통해 FadeTransition 위젯 반환
    /// 2. [positionBuilder]가 null값인지 확인을 통해 사용자가 위치를 직접 설정해는지 확인 후 Stack 위젯 반환
    // positionBuilder일때 stack처럼 쌓이게 하려면 큐에 담지말아야함.
    // positionBuilder와 animation 속성 확인. null값에 따라 overlay에 담는게 달라짐.
    OverlayEntry newEntry = OverlayEntry(builder: (context) {
      Widget resultWidget;

      if (positionBuilder != null &&
          (animation == null && fadeDuration == const Duration(seconds: 0))) {
        print('1 :');
        resultWidget = positionBuilder(context, child);
      } else if (positionBuilder == null &&
          (animation == null && fadeDuration == const Duration(seconds: 0))) {
        print('2 :');
        resultWidget = _getPositionWidget(child, position);
      } else if (positionBuilder != null &&
          (animation != null || fadeDuration != const Duration(seconds: 0))) {
        print('3 :');
        Widget child2 = positionBuilder(context, child);
        resultWidget =
            _AnimationToast(child2, animation, duration, fadeDuration);
      } else if (positionBuilder == null &&
          (animation != null || fadeDuration != const Duration(seconds: 0))) {
        print('4 :');
        Widget child2 = _getPositionWidget(child, position);
        resultWidget =
            _AnimationToast(child2, animation, duration, fadeDuration);
      } else {
        print('5 :');
        resultWidget = _getPositionWidget(child, position);
      }
      return resultWidget;
    });

    /// 반환 된 위젯들을 순차적으로 실행시키기 위해 Queue에 추가
    // _ToastEntry({
    //   required this.entry, : 실행 할 toast 객체
    //   required this.duration, : toast를 얼만큼 화면에 띄울 지 시간설정
    //   required this.fadeDuration : toast가 사라지는 효과 시간 설정
    // });
    if (presentation == toastpresentation.NORMAL) {
      toastManager.overlayQueue.add(_ToastEntry(
        // toast 하나가 만들어질때마다 큐에 담음
          entry: newEntry, duration: duration, fadeDuration: fadeDuration));
      //Overlay.of(context)?.insert(newEntry); // overlay 실행
      //return newEntry;
    } else if (presentation == toastpresentation.LAYER) {
      Overlay.of(context)?.insert(newEntry); // overlay 실행

    }
  }

  /// position
   /// --> return Stack
  Widget _getPositionWidget(Widget child, toastPosition? position) {
    print('_getPositionWidget');
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

      final totalDuration = toastEntry.duration+ toastEntry.fadeDuration;
      timer = Timer(totalDuration, () {
        print('totalDuration ' + totalDuration.toString());
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
}

/// Queue Object
class _ToastEntry {
  final OverlayEntry entry;
  final Duration duration;
  final Duration fadeDuration;

  _ToastEntry({
    required this.entry,
    required this.duration,
    required this.fadeDuration
  });
}

/// Animation
class _AnimationToast extends StatefulWidget {

  _AnimationToast(this.child, this.animation,this.duration, this.fadeDuration, {Key? key}) : super(key: key);

  final Widget child;
  final toastAnimation? animation;
  final Duration duration;
  final Duration fadeDuration;

  @override
  AnimationToastState createState() => AnimationToastState();

}

class AnimationToastState extends State<_AnimationToast>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> topAnimation;
  late Animation<Offset> bottomAnimation;
  late Animation<Offset> nullAnimation;
  late Animation<Offset> rightAnimation;
  late Animation<Offset> leftAnimation;

  late AnimationController _fadeController;
  late Animation _fadeAnimation;

  Timer? _timer;

  ///animation 동작 정의
  @override
  void initState() {
    print('_AnimationToast');

    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
        // AnimationController(vsync: this, duration: const Duration(seconds: 1));

    topAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    bottomAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    nullAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    rightAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    leftAnimation =
        Tween<Offset>(begin: const Offset(-1, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));


    _fadeController = AnimationController(vsync: this, duration: widget.fadeDuration);
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    _animationController.forward();

    if(widget.fadeDuration != const Duration(seconds: 0)) {
      _timer = Timer(widget.duration, () {
        print('widget.duration :' + (widget.duration).toString());
        _fadeController.forward();
      });
    }

  }

  Animation<Offset> AnimationType(toastAnimation? animation) {
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
      case null:
        return nullAnimation;
    }
  }

  @override
  void dispose() {
    if (_animationController.isAnimating) {
      _animationController.stop();
    }
    _animationController.dispose();
    _fadeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation as Animation<double>,

      child: SlideTransition(
        position: AnimationType(widget.animation),
        child: widget.child,
      ),
    );

  }
}
