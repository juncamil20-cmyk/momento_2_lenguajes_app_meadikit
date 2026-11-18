import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/media_widgets.dart';
import '../../../data/models/media_project.dart';
import '../../../data/models/media_resource.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../services/local_file_store.dart';
import 'resource_form_screen.dart';

class ResourceDetailScreen extends StatefulWidget {
  const ResourceDetailScreen({
    super.key,
    required this.resourceId,
    required this.onSectionSelected,
  });
  final int resourceId;
  final ValueChanged<int> onSectionSelected;
  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  MediaResource? _resource;
  MediaProject? _project;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final resource = await MediaRepository.instance.resource(
        widget.resourceId,
      );
      final project = resource == null
          ? null
          : await MediaRepository.instance.project(resource.projectId);
      if (mounted) {
        setState(() {
          _resource = resource;
          _project = project;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit() async {
    final project = _project;
    final resource = _resource;
    if (project == null || resource == null) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ResourceFormScreen(
          project: project,
          resource: resource,
          onSectionSelected: widget.onSectionSelected,
        ),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _delete() async {
    final resource = _resource;
    if (resource == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar recurso'),
        content: Text(
          'Se eliminará “${resource.name}” y el archivo guardado dentro de MediaKit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await MediaRepository.instance.deleteResource(resource.id!);
      if (mounted) {
        Navigator.pop(context, true);
      }
      await LocalFileStore().delete(resource.localFilePath);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el recurso.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resource = _resource;
    final isImage =
        resource != null &&
        [
          'jpg',
          'jpeg',
          'png',
          'webp',
        ].contains(resource.fileExtension.toLowerCase());
    return Scaffold(
      appBar: MediaAppBar(
        title: 'DETALLE DEL RECURSO',
        onBack: () => Navigator.pop(context),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            )
          : resource == null
          ? const Center(child: Text('Este recurso ya no está disponible.'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'VOLVER A ${_project?.name.toUpperCase() ?? 'PROYECTO'}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                          letterSpacing: .8,
                        ),
                      ),
                    ),
                    Text(
                      'FICHA TÉCNICA · REC-${resource.id}',
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Container(
                  height: 235,
                  color: AppColors.surface,
                  child: isImage
                      ? MediaImage(
                          path: resource.localFilePath,
                          height: 235,
                          icon: Icons.broken_image_outlined,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _fileIcon(resource.fileExtension),
                              size: 62,
                              color: AppColors.orange,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              resource.fileExtension.toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.muted,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      color: AppColors.orange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      child: Text(
                        resource.category.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      'ID: REC-${resource.id}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                        letterSpacing: .7,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  resource.name.toUpperCase(),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 23),
                const SectionLabel('Especificaciones de archivo'),
                const SizedBox(height: 9),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.9,
                  children: [
                    _InfoTile(
                      label: 'PROYECTO ASOCIADO',
                      value: _project?.name ?? 'No disponible',
                      icon: Icons.folder_outlined,
                    ),
                    _InfoTile(
                      label: 'TIPO DE ARCHIVO',
                      value: resource.fileExtension.toUpperCase(),
                      icon: _fileIcon(resource.fileExtension),
                    ),
                    _InfoTile(
                      label: 'DIMENSIONES',
                      value: resource.imageWidth != null
                          ? '${resource.imageWidth} × ${resource.imageHeight} px'
                          : 'No aplica',
                      icon: Icons.photo_size_select_large_outlined,
                    ),
                    _InfoTile(
                      label: 'PESO DEL ARCHIVO',
                      value: formatBytes(resource.fileSize),
                      icon: Icons.storage_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                _InfoTile(
                  label: 'FECHA DE REGISTRO',
                  value: _date(resource.createdAt),
                  icon: Icons.schedule,
                ),
                if (resource.description.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const SectionLabel(
                    'Descripción editorial',
                    trailing: 'NOTAS',
                  ),
                  const SizedBox(height: 8),
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      resource.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
                const SizedBox(height: 25),
                ElevatedButton.icon(
                  onPressed: _edit,
                  icon: const Icon(Icons.edit_note),
                  label: const Text('EDITAR INFORMACIÓN'),
                ),
                const SizedBox(height: 9),
                OutlinedButton.icon(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('ELIMINAR RECURSO'),
                ),
              ],
            ),
      bottomNavigationBar: MediaBottomNavigation(
        currentIndex: 2,
        onTap: widget.onSectionSelected,
      ),
    );
  }

  IconData _fileIcon(String ext) => switch (ext.toLowerCase()) {
    'pdf' => Icons.picture_as_pdf_outlined,
    'mp4' => Icons.videocam_outlined,
    'mp3' || 'wav' => Icons.graphic_eq,
    'docx' || 'txt' => Icons.description_outlined,
    _ => Icons.insert_drive_file_outlined,
  };
  String _date(DateTime value) =>
      '${value.day} de ${_month(value.month)}, ${value.year} · ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  String _month(int month) => const [
    '',
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ][month];
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.surface,
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Icon(icon, size: 17, color: AppColors.muted),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 8,
                  color: AppColors.muted,
                  letterSpacing: .55,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
