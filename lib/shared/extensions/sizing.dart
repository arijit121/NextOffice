import 'package:flutter/widgets.dart';

import 'package:nextoffice/core/services/context_service.dart';
import 'package:nextoffice/shared/utils/screen_utils.dart';

extension Sizing on num {
  double get fs =>
      MediaQuery.of(CurrentContext().context).textScaler.scale(toDouble());

  double get sh => ScreenUtils.nh() * (toDouble() / 100);

  double get sw => ScreenUtils.nw() * (toDouble() / 100);
}
