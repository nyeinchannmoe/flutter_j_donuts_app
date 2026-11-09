import 'package:jdonuts/core/database/daos/app_meta_dao.dart';
import 'package:jdonuts/core/error/guard.dart';
import 'package:jdonuts/core/logging/app_logger.dart';
import 'package:jdonuts/core/result/result.dart';

/// Persists the user's language choice in app_meta.
class LocalePreferenceStore {
  const LocalePreferenceStore({
    required this._dao,
    required this._logger,
  });

  final AppMetaDao _dao;
  final AppLogger _logger;

  /// Language code, or null when the user never chose one.
  Future<Result<String?>> read() =>
      guardResult(() => _dao.readValue(AppMetaKeys.locale), logger: _logger);

  Future<Result<void>> write(String languageCode) => guardResult(
    () => _dao.writeValue(AppMetaKeys.locale, languageCode),
    logger: _logger,
  );
}
