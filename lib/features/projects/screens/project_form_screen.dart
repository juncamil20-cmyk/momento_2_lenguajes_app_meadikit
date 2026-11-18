import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/media_widgets.dart';
import '../../../data/models/media_project.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../services/local_file_store.dart';

const projectTypes = [
  'Diseño Crossmedia',
  'Identidad visual',
  'Producción audiovisual',
  'Fotografía',
  'Diseño editorial',
  'Campaña digital',
  'Otro',
];

class ProjectFormScreen extends StatefulWidget {
  const ProjectFormScreen({
    super.key,
    this.project,
    required this.onSectionSelected,
  });
  final MediaProject? project;
  final ValueChanged<int> onSectionSelected;
  @override
  State<ProjectFormScreen> createState() => _ProjectFormScreenState();
}

class _ProjectFormScreenState extends State<ProjectFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late String _type;
  String? _cover;
  PlatformFile? _newCover;
  bool _saving = false;
  final _files = LocalFileStore();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.project?.name ?? '');
    _description = TextEditingController(
      text: widget.project?.description ?? '',
    );
    _type = widget.project?.projectType ?? projectTypes.first;
    _cover = widget.project?.coverImagePath;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _selectCover() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: false,
      );
      if (result == null || !mounted) return;
      final image = result.files.single;
      if (image.size > 15 * 1024 * 1024) {
        _message('La portada no puede superar 15 MB.');
        return;
      }
      setState(() => _newCover = image);
    } catch (_) {
      if (mounted) _message('No fue posible abrir el selector de imágenes.');
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    String? copiedCover;
    try {
      final now = DateTime.now();
      var coverPath = _cover;
      if (_newCover != null) {
        coverPath = copiedCover = await _files.copyIntoApp(
          _newCover!,
          folder: 'covers',
        );
      }
      final item = MediaProject(
        id: widget.project?.id,
        name: _name.text.trim(),
        description: _description.text.trim(),
        projectType: _type,
        coverImagePath: coverPath,
        createdAt: widget.project?.createdAt ?? now,
        updatedAt: now,
      );
      late final int id;
      if (widget.project == null) {
        id = await MediaRepository.instance.saveProject(item);
      } else {
        await MediaRepository.instance.updateProject(item);
        id = widget.project!.id!;
      }
      if (copiedCover != null && widget.project?.coverImagePath != null) {
        try {
          await _files.delete(widget.project!.coverImagePath!);
        } catch (_) {
          /* El registro conserva la nueva portada. */
        }
      }
      if (mounted) Navigator.pop(context, id);
    } catch (_) {
      if (copiedCover != null) await _files.delete(copiedCover);
      if (mounted) {
        setState(() => _saving = false);
        _message('No se pudo guardar el proyecto. Intenta nuevamente.');
      }
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back),
      ),
      title: Text(
        widget.project == null ? 'CREAR PROYECTO' : 'EDITAR PROYECTO',
        style: const TextStyle(
          fontSize: 14,
          letterSpacing: .7,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    body: SafeArea(
      child: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            PageHeading(
              kicker: widget.project == null
                  ? 'Nuevo registro / proyecto'
                  : 'Actualizar registro / proyecto',
              title: widget.project == null
                  ? 'Nuevo proyecto'
                  : 'Editar proyecto',
              description: 'Define los parámetros básicos para organizar tus archivos y activos visuales.',
            ),
            const SizedBox(height: 25),
            const SectionLabel('Nombre del proyecto', trailing: 'OBLIGATORIO'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 80,
              decoration: const InputDecoration(
                hintText: 'Ej. Campaña Sonora Pacífico',
                counterText: '',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Ingresa el nombre del proyecto.'
                  : null,
            ),
            const SizedBox(height: 17),
            const SectionLabel('Descripción', trailing: 'MÁX. 280 CARACTERES'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _description,
              maxLength: 280,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe brevemente el alcance creativo y tipo de entrega...',
              ),
            ),
            const SizedBox(height: 17),
            const SectionLabel('Tipo de proyecto'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _type,
              items: projectTypes
                  .map(
                    (item) => DropdownMenuItem(value: item, child: Text(item)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _type = value ?? projectTypes.first),
            ),
            const SizedBox(height: 22),
            const SectionLabel(
              'Agregar imagen de portada',
              trailing: 'JPG / PNG',
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectCover,
              child: Container(
                height: 155,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                ),
                child: _newCover?.path != null
                    ? Image.file(File(_newCover!.path!), fit: BoxFit.cover)
                    : _cover != null
                    ? MediaImage(path: _cover!, height: 155)
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.muted,
                            size: 28,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Subir imagen de portada',
                            style: TextStyle(color: AppColors.cream),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Toca para explorar archivos · Máx. 15 MB',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (_newCover != null || _cover != null)
              TextButton.icon(
                onPressed: _selectCover,
                icon: const Icon(Icons.refresh),
                label: const Text('REEMPLAZAR PORTADA'),
              ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.background,
                      ),
                    )
                  : const Icon(Icons.bookmark_border),
              label: Text(_saving ? 'GUARDANDO...' : 'GUARDAR PROYECTO'),
            ),
            const SizedBox(height: 9),
            OutlinedButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: MediaBottomNavigation(
      currentIndex: 1,
      onTap: widget.onSectionSelected,
    ),
  );
}
