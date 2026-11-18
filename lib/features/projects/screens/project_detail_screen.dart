import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/media_widgets.dart';
import '../../../data/models/media_project.dart';
import '../../../data/models/media_resource.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../services/local_file_store.dart';
import '../../resources/screens/resource_detail_screen.dart';
import '../../resources/screens/resource_form_screen.dart';
import 'project_form_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.onSectionSelected,
  });
  final int projectId;
  final ValueChanged<int> onSectionSelected;
  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  MediaProject? _project;
  List<MediaResource> _resources = [];
  bool _loading = true;
  String _query = '';
  String _filter = 'Todos';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final project = await MediaRepository.instance.project(widget.projectId);
      final resources = await MediaRepository.instance.resources(
        projectId: widget.projectId,
      );
      if (mounted) {
        setState(() {
          _project = project;
          _resources = resources;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<MediaResource> get _visible => _resources.where((item) {
    final matchesSearch =
        '${item.name} ${item.originalFileName} ${item.category}'
            .toLowerCase()
            .contains(_query.toLowerCase());
    final matchesFilter = _filter == 'Todos' || item.category == _filter;
    return matchesSearch && matchesFilter;
  }).toList();

  Future<void> _addResource() async {
    final project = _project;
    if (project == null) return;
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ResourceFormScreen(
          project: project,
          onSectionSelected: widget.onSectionSelected,
        ),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _openResource(MediaResource resource) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResourceDetailScreen(
          resourceId: resource.id!,
          onSectionSelected: widget.onSectionSelected,
        ),
      ),
    );
    _load();
  }

  Future<void> _editProject() async {
    final project = _project;
    if (project == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectFormScreen(
          project: project,
          onSectionSelected: widget.onSectionSelected,
        ),
      ),
    );
    _load();
  }

  Future<void> _deleteProject() async {
    final project = _project;
    if (project == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar proyecto'),
        content: Text(
          'Se eliminará “${project.name}” y sus recursos asociados del catálogo. Esta acción no se puede deshacer.',
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
      final files = LocalFileStore();
      await MediaRepository.instance.deleteProject(project.id!);
      if (mounted) {
        Navigator.pop(context, true);
      }
      for (final resource in _resources) {
        await files.delete(resource.localFilePath);
      }
      if (project.coverImagePath != null) {
        await files.delete(project.coverImagePath!);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar el proyecto.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = _project;
    final totalBytes = _resources.fold<int>(
      0,
      (sum, item) => sum + item.fileSize,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'DETALLE DEL PROYECTO',
          style: TextStyle(
            fontSize: 14,
            letterSpacing: .7,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) =>
                value == 'edit' ? _editProject() : _deleteProject(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar proyecto')),
              PopupMenuItem(value: 'delete', child: Text('Eliminar proyecto')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            )
          : project == null
          ? const Center(child: Text('No se encontró este proyecto.'))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.orange,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: PageHeading(
                                  kicker: project.projectType,
                                  title: project.name,
                                ),
                              ),
                              Container(
                                color: AppColors.orange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 7,
                                ),
                                child: Text(
                                  '${_resources.length} RECURSOS',
                                  style: const TextStyle(
                                    color: AppColors.background,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (project.description.isNotEmpty) ...[
                            const SizedBox(height: 9),
                            Text(
                              project.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Icon(
                                Icons.folder_open_outlined,
                                color: AppColors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'VOLUMEN TOTAL: ${formatBytes(totalBytes)}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  letterSpacing: .8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'ACTUALIZADO ${_date(project.updatedAt)}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          TextField(
                            onChanged: (value) =>
                                setState(() => _query = value),
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search, size: 19),
                              hintText: 'Buscar en este proyecto...',
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 36,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: mediaCategories.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 6),
                              itemBuilder: (context, index) {
                                final category = mediaCategories[index];
                                final active = category == _filter;
                                return ChoiceChip(
                                  label: Text(
                                    category == 'Fotografías e imágenes'
                                        ? 'FOTOGRAFÍAS'
                                        : category.toUpperCase(),
                                  ),
                                  selected: active,
                                  onSelected: (_) =>
                                      setState(() => _filter = category),
                                  selectedColor: AppColors.orange,
                                  backgroundColor: AppColors.surface,
                                  labelStyle: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: active
                                        ? AppColors.background
                                        : AppColors.cream,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                    side: BorderSide(color: AppColors.border),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 11),
                          ElevatedButton.icon(
                            onPressed: _addResource,
                            icon: const Icon(Icons.add),
                            label: const Text('AGREGAR RECURSO'),
                          ),
                          const SizedBox(height: 17),
                          const SectionLabel(
                            'Archivos registrados',
                            trailing: 'FORMATO / PESO',
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  if (_visible.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                color: AppColors.muted,
                                size: 38,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _resources.isEmpty
                                    ? 'Este proyecto todavía no tiene recursos.'
                                    : 'No hay recursos que coincidan con la búsqueda.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.muted),
                              ),
                              if (_resources.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: TextButton(
                                    onPressed: _addResource,
                                    child: const Text(
                                      'AGREGAR EL PRIMER RECURSO',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: _visible.length,
                      itemBuilder: (context, index) => _ResourceRow(
                        resource: _visible[index],
                        onTap: () => _openResource(_visible[index]),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 26)),
                ],
              ),
            ),
      bottomNavigationBar: MediaBottomNavigation(
        currentIndex: 1,
        onTap: widget.onSectionSelected,
      ),
    );
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({required this.resource, required this.onTap});
  final MediaResource resource;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final image = [
      'jpg',
      'jpeg',
      'png',
      'webp',
    ].contains(resource.fileExtension.toLowerCase());
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            if (image)
              MediaImage(path: resource.localFilePath, width: 54, height: 54)
            else
              Container(
                width: 54,
                height: 54,
                color: AppColors.surface,
                child: Center(
                  child: Text(
                    resource.fileExtension.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REC-${resource.id?.toString().padLeft(3, '0')}  ·  ${resource.category.toUpperCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.orange,
                      fontSize: 9,
                      letterSpacing: .4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${formatBytes(resource.fileSize)} · ${resource.fileExtension.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: AppColors.muted, size: 19),
          ],
        ),
      ),
    );
  }
}
