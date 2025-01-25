import 'package:mason_logger/mason_logger.dart';

class MyLogger {
  static final Logger _logger = Logger(
    level: Level.info,
  );
  static Logger get logger => _logger;

  static void logError(String message) => _logger.err(message);

  static void logInfo(String message) => _logger.info(message);

  static void logSuccess(String message) => _logger.success(message);

  static void logAlert(String message) => logger.alert(black.wrap(
        backgroundMagenta.wrap(
          styleItalic.wrap(" $message"),
        ),
      ));

  static void logWarn(String message) => logger.info(yellow.wrap(message));

  static Progress logProgress(String message) => _logger.progress(
        message,
        options: ProgressOptions(
          animation: ProgressAnimation(
            frames: [' 🇵🇸 '],
          ),
        ),
      );
}
