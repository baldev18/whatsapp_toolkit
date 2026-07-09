import 'dart:io' as io;

class FileUtils {
  static List<dynamic> getStatuses(String path) {
    final dir = io.Directory(path);
    if (!dir.existsSync()) return [];
    return dir.listSync().where((e) {
      if (e is! io.File) return false;
      final ext = e.path.toLowerCase();
      return ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png') || ext.endsWith('.mp4');
    }).toList();
  }

  static Future<int> getFileLength(dynamic file) async {
    if (file is io.File) return await file.length();
    return 0;
  }

  static Future<void> deleteFile(String path) async {
    final file = io.File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static List<dynamic> listDirectory(String path) {
    final dir = io.Directory(path);
    if (!dir.existsSync()) return [];
    return dir.listSync(recursive: true).whereType<io.File>().toList();
  }

  static bool directoryExists(String path) {
    return io.Directory(path).existsSync();
  }
}
