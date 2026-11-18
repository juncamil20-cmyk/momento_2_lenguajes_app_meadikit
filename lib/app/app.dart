import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/media_widgets.dart';
import '../features/library/screens/library_screen.dart';

class MediaKitApp extends StatelessWidget {
  const MediaKitApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MediaKit · Biblioteca de recursos creativos',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark,
    home: const MediaKitShell(),
  );
}

class MediaKitShell extends StatefulWidget {
  const MediaKitShell({super.key});
  @override
  State<MediaKitShell> createState() => _MediaKitShellState();
}

class _MediaKitShellState extends State<MediaKitShell> {
  int _section = 0;

  void _selectSection(int section) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (mounted) setState(() => _section = section);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LibraryScreen(
        key: ValueKey(_section),
        section: _section,
        onSectionSelected: _selectSection,
      ),
    ),
    bottomNavigationBar: MediaBottomNavigation(
      currentIndex: _section,
      onTap: _selectSection,
    ),
  );
}
