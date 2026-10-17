import 'dart:convert';
import 'dart:io';

/// Lit un extrait réel de la recette 1416 ; le chemin est relatif au dossier du
/// projet, d'où `flutter test` est lancé.
Map<String, dynamic> fixture(String name) {
  final text = File('test/fixtures/recette_1416/$name.json').readAsStringSync();
  final decoded = jsonDecode(text);
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('La fixture $name n\'est pas un objet JSON.');
  }
  return decoded;
}
