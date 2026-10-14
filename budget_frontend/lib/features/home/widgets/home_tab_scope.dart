import 'package:flutter/widgets.dart';

class HomeTabScope extends InheritedWidget {
  const HomeTabScope({
    super.key,
    required this.onSelectTab,
    required super.child,
  });

  final ValueChanged<int> onSelectTab;

  static HomeTabScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeTabScope>();
  }

  static void selectTab(BuildContext context, int index) {
    final scope = context.findAncestorWidgetOfExactType<HomeTabScope>();
    scope?.onSelectTab(index);
  }

  @override
  bool updateShouldNotify(HomeTabScope oldWidget) =>
      onSelectTab != oldWidget.onSelectTab;
}
