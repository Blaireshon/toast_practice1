/// Example
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             Container(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: () {
                    ///이벤트 발생 시 toast 생성할 메서드 호출
//                   _topToast('top position', context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Color(0xffFCAF17),
//                   elevation: 0,
//                 ),
//                 child: const Text('top position',
//                     style: TextStyle(color: Colors.white)),
//               ),
//             ),
//             SizedBox(height: 10,),
//             Container(
//               width: 200,
//               child: ElevatedButton(
//                 onPressed: () {
//                   _incrementCounter();
                     ///이벤트 발생 시 toast 생성할 메서드 호출
//                   _defaultToast('$_counter', context);
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   elevation: 0,
//                 ),
//                 child: const Text('default',
//                     style: TextStyle(color: Colors.white)),
//               ),
//             ),
//
///toast 생성 메서드
// void _topToast(String msg, BuildContext context) {
//
//   ///toast 생성
//   ToastView.createToast(
//     child: toast(msg),
//     context: context,
//     duration: const Duration(milliseconds: 400), //시간 설정
//     position: toastPosition.TOP,
//     presentation: toastpresentation.LAYER,
//   );
// }
// void _defaultToast(String msg, BuildContext context){
//   ToastView.createToast(
//     child: Text(msg),
//     context: context,
//   );
// }
//
// }
///toast Custom 위젯.
// ///child 위젯 설정
// Widget toast(String msg) {
//   return Container(
//     height: 50,
//     width: 300,
//     decoration: BoxDecoration(
//       borderRadius: BorderRadius.circular(10.0),
//       border: Border.all(),
//       // color: const Color(0xff67CC36),
//       color: Colors.white,
//     ),
//     child: Center(
//         child: Text(msg,
//             style: const TextStyle(
//                 color: Colors.black54,
//                 decoration: TextDecoration.none,
//                 fontSize: 20),
//             textAlign: TextAlign.center)),
//   );
// }

library toast_practice;

import 'dart:async';
import 'dart:collection';
//import 'dart:js';
import 'package:get/get.dart';
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
/// [LAYER] toast를 여러개를 겹쳐서 보여줌
/// [LIST] toast를 쌓아서 여러개를 보여줌
/// [TIMER] toast를 하나씩 보여줌.
enum toastPresentation { LAYER, LIST, TIMER }

/// [toastPresentation.TIMER]일때 실행 됨
ToastManager toastManager = ToastManager();

/// [toastPresentation.LIST]일때 실행 됨
ToastListManager toastListManager = ToastListManager();

/// [toastPresentation.LIST]일때 가장 기초가되는 overlayEntry
OverlayEntry? bottomNewEntry;

/// toast를 생성하는 클래스
/// [createToast] toast 생성
/// [showToast] 생성된 toast를 OverlayEntry객체에 담고 Queue에 담음
/// [_getPositionWidget] 사용자가 위치를 설정하지 않고 [toastPosition] 고정값으로 설정하면 이 함수를 통해 Stack 위젯 반환
/// --> return Stack
class ToastView {
  static int addOne(int value) => value + 1;

  Timer? timer;
  //Timer? listTimer;

  /// toast생성
  /// --> return void
  /// required [child] toast내용이 들어가는 위젯
  /// Nullable [position] { TOP, BOTTOM, CENTER } 위치 고정값
  /// required [context]
  /// [duration] toast가 화면에 띄어지는 시간
  /// [fadeDuration] toast가 opacity값을 사용해서 사라지는 애니메이션의 시간 설정
  /// Nullable [positionBuilder] toast 사용자 위치 설정
  /// Nullable [animation] { TOP, BOTTOM, RIGHT, LEFT } toast 띄울 때 애니메이션 효과
  /// [toastPresentation]
   ToastView.createToast(
      {required dynamic child,
      toastPosition? position = toastPosition.BOTTOM,
      required BuildContext context,
      Duration duration = const Duration(seconds: 2), // 기본 설정
      Duration fadeDuration = const Duration(seconds: 0),
      PositionBuilder? positionBuilder,
      toastAnimation? animation,
        toastPresentation presentation = toastPresentation.LAYER}) {

     child = defaultWidget(child, context);
     // if (child is String) {
     //   // 문자열일 경우 디폴트 위젯에 텍스트로 추가
     //   child = defaultWidget(child, context);
     // } else if (child is Widget) {
     //   // 위젯일 경우 그대로 사용
     //   child = child;
     // } else {
     //   // 예외 처리
     //   throw Exception('Child must be a String or a Widget');
     // }

    /// 오버레이 생성 및 큐에 각 toast add
    /// --> return void
    if (presentation != toastPresentation.LIST) {
      showToast(child, position, context, duration, fadeDuration,
          positionBuilder, animation, presentation);
    } else {
      listToast(child, context, presentation);
    }

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
  /// [child] custom 위젯
  /// Nullable [position] { TOP, BOTTOM, CENTER } 위치 고정값
  /// [duration] toast가 화면에 띄어지는 시간
  /// [fadeDuration] toast가 opacity값을 사용해서 사라지는 애니메이션의 시간 설정
  /// Nullable [positionBuilder]
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
  /// Nullable [animation] { TOP, BOTTOM, RIGHT, LEFT } toast 띄울 때 애니메이션 효과
  void showToast(
      Widget child,
      toastPosition? position,
      BuildContext context,
      duration,
      fadeDuration,
      PositionBuilder? positionBuilder,
      toastAnimation? animation,
      toastPresentation presentation) {
    /// 오버레이 생성
    /// --> return OverlayEntry
    /// 사용자가 toast 커스텀을 어떻게 했는지에 따라 반환 위젯이 달라지고 그 위젯들은 오버레이 객체에 담겨 Queue를 통해 순차적으로 실행됨
    /// 1. [animation]이나 [fadeDuration]을 통해 애니메이션 효과를 줄 때 [_AnimationToast]를 통해 FadeTransition 위젯 반환
    /// 2. [positionBuilder]가 null값인지 확인을 통해 사용자가 위치를 직접 설정해는지 확인 후 Stack 위젯 반환
    // positionBuilder일때 stack처럼 쌓이게 하려면 큐에 담지말아야함.
    // positionBuilder와 animation 속성 확인. null값에 따라 overlay에 담는게 달라짐.
    OverlayEntry newEntry = OverlayEntry(builder: (context) {
      Widget resultWidget;

      if (positionBuilder != null) {
        resultWidget = positionBuilder(context, child);
        if (animation != null || fadeDuration != const Duration(seconds: 0)) {
          resultWidget =
              _AnimationToast(resultWidget, animation, duration, fadeDuration);
        }
      } else {
        resultWidget = _getPositionWidget(child, position);
        if (animation != null || fadeDuration != const Duration(seconds: 0)) {
          resultWidget =
              _AnimationToast(resultWidget, animation, duration, fadeDuration);
        }
      }

      return resultWidget;
    });

    /// 반환 된 위젯들을 순차적으로 실행시키기 위해 Queue에 추가
    // _ToastEntry({
    //   required this.entry, : 실행 할 toast 객체
    //   required this.duration, : toast를 얼만큼 화면에 띄울 지 시간설정
    //   required this.fadeDuration : toast가 사라지는 효과 시간 설정
    // });
    if (presentation == toastPresentation.TIMER) {
      toastManager.overlayQueue.add(_ToastEntry(
          // toast 하나가 만들어질때마다 큐에 담음
          entry: newEntry,
          duration: duration,
          fadeDuration: fadeDuration));
      //Overlay.of(context)?.insert(newEntry); // overlay 실행
      //return newEntry;
    } else if (presentation == toastPresentation.LAYER) {
      Overlay.of(context)?.insert(newEntry); // overlay 실행

      final totalDuration = duration + fadeDuration;
      timer = Timer(totalDuration, () {
        newEntry?.remove();
      });
    }
  }

  /// position (toast 위치 고정값)
  /// --> return Stack
  /// 사용자가 직접 위치설정안하고 기존 고정되어있는 위치를 사용할 때
  /// position: toastPosition.CENTER,

  /// [toastPosition.TOP] Positioned(top: 50.0, child: child);
  /// [toastPosition.BOTTOM] Positioned(bottom: 50.0, child: child);
  /// [toastPosition.CENTER] Positioned(bottom: 50.0, child: child);
  Widget _getPositionWidget(Widget child, toastPosition? position) {
    Widget positionedWidget;
    switch (position) {
      case toastPosition.TOP:
        positionedWidget = Positioned(top: 50.0, child: child);
        break;
      case toastPosition.BOTTOM:
        positionedWidget = Positioned(bottom: 50.0, child: child);
        break;
      case toastPosition.CENTER:
        positionedWidget = Positioned(child: child);
        break;
      default:
        positionedWidget = Positioned(bottom: 50.0, child: child);
        break;
      //return Positioned(bottom: 50.0, left: 24.0, right: 24.0, child: child);
    }

    return Stack(
      alignment: Alignment.center,
      children: [positionedWidget],
    );
  }

  ToastListManager toastListManager = Get.put(ToastListManager());

  ///=============================================================================
  void listToast(
      Widget child, BuildContext context, toastPresentation presentation) {

    /// 처음에 바닥에 깔릴 overlayEntry 만들기
    if (bottomNewEntry == null) {
      print('처음');

      bottomNewEntry = OverlayEntry(
        builder: (BuildContext context) => Positioned(
          top: 50,
          left: 10,
          right: 10,
          child: Column(
            children: [
              //for (_ToastListEntry obj in toastListManager.overlayList)
              for (_ToastListEntry obj in toastListManager.overlayList.reversed) // 역순으로 순회
              Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(child: obj?.child),
                ), // toastList의 모든 메시지를 표시
            ],
          ),
        ),
      );
      Overlay.of(context)?.insert(bottomNewEntry!);
    } else if (bottomNewEntry != null && !bottomNewEntry!.mounted) {
      print('Bottom overlayEntry 실행중');
    }
    _ToastListEntry creatToast =
        _ToastListEntry(child: child, duration: const Duration(seconds: 2));

    toastListManager.overlayList.add(creatToast);

    toastListManager.insertToast(creatToast);

  }

  /// defaultWidget. Toast 형식이 정해져 있음. String과 Widget이 아래 Container의 child로 들어감.
  Widget defaultWidget(dynamic child, BuildContext context){
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color(0xffFCAF17),
      ),
      child: childWidget(child),
    );
  }
  Widget childWidget(dynamic child){
    if( child is String){
      return Center(
          child: Text(child,
              style: const TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.none,
                  fontSize: 20),
              textAlign: TextAlign.center));
    }else if(child is Widget){
      return child;
    }else{
      throw Exception('Child must be a String or a Widget');
    }

  }
}

