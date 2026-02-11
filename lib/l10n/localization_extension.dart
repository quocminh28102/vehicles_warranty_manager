import 'package:flutter/widgets.dart';
import 'package:vehicles_warranty_manager/l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
