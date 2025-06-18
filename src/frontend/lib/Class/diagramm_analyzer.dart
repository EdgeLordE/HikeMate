import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

void main(List<String> args) async {
  // Ordner mit Dart-Quellcode, Standard ist aktueller Ordner
  final sourcePath = args.isNotEmpty ? args[0] : '.';

  final inputDir = Directory(sourcePath);
  if (!inputDir.existsSync()) {
    print('Fehler: Verzeichnis "$sourcePath" existiert nicht.');
    exit(1);
  }

  final outputFile = File('diagram.puml');
  final buffer = StringBuffer();
  buffer.writeln('@startuml');

  final classDefinitions = <String, ClassDeclaration>{};
  final relations = <String>[];

  // Alle Dart-Dateien rekursiv finden
  final files = await inputDir
      .list(recursive: true)
      .where((entity) => entity is File && entity.path.endsWith('.dart'))
      .cast<File>()
      .toList();

  for (final file in files) {
    final content = await file.readAsString();
    final parseResult = parseString(content: content, throwIfDiagnostics: false);
    final unit = parseResult.unit;

    for (final declaration in unit.declarations) {
      if (declaration is ClassDeclaration) {
        final className = declaration.name.lexeme;
        classDefinitions[className] = declaration;

        // Vererbung (extends)
        final extendsClause = declaration.extendsClause;
        if (extendsClause != null) {
          final superClass = extendsClause.superclass.name2.lexeme;
          relations.add('$className --|> $superClass');
        }

        // Implementierte Interfaces (implements)
        final implementsClause = declaration.implementsClause;
        if (implementsClause != null) {
          for (final interfaceType in implementsClause.interfaces) {
            final interfaceName = interfaceType.name2.lexeme;
            relations.add('$className ..|> $interfaceName');
          }
        }
      }
    }
  }

  // Klassen mit Feldern und Methoden ausgeben
  for (final entry in classDefinitions.entries) {
    final className = entry.key;
    final classNode = entry.value;

    buffer.writeln('class $className {');

    for (final member in classNode.members) {
      if (member is FieldDeclaration) {
        final fieldType = member.fields.type?.toSource() ?? 'var';
        for (final variable in member.fields.variables) {
          final name = variable.name.lexeme; // Korrektur: .name.lexeme statt .name.name
          final visibility = name.startsWith('_') ? '-' : '+';
          buffer.writeln('  $visibility $fieldType $name');
        }
      } else if (member is MethodDeclaration) {
        final name = member.name.lexeme; // Korrektur: .name.lexeme statt .name.name
        final visibility = name.startsWith('_') ? '-' : '+';
        final returnType = member.returnType?.toSource() ?? 'void';
        buffer.writeln('  $visibility $returnType $name()');
      }
    }

    buffer.writeln('}');
  }

  // Beziehungen hinzufügen
  for (final rel in relations) {
    buffer.writeln(rel);
  }

  buffer.writeln('@enduml');

  // Datei schreiben
  await outputFile.writeAsString(buffer.toString());

  print('✅ UML Diagramm als diagram.puml erzeugt.');
}