///Toast List 실행 순서 관리 [toastPresentation.LIST]
/// [overlayList] 화면에 보여줄 토스트 객체 리스트
/// [_overlayEntries] 각 토스트의 overlayEntry.
class ToastListManager {
  List<_ToastListEntry> overlayList = [];
 // OverlayEntry? newEntry;
  List<OverlayEntry> _overlayEntries = [];

  /// toast가 새로 생기거나 사라질때 update
  void _updateToast() {
    bottomNewEntry?.markNeedsBuild();
  }

  /// 이미 실행 된 overlayEntry가 있는데 새로운 toast를 추가할 때
  void insertToast(_ToastListEntry toast) {
    OverlayEntry newEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: 50,
        left: 10,
        right: 10,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(child: toast.child),
            ),
          ],
        ),
      ),
    );

    // 리스트에 추가
    _overlayEntries.add(newEntry);


    toast.entry = newEntry;
    //toast.timer.cancel(); // Cancel the previous timer

    // 생성된지 2초가 지나면 해당 객체 사라짐
    toast.timer = Timer(Duration(seconds: 2), () {
      hideToast(toast);
    });
    _updateToast();
  }

  /// 실행 된 toast가 2초가 지나면 사라질 때
  void hideToast(_ToastListEntry toastEntry) {

    if (_overlayEntries.isNotEmpty) {
      _overlayEntries.remove(toastEntry.entry);
      overlayList.remove(toastEntry);
      //_updateToast();
      // 화면에 보여줄 list가 남아 있으면 다시 실행
      if (_overlayEntries.isNotEmpty) {
        _updateToast();
        // 화면에 보여줄 list가 없으면 토스트 종료
      }else{
        _overlayEntries = [];
        overlayList = [];
        bottomNewEntry?.remove();
        bottomNewEntry = null;
      }
    }
  }
}

