import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllCompetitionsPage extends ConsumerStatefulWidget {
  const AllCompetitionsPage({super.key});

  @override
  ConsumerState<AllCompetitionsPage> createState() =>
      _AllCompetitionsPageState();
}

class _AllCompetitionsPageState extends ConsumerState<AllCompetitionsPage> {
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Compétitions')));
}
