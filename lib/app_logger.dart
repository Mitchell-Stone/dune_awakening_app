import 'dart:io';

class Logger {
  static File? _logFile;

  /// Initialize log file — run this early in your app startup
  static Future<void> init() async {
    final logPath = './app.log';
    _logFile = File(logPath);

    if (!await _logFile!.exists()) {
      await _logFile!.create(recursive: true);
    }

    info('--- App Started ---');
  }

  /// Write a line to the log file
  static Future<void> info(String message) async {
    final now = DateTime.now();
    final logEntry = '[${now.toIso8601String()}] INFO: $message\n';

    // Also print to console (optional)
    print(logEntry);

    if (_logFile != null) {
      await _logFile!.writeAsString(logEntry, mode: FileMode.append);
    }
  }

  static Future<void> error(String message, [StackTrace? stackTrace]) async {
    final now = DateTime.now();
    final logEntry = '[${now.toIso8601String()}] ERROR: $message\n';

    // Also print to console (optional)
    print(logEntry);
    if (stackTrace != null) {
      print(stackTrace);
    }

    if (_logFile != null) {
      await _logFile!.writeAsString(logEntry, mode: FileMode.append);
      if (stackTrace != null) {
        await _logFile!.writeAsString('$stackTrace\n', mode: FileMode.append);
      }
    }
  }

  static Future<void> warn(String message) async {
    final now = DateTime.now();
    final logEntry = '[${now.toIso8601String()}] WARNING: $message\n';

    // Also print to console (optional)
    print(logEntry);

    if (_logFile != null) {
      await _logFile!.writeAsString(logEntry, mode: FileMode.append);
    }
  }

  /// Clear the log (optional utility)
  static Future<void> clear() async {
    if (_logFile != null && await _logFile!.exists()) {
      await _logFile!.writeAsString('');
    }
  }

  /// Get path to the log file (e.g. for UI buttons)
  static String get path => _logFile?.path ?? 'Not initialized';
}