/// overlayList에 담길 object
class _ToastListEntry {
  final Widget child;
  late final Duration duration;
  late Timer timer;
  late OverlayEntry entry;

  _ToastListEntry({
    required this.child,
    required this.duration,
  }) {
    timer = Timer(duration, () {
      toastListManager.hideToast(this);
    });
  }
}

///=============================================================================

/// toast 실행 순서 관리 [toastPresentation.LAYER], [toastPresentation.TIMER]
/// Queue<_ToastEntry> [overlayQueue]  toast 객체 관리할 Queue
//class _ToastEntry {
//   final OverlayEntry entry;
//   final Duration duration;
//   final Duration fadeDuration;
// }
/// bool [queueState]  queue가 실행 중인지 상태 확인. true : 실행 가능 / false : 실행 중으로 중복 실행 x
/// Timer? [timer] 화면에 보여줘야 할 시간 관리
/// OverlayEntry? [entryQueue] Queue에 추가 될 OverlayEntry객체
/// [startQueue]
///
class ToastManager {
  Queue<_ToastEntry> overlayQueue = Queue();
  bool queueState = true;
  Timer? timer;
  OverlayEntry? entryQueue;

  /// 순차적으로 큐에 담긴 오버레이 실행.
  /// --> return void
  void startQueue(BuildContext context) {
    if (overlayQueue.isNotEmpty && entryQueue == null) {
      // 중복 실행되지 않도록 queue 실행 중으로 상태 전환.
      queueState = false;
      // queue의 첫번째 pop한 객체<_ToastEntry>를 변수에 담음
      final toastEntry = overlayQueue.removeFirst();
      //<_ToastEntry>의 OverlayEntry객체를 변수에 담음
      entryQueue = toastEntry.entry;
      // 오버레이 실행
      Overlay.of(context)?.insert(entryQueue!);

      // 해당 오버레이가 화면에 띄어져야 할 시간 : duration + fadeDuration
      final totalDuration = toastEntry.duration + toastEntry.fadeDuration;

      timer = Timer(totalDuration, () {
        print('totalDuration ' + totalDuration.toString());
        // duration 시간만큼 실행 후 오버레이 삭제
        entryQueue?.remove();
        entryQueue = null;
        // 재귀함수. overlayQueue에 담긴 객체들이 모두 보여줄때까지 실행반복
        startQueue(context);
      });
    } else if (overlayQueue.isEmpty) {
      // 큐에 있는 toast를 모두 실행 시킨 후 상태를 실행 가능으로 전환.
      queueState = true;
    }
  }
}

