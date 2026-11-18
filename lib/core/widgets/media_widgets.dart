import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});
  final String text;
  final String? trailing;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.15,
            fontWeight: FontWeight.w700,
            color: AppColors.tertiary,
          ),
        ),
      ),
      if (trailing != null)
        Text(
          trailing!,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.muted,
            letterSpacing: .6,
          ),
        ),
    ],
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.kicker,
    required this.title,
    this.description,
  });
  final String kicker;
  final String title;
  final String? description;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            kicker.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
      const SizedBox(height: 7),
      Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      if (description != null) ...[
        const SizedBox(height: 7),
        Text(
          description!,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: AppColors.tertiary),
        ),
      ],
    ],
  );
}

class MediaImage extends StatelessWidget {
  const MediaImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.icon = Icons.insert_drive_file_outlined,
  });
  final String path;
  final double? width;
  final double? height;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final file = File(path);
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Image.file(
            file,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _placeholder(),
          );
        }
        return _placeholder();
      },
    );
  }

  Widget _placeholder() => Container(
    width: width,
    height: height,
    color: AppColors.surfaceRaised,
    alignment: Alignment.center,
    child: Icon(icon, color: AppColors.muted, size: 28),
  );
}

String formatBytes(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String categoryForExtension(String ext) {
  final value = ext.toLowerCase();
  if (['jpg', 'jpeg', 'png', 'webp'].contains(value)) {
    return 'Fotografías e imágenes';
  }
  if (['mp4'].contains(value)) return 'Videos';
  if (['mp3', 'wav'].contains(value)) return 'Audios';
  if (['pdf', 'docx', 'txt'].contains(value)) return 'Documentos';
  return 'Otros';
}

const mediaCategories = [
  'Todos',
  'Fotografías e imágenes',
  'Documentos',
  'Gráficos',
  'Videos',
  'Audios',
  'Otros',
];

String? categoryFilter(String value) => value == 'Todos' ? null : value;

class MediaBottomNavigation extends StatelessWidget {
  const MediaBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onTap,
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.orange.withValues(alpha: .16),
    height: 66,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.folder_open_outlined),
        selectedIcon: Icon(Icons.folder_open),
        label: 'BIBLIOTECA',
      ),
      NavigationDestination(
        icon: Icon(Icons.work_outline),
        selectedIcon: Icon(Icons.work),
        label: 'PROYECTOS',
      ),
      NavigationDestination(
        icon: Icon(Icons.layers_outlined),
        selectedIcon: Icon(Icons.layers),
        label: 'RECURSOS',
      ),
    ],
  );
}

class MediaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MediaAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = true,
    this.actions = const [],
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBack;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    automaticallyImplyLeading: false,
    leading: showBack
        ? IconButton(
            onPressed: onBack ?? () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back),
          )
        : null,
    title: Row(
      children: [
        Image.asset(
          'assets/logo_camilus.png.png',
          width: 34,
          height: 38,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              letterSpacing: .65,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
    actions: [
      ...actions,
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Image.asset(
          'assets/logo_mediakit.png.png',
          width: 34,
          height: 34,
          fit: BoxFit.contain,
        ),
      ),
    ],
  );
}
