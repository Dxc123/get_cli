import 'dart:io';

/// 从列表创建目录
void createListDirectory(List<Directory> dirs) {
  for (final element in dirs) {
    element.createSync(recursive: true);
  }
}