/// Queue에 담길 Object
/// Queue<_ToastEntry> overlayQueue에 담길 객체.
/// OverlayEntry [entry] [showToast]에서 생성된 OverlayEntry객체
/// Duration [duration] 사용자가 설정한 toast 보여주는 시간. 설정하지 않으면 기본 설정값 seconds:2
/// Duration [fadeDuration] 사용자가 설정한 toast 사라지는 애니메이션 효과 시간. 설정하지 않으면 기본 설정값 seconds:0
class _ToastEntry {
  final OverlayEntry entry;
  final Duration duration;
  final Duration fadeDuration;

  _ToastEntry(
      {required this.entry,
      required this.duration,
      required this.fadeDuration});
}

/// Animation (slide효과 [animation], fade효과[fadeDuration])
/// Widget [child] 사용자가 custom한 위젯
/// toastAnimation [animation] 사용자가 설정한 animation 효과
/// Duration [duration] 사용자가 설정한 toast 시간
/// Duration [fadeDuration] 사용자가 설정한 fade 효과 시간
class _AnimationToast extends StatefulWidget {
  _AnimationToast(this.child, this.animation, this.duration, this.fadeDuration,
      {Key? key})
      : super(key: key);

  final Widget child;
  final toastAnimation? animation;
  final Duration duration;
  final Duration fadeDuration;

  @override
  AnimationToastState createState() => AnimationToastState();
}

///_AnimationToast 위젯 상태 관리, 애니메이션 제어
class AnimationToastState extends State<_AnimationToast>
    with TickerProviderStateMixin {
  /// [animation] slide효과 애니메이션 제어
  late AnimationController _animationController;
  late Animation<Offset> topAnimation;
  late Animation<Offset> bottomAnimation;
  late Animation<Offset> nullAnimation;
  late Animation<Offset> rightAnimation;
  late Animation<Offset> leftAnimation;

  /// [fadeDuration] fade효과 애니메이션 제어
  late AnimationController _fadeController;
  late Animation _fadeAnimation;

  /// [fadeDuration] fade 애니메이션 시간 관리
  Timer? _timer;

  /// animation 동작 정의
  /// 리소스 할당
  @override
  void initState() {
    super.initState();

    /// [animation] 기본 설정 1초
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    // AnimationController(vsync: this, duration: const Duration(seconds: 1));

    /// 위에서 아래로
    topAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    /// 아래에서 위로
    bottomAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    /// 사용자가 애니메이션 설정 안했을때 기본 설정값. 애니메이션 없이 실행
    nullAnimation =
        Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    /// 오른쪽에서 왼쪽으로
    rightAnimation =
        Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    /// 왼쪽에서 오른쪽으로
    leftAnimation =
        Tween<Offset>(begin: const Offset(-1, 0), end: const Offset(0, 0))
            .animate(CurvedAnimation(
                parent: _animationController!, curve: Curves.easeInCubic));

    /// [fadeDuration] 사용자가 설정한 시간만큼 fade애니메이션 실행
    _fadeController =
        AnimationController(vsync: this, duration: widget.fadeDuration);

    /// 나타난 toast 스르륵 사라짐
    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_fadeController);

    /// [animation] 설정한 값으로 애니메이션 시작
    _animationController.forward();

    /// [fadeDuration] 사용자가 설정한 값이 있으면 toast보여주는 시간[duration]이 지난 후 [fadeDuration]실행 됨
    if (widget.fadeDuration != const Duration(seconds: 0)) {
      // 이전에 실행 중인 타이머가 있으면 취소
      // _timer?.cancel();

      /// [widget.duration] 사용자가 지정한 toast보여주는 시간
      _timer = Timer(widget.duration, () {
        print('widget.duration :' + (widget.duration).toString());
        _fadeController.forward();
      });
    }
  }

  /// [animation] 설정한 값으로 return
  /// --> return Animation<Offset>
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

  /// State객체가 제거되기 전 실행. 리소스 해제
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



