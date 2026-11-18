import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LocalFileStore {
  Future<String> copyIntoApp(
    PlatformFile picked, {
    String folder = 'resources',
  }) async {
    final source = picked.path;
    if (source == null) {
      throw const FileSystemException(
        'El archivo seleccionado no está disponible.',
      );
    }
    final directory = await getApplicationDocumentsDirectory();
    final targetDirectory = Directory(p.join(directory.path, folder));
    await targetDirectory.create(recursive: true);
    final extension = p.extension(picked.name);
    final target = p.join(
      targetDirectory.path,
      '${DateTime.now().microsecondsSinceEpoch}$extension',
    );
    await File(source).copy(target);
    return target;
  }

  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
