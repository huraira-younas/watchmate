import 'package:flutter/widgets.dart' show PageController;
import 'package:flutter/foundation.dart' show immutable;
import 'package:watchmate_app/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  final controller = PageController();
  int currentIndex = 0;

  void navigateTo(int event) {
    if (currentIndex == event) return;

    Logger.info(tag: "Navigate", message: "To: $event");
    controller.jumpToPage(event);
    currentIndex = event;
    _emit();
  }

  void _emit({String? route, dynamic data}) {
    emit(NavigationState(idx: currentIndex, route: route, data: data));
  }

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}

@immutable
class NavigationState {
  final String? route;
  final dynamic data;
  final int idx;

  const NavigationState({this.idx = 0, this.route, this.data});
}
