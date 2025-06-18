import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;

  late final Logger _logger;
  IOSink? _sink;

  LoggingService._internal() {
    _logger = Logger('AppLogger');
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      final msg = '[${record.level.name}][${record.time.toIso8601String()}]'
          ' ${record.loggerName}: ${record.message}';
      print(msg);
      _sink?.writeln(msg);
    });
  }

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/app.log');
    _sink = file.openWrite(mode: FileMode.append);
  }

  void d(String message) => _logger.fine(message);
  void i(String message) => _logger.info(message);
  void w(String message) => _logger.warning(message);
  void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.severe(message, error, stackTrace);
}
