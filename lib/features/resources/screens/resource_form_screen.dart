import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/media_widgets.dart';
import '../../../data/models/media_project.dart';
import '../../../data/models/media_resource.dart';
import '../../../data/repositories/media_repository.dart';
import '../../../services/local_file_store.dart';

const editableCategories = [
  'Fotografías e imágenes',
  'Documentos',
  'Gráficos',
  'Videos',
  'Audios',
  'Otros',
];
const allowedExtensions = [
  'jpg',
  'jpeg',
  'png',
  'webp',
  'pdf',
  'docx',
  'txt',
  'mp4',
  'mp3',
  'wav',
];

class ResourceFormScreen extends StatefulWidget {
  const ResourceFormScreen({
    super.key,
    required this.project,
    required this.onSectionSelected,
    this.resource,
  });
  final MediaProject project;
  final ValueChanged<int> onSectionSelected;
  final MediaResource? resource;
  @override
  State<ResourceFormScreen> createState() => _ResourceFormScreenState();
}

class _ResourceFormScreenState extends State<ResourceFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late String _category;
  PlatformFile? _picked;
  bool _saving = false;
  final _files = LocalFileStore();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.resource?.name ?? '');
    _description = TextEditingController(
      text: widget.resource?.description ?? '',
    );
    _category = widget.resource?.category ?? editableCategories.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: false,
      );
      if (result == null || !mounted) return;
      final item = result.files.single;
      final ext = item.extension?.toLowerCase() ?? '';
      if (!allowedExtensions.contains(ext)) {
        _message('Ese formato no está permitido.');
        return;
      }
      if (item.size > 50 * 1024 * 1024) {
        _message('El archivo no puede superar 50 MB.');
        return;
      }
      setState(() {
        _picked = item;
        if (widget.resource == null || _name.text.isEmpty) {
          _name.text = item.name.replaceFirst(RegExp(r'\.[^.]+$'), '');
        }
        if (widget.resource == null) _category = categoryForExtension(ext);
      });
    } catch (_) {
      if (mounted) _message('No fue posible abrir el selector de archivos.');
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_picked == null && widget.resource == null) {
      _message('Selecciona un archivo antes de guardar.');
      return;
    }
    setState(() => _saving = true);
    String? copiedPath;
    try {
      final previous = widget.resource;
      final picked = _picked;
      final path = picked == null
          ? previous!.localFilePath
          : copiedPath = await _files.copyIntoApp(picked);
      final file = File(path);
      final exists = await file.exists();
      if (!exists) {
        throw const FileSystemException('El archivo local no está disponible.');
      }
      final bytes = await file.length();
      final ext = picked?.extension?.toLowerCase() ?? previous!.fileExtension;
      int? width = previous?.imageWidth;
      int? height = previous?.imageHeight;
      if (['jpg', 'jpeg', 'png', 'webp'].contains(ext)) {
        try {
          final decoded = img.decodeImage(await file.readAsBytes());
          width = decoded?.width;
          height = decoded?.height;
        } catch (_) {
          width = null;
          height = null;
        }
      } else {
        width = null;
        height = null;
      }
      final now = DateTime.now();
      final item = MediaResource(
        id: previous?.id,
        projectId: widget.project.id!,
        name: _name.text.trim(),
        description: _description.text.trim(),
        category: _category,
        originalFileName: picked?.name ?? previous!.originalFileName,
        fileExtension: ext,
        localFilePath: path,
        fileSize: bytes,
        imageWidth: width,
        imageHeight: height,
        createdAt: previous?.createdAt ?? now,
        updatedAt: now,
      );
      if (previous == null) {
        await MediaRepository.instance.saveResource(item);
      } else {
        await MediaRepository.instance.updateResource(item);
        if (picked != null && previous.localFilePath != path) {
          try {
            await _files.delete(previous.localFilePath);
          } catch (_) {
            /* El registro ya apunta al archivo nuevo. */
          }
        }
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (copiedPath != null) await _files.delete(copiedPath);
      if (mounted) {
        setState(() => _saving = false);
        _message(
          'No se pudo guardar el recurso. Revisa el archivo e inténtalo de nuevo.',
        );
      }
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final resource = widget.resource;
    final chosenName = _picked?.name ?? resource?.originalFileName;
    final chosenPath = _picked?.path ?? resource?.localFilePath;
    final chosenSize = _picked?.size ?? resource?.fileSize;
    return Scaffold(
      appBar: MediaAppBar(
        title: resource == null ? 'AGREGAR RECURSO' : 'EDITAR RECURSO',
        onBack: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              PageHeading(
                kicker:
                    'Importación de recurso · ${resource == null ? 'nuevo' : 'edición'}',
                title: resource == null
                    ? 'Agregar recurso'
                    : 'Editar información',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                color: AppColors.surface,
                child: Row(
                  children: [
                    const Icon(Icons.folder_outlined, color: AppColors.orange),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DESTINO EN CATÁLOGO',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                              letterSpacing: .7,
                            ),
                          ),
                          Text(
                            widget.project.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 23),
              const SectionLabel(
                '01 // Archivo fuente',
                trailing: 'LOCAL DEVICE',
              ),
              const SizedBox(height: 9),
              OutlinedButton.icon(
                onPressed: _selectFile,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  chosenName == null
                      ? 'SELECCIONAR ARCHIVO DESDE EL DISPOSITIVO'
                      : 'REEMPLAZAR ARCHIVO',
                ),
              ),
              if (chosenName != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      if (chosenPath != null &&
                          ['jpg', 'jpeg', 'png', 'webp'].contains(
                            (_picked?.extension ?? resource?.fileExtension)
                                .toString()
                                .toLowerCase(),
                          ))
                        MediaImage(path: chosenPath, width: 56, height: 56)
                      else
                        Container(
                          width: 56,
                          height: 56,
                          color: AppColors.surfaceRaised,
                          child: const Icon(
                            Icons.insert_drive_file_outlined,
                            color: AppColors.orange,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chosenName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(_picked?.extension ?? resource?.fileExtension ?? '').toUpperCase()} · ${formatBytes(chosenSize ?? 0)}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              const SectionLabel('02 // Metadatos y clasificación'),
              const SizedBox(height: 10),
              const SectionLabel('Nombre del recurso', trailing: 'OBLIGATORIO'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingresa un nombre para el recurso.'
                    : null,
              ),
              const SizedBox(height: 16),
              const SectionLabel(
                'Categoría de archivo',
                trailing: 'OBLIGATORIO',
              ),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
                initialValue: _category,
                items: editableCategories
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) => setState(
                  () => _category = value ?? editableCategories.first,
                ),
              ),
              const SizedBox(height: 16),
              const SectionLabel(
                'Descripción contextual',
                trailing: 'OPCIONAL',
              ),
              const SizedBox(height: 7),
              TextFormField(
                controller: _description,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText:
                      'Agrega contexto útil para identificar el archivo...',
                ),
              ),
              const SizedBox(height: 24),
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
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'GUARDANDO...' : 'GUARDAR RECURSO'),
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
        currentIndex: 2,
        onTap: widget.onSectionSelected,
      ),
    );
  }
}
