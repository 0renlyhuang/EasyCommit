import 'dart:io';
import 'package:path/path.dart' as xPath;

class FileSystemHelper {
  static void openFolder(String path) async {
    String folderDir = '';
    do {
      bool isDir = await FileSystemEntity.isDirectory(path);
      if (isDir) {
        folderDir = path;
        break;
      }

      bool isFile = await FileSystemEntity.isFile(path);
      if (isFile) {
        folderDir = xPath.dirname(path);
        break;
      }

      assert(false);
      return;
    } while (true);

    if (Platform.isMacOS) {
      Process.run('open', [folderDir]);
    } else if (Platform.isWindows) {
      Process.run('start', [folderDir]);
    }
  }
}