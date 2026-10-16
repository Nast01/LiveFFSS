import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:live_ffss_v2/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Les formats de date des extensions de présentation (`DateFormat('d MMMM
  // y', locale)`) lèvent tant que les données de la langue ne sont pas
  // chargées.
  await initializeDateFormatting();
  runApp(const ProviderScope(child: LiveFfssApp()));
}
