import 'package:flutter/widgets.dart';

import 'di/app_di.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.di,
    required super.child,
  });

  final AppDi di;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) => di != oldWidget.di;
}

