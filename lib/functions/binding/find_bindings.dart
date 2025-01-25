import 'dart:io';

import 'package:path/path.dart';
import 'package:recase/recase.dart';

import '../../core/structure.dart';


///
/// 根据给定的路径和名称查找绑定文件。
///
/// 该函数会从给定路径开始向上遍历目录，直到找到与指定名称匹配的绑定文件。
/// 支持两种命名格式：
/// - `${name.snakeCase}_binding.dart`
/// - `${name.snakeCase}.controller.binding.dart`
///
/// 参数:
/// - `path`: 起始路径，用于查找绑定文件。
/// - `name`: 控制器或模块的名称，用于构建绑定文件名。
///
/// 返回值:
/// - 匹配的绑定文件的完整路径，如果未找到则返回空字符串。
///

String findBindingFromName(String path, String name) {
  // 将路径转换为预期格式（例如处理相对路径）
  path = Structure.replaceAsExpected(path: path);
  // 将路径分割成列表，方便逐级遍历
  var splitPath = Structure.safeSplitPath(path);
  splitPath
    ..remove('.')// 移除当前目录符号 '.'
    ..removeLast();// 移除最后一部分，确保从父目录开始查找

  var bindingPath = '';//用于存储找到的绑定文件路径
  // 逐级向上遍历目录，直到找到绑定文件或遍历完所有层级
  while (splitPath.isNotEmpty && bindingPath == '') {
    // 获取当前层级的路径
    var currentPath = splitPath.join(separator);
    // 遍历当前目录下的所有文件
    Directory(currentPath)
        .listSync(recursive: true, followLinks: false)
        .forEach((element) {
      if (element is File) {
        // 获取文件名
        var fileName = basename(element.path);
        // 检查文件名是否符合绑定文件的命名规则
        if (fileName == '${name.snakeCase}_binding.dart' ||
            fileName == '${name.snakeCase}.controller.binding.dart') {
          bindingPath = element.path;
        }
      }
    });
    // 如果未找到绑定文件，移除当前层级的最后一部分，继续向上一级目录查找
    if (bindingPath.isEmpty) {
      splitPath.removeLast();
    }
  }
  return bindingPath; // 返回找到的绑定文件路径，或空字符串表示未找到
}
