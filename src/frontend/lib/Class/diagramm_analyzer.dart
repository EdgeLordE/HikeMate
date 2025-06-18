/// Tool zur automatischen Erzeugung von UML-Klassendiagrammen aus Dart-Code
/// 
/// Dieses Programm analysiert alle .dart Dateien in einem Verzeichnis
/// und generiert ein PlantUML-Diagramm (.puml) mit allen gefundenen Klassen,
/// ihren Feldern, Methoden und Vererbungsbeziehungen.
/// 
/// Verwendung: dart run diagramm_analyzer.dart [verzeichnis_pfad]
/// Ausgabe: diagram.puml Datei im aktuellen Verzeichnis

import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

/// Hauptfunktion des Diagramm-Analyzers
/// 
/// [args] - Kommandozeilenargumente, erstes Argument ist der Quellcode-Pfad
/// Falls kein Pfad angegeben wird, wird das aktuelle Verzeichnis verwendet
void main(List<String> args) async {
  // Pfad zum Analysieren aus Argumenten lesen oder Standard verwenden
  final sourcePath = args.isNotEmpty ? args[0] : '.';

  // Überprüfung ob das Verzeichnis existiert
  final inputDir = Directory(sourcePath);
  if (!inputDir.existsSync()) {
    print('Fehler: Verzeichnis "$sourcePath" existiert nicht.');
    exit(1);
  }

  // PlantUML Ausgabe-Datei vorbereiten
  final outputFile = File('diagram.puml');
  final buffer = StringBuffer();
  buffer.writeln('@startuml');

  // Datenstrukturen für gefundene Klassen und ihre Beziehungen
  final classDefinitions = <String, ClassDeclaration>{};
  final relations = <String>[];

  // Alle .dart Dateien im Verzeichnis finden (rekursiv)
  final files = await inputDir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();

  // Jede Dart-Datei analysieren
  for (final file in files) {
    final content = await file.readAsString();
    final parseResult = parseString(content: content, throwIfDiagnostics: false);
    final unit = parseResult.unit;

    // Alle Klassendefinitionen in der Datei durchsuchen
    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        final className = declaration.name.lexeme;
        classDefinitions[className] = declaration;

        // Vererbungsbeziehung (extends) analysieren
        final extendsClause = declaration.extendsClause;
        if (extendsClause != null) {
          final superClass = extendsClause.superclass.name2.lexeme;
          relations.add('$className --|> $superClass');
        }

        // Interface-Implementierung (implements) analysieren
        final implementsClause = declaration.implementsClause;        if (implementsClause != null) {
          for (final interfaceType in implementsClause.interfaces) {
            final interfaceName = interfaceType.name2.lexeme;
            relations.add('$className ..|> $interfaceName');
          }
        }
      }
    }
  }

  // PlantUML-Code für alle gefundenen Klassen generieren
  for (final entry in classDefinitions.entries) {
    final className = entry.key;
    final classNode = entry.value;

    buffer.writeln('class $className {');

    // Alle Felder (Variablen) der Klasse hinzufügen
    for (final member in classNode.members) {
      if (member is FieldDeclaration) {
        final fieldType = member.fields.type?.toSource() ?? 'var';
        for (final variable in member.fields.variables) {
          final name = variable.name.lexeme; 
          // Private Felder (mit _) bekommen - Symbol, public bekommen +
          final visibility = name.startsWith('_') ? '-' : '+';
          buffer.writeln('  $visibility $fieldType $name');
        }
      } 
      // Alle Methoden der Klasse hinzufügen
      else if (member is MethodDeclaration) {
        final name = member.name.lexeme; 
        // Private Methoden (mit _) bekommen - Symbol, public bekommen +
        final visibility = name.startsWith('_') ? '-' : '+';
        final returnType = member.returnType?.toSource() ?? 'void';
        buffer.writeln('  $visibility $returnType $name()');
      }
    }

    buffer.writeln('}');
  }

  // Alle Vererbungsbeziehungen zum Diagramm hinzufügen
  for (final rel in relations) {
    buffer.writeln(rel);
  }

  buffer.writeln('@enduml');

  // PlantUML-Datei schreiben
  await outputFile.writeAsString(buffer.toString());

  print('UML Diagramm als diagram.puml erzeugt.');
}