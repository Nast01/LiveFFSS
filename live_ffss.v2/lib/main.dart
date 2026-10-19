import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:live_ffss_v2/app.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Les formats de date des extensions de présentation (`DateFormat('d MMMM
  // y', locale)`) lèvent tant que les données de la langue ne sont pas
  // chargées.
  await initializeDateFormatting();
  final environment = await readLaunchEnvironment(
    GlobalStore.secure(const FlutterSecureStorage()),
  );
  runApp(AppRoot(environment: environment));
}
