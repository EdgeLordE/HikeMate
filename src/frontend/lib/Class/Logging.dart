import 'dart:io';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

/// Service für zentrales Logging in der HikeMate App
/// 
/// Diese Klasse implementiert ein Singleton-Pattern und stellt
/// einheitliche Logging-Funktionen für die gesamte App bereit.
/// 
/// Features:
/// - Verschiedene Log-Level (Debug, Info, Warning, Error)
/// - Ausgabe in Konsole und Log-Datei
/// - Automatische Zeitstempel
/// - Singleton-Pattern für einheitliche Nutzung
class LoggingService {
  /// Singleton-Instanz des LoggingService
  static final LoggingService _instance = LoggingService._internal();
  
  /// Factory Constructor für Singleton-Pattern
  factory LoggingService() => _instance;

  /// Dart Logger-Instanz für die eigentliche Log-Funktionalität
  late final Logger _logger;
  
  /// File-Stream zum Schreiben in die Log-Datei
  IOSink? _sink;

  /// Privater Constructor für Singleton-Pattern
  /// 
  /// Initialisiert den Logger und konfiguriert die Log-Ausgabe
  /// sowohl für Konsole als auch für Datei-Logging.
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

  /// Initialisiert das Datei-Logging
  /// 
  /// Erstellt eine Log-Datei im App-Dokumenten-Verzeichnis
  /// und öffnet einen Stream zum Schreiben der Log-Nachrichten.
  /// Diese Methode sollte beim App-Start aufgerufen werden.
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/app.log');
    _sink = file.openWrite(mode: FileMode.append);
  }

  /// Debug-Nachricht loggen (für Entwicklung)
  /// [message] - Die Debug-Nachricht
  void d(String message) => _logger.fine(message);
  
  /// Info-Nachricht loggen (allgemeine Informationen)
  /// [message] - Die Info-Nachricht
  void i(String message) => _logger.info(message);
  
  /// Warning-Nachricht loggen (Warnungen)
  /// [message] - Die Warning-Nachricht
  void w(String message) => _logger.warning(message);
  
  /// Error-Nachricht loggen (Fehler)
  /// [message] - Die Error-Nachricht
  /// [error] - Optional: Das Error-Objekt
  /// [stackTrace] - Optional: Der Stack-Trace
  void e(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.severe(message, error, stackTrace);
}
