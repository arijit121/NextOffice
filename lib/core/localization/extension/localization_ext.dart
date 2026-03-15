import 'package:flutter/material.dart';

import 'package:nextoffice/core/localization/app_localizations/app_localizations.dart';
import 'package:nextoffice/core/localization/app_localizations/app_localizations_en.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n =>
      AppLocalizations.of(this) ?? AppLocalizationsEn();
}
