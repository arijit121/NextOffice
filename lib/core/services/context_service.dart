import 'package:flutter/material.dart';

import 'package:nextoffice/navigation/router_manager.dart';

class CurrentContext {
  BuildContext context = RouterManager
      .getInstance.router.routerDelegate.navigatorKey.currentContext!;
}
