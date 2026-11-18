import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/media_widgets.dart';
import '../../../data/models/media_project.dart';
import '../../../data/models/media_resource.dart';
import '../../../data/repositories/media_repository.dart';
import '../../projects/screens/project_detail_screen.dart';
import '../../projects/screens/project_form_screen.dart';
import '../../resources/screens/resource_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({
    super.key,
    this.section = 0,
    required this.onSectionSelected,
  });
  final int section;
  final ValueChanged<int> onSectionSelected;
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  List<MediaProject> _projects = [];
  List<MediaResource> _resources = [];
  bool _loading = true;
  String _search = '';
  String _category = 'Todos';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final values = await Future.wait([
        MediaRepository.instance.projects(),
        MediaRepository.instance.resources(),
      ]);
      if (mounted) {
        setState(() {
          _projects = values[0] as List<MediaProject>;
          _resources = values[1] as List<MediaResource>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<MediaProject> get _filteredProjects => _projects
      .where(
        (item) => '${item.name} ${item.description} ${item.projectType}'
            .toLowerCase()
            .contains(_search.toLowerCase()),
      )
      .toList();
  List<MediaResource> get _filteredResources => _resources.where((item) {
    final matchesSearch =
        '${item.name} ${item.originalFileName} ${item.category}'
            .toLowerCase()
            .contains(_search.toLowerCase());
    final matchesCategory = _category == 'Todos' || item.category == _category;
    return matchesSearch && matchesCategory;
  }).toList();
  int get _visibleResourceCount => _resources.length;

  Future<void> _createProject() async {
    final id = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProjectFormScreen(onSectionSelected: widget.onSectionSelected),
      ),
    );
    if (id != null && mounted) {
      await _load();
      if (!mounted) return;
      await _openProject(id);
    } else {
      _load();
    }
  }

  Future<void> _openProject(int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailScreen(
          projectId: id,
          onSectionSelected: widget.onSectionSelected,
        ),
      ),
    );
    _load();
  }

  Future<void> _openResource(int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResourceDetailScreen(
          resourceId: id,
          onSectionSelected: widget.onSectionSelected,
        ),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) => _loading
      ? const Center(child: CircularProgressIndicator(color: AppColors.orange))
      : RefreshIndicator(
          onRefresh: _load,
          color: AppColors.orange,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              _BrandHeader(section: widget.section),
              if (widget.section == 0) ...[
                const SizedBox(height: 21),
                const PageHeading(
                  kicker: 'Módulo: archivo general · V1.0',
                  title: 'Mi biblioteca',
                  description: 'Organiza, clasifica y gestiona tus recursos visuales y editoriales de proyectos Crossmedia.',
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'PROYECTOS ACTIVOS',
                        value: _projects.length.toString().padLeft(2, '0'),
                        caption: 'En esta biblioteca',
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _StatCard(
                        title: 'TOTAL RECURSOS',
                        value: _visibleResourceCount.toString().padLeft(2, '0'),
                        caption: 'Archivos registrados',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
              ] else ...[
                const SizedBox(height: 19),
                PageHeading(
                  kicker: widget.section == 1
                      ? 'Archivo general · proyectos'
                      : 'Archivo general · recursos',
                  title: widget.section == 1 ? 'Proyectos' : 'Recursos',
                  description: widget.section == 1
                      ? 'Consulta y administra tus proyectos creativos.'
                      : 'Consulta los archivos registrados en tu biblioteca.',
                ),
                const SizedBox(height: 18),
              ],
              TextField(
                onChanged: (value) => setState(() => _search = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 19),
                  hintText: 'Buscar proyectos o recursos...',
                ),
              ),
              if (widget.section != 1) ...[
                const SizedBox(height: 11),
                SizedBox(
                  height: 35,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mediaCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final category = mediaCategories[index];
                      final active = category == _category;
                      return ChoiceChip(
                        label: Text(
                          category == 'Fotografías e imágenes'
                              ? 'FOTOGRAFÍAS'
                              : category.toUpperCase(),
                        ),
                        selected: active,
                        onSelected: (_) => setState(() => _category = category),
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
              ],
              if (widget.section != 2) ...[
                const SizedBox(height: 13),
                ElevatedButton.icon(
                  onPressed: _createProject,
                  icon: const Icon(Icons.add),
                  label: const Text('CREAR PROYECTO'),
                ),
                const SizedBox(height: 22),
                SectionLabel(
                  widget.section == 1
                      ? 'Proyectos registrados'
                      : 'Proyectos recientes',
                  trailing:
                      '${_filteredProjects.length.toString().padLeft(2, '0')} PROYECTOS',
                ),
                const SizedBox(height: 10),
                if (_filteredProjects.isEmpty)
                  _EmptyState(
                    text: _projects.isEmpty
                        ? 'Aún no tienes proyectos. Crea uno para comenzar a organizar tus recursos.'
                        : 'No hay proyectos que coincidan con la búsqueda.',
                  ),
                ..._filteredProjects.map(
                  (project) => _ProjectCard(
                    project: project,
                    resourceCount: _resources
                        .where((item) => item.projectId == project.id)
                        .length,
                    onTap: () => _openProject(project.id!),
                  ),
                ),
              ],
              if (widget.section != 1) ...[
                const SizedBox(height: 22),
                SectionLabel(
                  widget.section == 2
                      ? 'Todos los recursos'
                      : 'Recursos registrados',
                  trailing:
                      '${_filteredResources.length.toString().padLeft(2, '0')} ARCHIVOS',
                ),
                const SizedBox(height: 8),
                if (_filteredResources.isEmpty)
                  _EmptyState(
                    text: _resources.isEmpty
                        ? 'Los recursos que agregues desde un proyecto aparecerán aquí.'
                        : 'No hay recursos que coincidan con la búsqueda.',
                  ),
                ..._filteredResources.map(
                  (resource) => _ResourceCard(
                    resource: resource,
                    projectName:
                        _projects
                            .where((item) => item.id == resource.projectId)
                            .firstOrNull
                            ?.name ??
                        'Proyecto eliminado',
                    onTap: () => _openResource(resource.id!),
                  ),
                ),
              ],
            ],
          ),
        );
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.section});
  final int section;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(bottom: 12),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        Image.asset(
          'assets/logo_camilus.png.png',
          width: 36,
          height: 38,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 6),
        Text(
          'MEDIAKIT',
          style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontSize: 30),
        ),
        const SizedBox(width: 9),
        const Icon(Icons.bolt, color: AppColors.orange, size: 23),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              ['INICIO / MI BIBLIOTECA', 'PROYECTOS', 'RECURSOS'][section],
              style: const TextStyle(
                color: AppColors.orange,
                fontSize: 9,
                letterSpacing: .8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Text(
              '[V1.0 · CROSSMEDIA]',
              style: TextStyle(
                fontSize: 8,
                color: AppColors.muted,
                letterSpacing: .8,
              ),
            ),
          ],
        ),
        const SizedBox(width: 9),
        Image.asset(
          'assets/logo_mediakit.png.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
      ],
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.caption,
  });
  final String title;
  final String value;
  final String caption;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    color: AppColors.surface,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 8,
            color: AppColors.muted,
            letterSpacing: .65,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                title.startsWith('PROY') ? 'PROYECTOS' : 'ARCHIVOS',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Text(
          caption,
          style: const TextStyle(fontSize: 9, color: AppColors.muted),
        ),
      ],
    ),
  );
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.project,
    required this.resourceCount,
    required this.onTap,
  });
  final MediaProject project;
  final int resourceCount;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    color: AppColors.surface,
    margin: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Row(
          children: [
            if (project.coverImagePath != null)
              MediaImage(
                path: project.coverImagePath!,
                width: 63,
                height: 63,
                icon: Icons.image_outlined,
              )
            else
              Container(
                width: 63,
                height: 63,
                color: AppColors.surfaceRaised,
                child: const Icon(
                  Icons.folder_open_outlined,
                  color: AppColors.orange,
                ),
              ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$resourceCount recursos · ${project.projectType}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, size: 17, color: AppColors.muted),
          ],
        ),
      ),
    ),
  );
}

class _ResourceCard extends StatelessWidget {
  const _ResourceCard({
    required this.resource,
    required this.projectName,
    required this.onTap,
  });
  final MediaResource resource;
  final String projectName;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final image = [
      'jpg',
      'jpeg',
      'png',
      'webp',
    ].contains(resource.fileExtension.toLowerCase());
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 7),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        leading: image
            ? MediaImage(path: resource.localFilePath, width: 46, height: 46)
            : Container(
                width: 46,
                height: 46,
                color: AppColors.surfaceRaised,
                child: Icon(
                  Icons.insert_drive_file_outlined,
                  color: AppColors.orange,
                  size: 21,
                ),
              ),
        title: Text(
          resource.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${projectName.toUpperCase()} · ${resource.category} · ${formatBytes(resource.fileSize)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 9, color: AppColors.muted),
        ),
        trailing: const Icon(
          Icons.arrow_forward,
          size: 17,
          color: AppColors.muted,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    margin: const EdgeInsets.only(bottom: 9),
    color: AppColors.surface,
    child: Text(
      text,
      style: const TextStyle(color: AppColors.muted, fontSize: 12),
      textAlign: TextAlign.center,
    ),
  );
}
