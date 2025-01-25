import 'dart:convert';
import '../../common/utils/pubspec/pubspec_utils.dart';
import '../../extensions.dart';
import '../create/create_single_file.dart';
import '../formatter_dart_file/frommatter_dart_file.dart';
import '../path/replace_to_relative.dart';

/// 对 Dart 文件中的导入语句进行排序
String sortImports(
  String content, {
  String? packageName,
  bool renameImport = false,
  String filePath = '',
  bool useRelative = false,
}) {
  // 如果未提供包名，则使用当前项目的包名
  packageName = packageName ?? PubspecUtils.projectName;

  // 格式化输入的 Dart 文件内容
  content = formatterDartFile(content);

  // 将文件内容按行分割成列表
  var lines = LineSplitter.split(content).toList();

  // 存储非导入和导出的代码行
  var contentLines = <String>[];

  // 分别存储不同类型的导入和导出语句
  var librarys = <String>[];
  var dartImports = <String>[];
  var flutterImports = <String>[];
  var packageImports = <String>[];
  var projectRelativeImports = <String>[];
  var projectImports = <String>[];
  var exports = <String>[];

  // 标记是否在多行字符串中
  var stringLine = false;

  // 遍历每一行代码，分类导入和导出语句
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].startsWith('import ') && !stringLine && lines[i].endsWith(';')) {
      // 分类不同的导入语句
      if (lines[i].contains('dart:')) {
        dartImports.add(lines[i]);
      } else if (lines[i].contains('package:flutter/')) {
        flutterImports.add(lines[i]);
      } else if (lines[i].contains('package:$packageName/')) {
        projectImports.add(lines[i]);
      } else if (!lines[i].contains('package:')) {
        projectRelativeImports.add(lines[i]);
      } else if (lines[i].contains('package:')) {
        if (!lines[i].contains('package:flutter/')) {
          packageImports.add(lines[i]);
        }
      }
    } else if (lines[i].startsWith('export ') && lines[i].endsWith(';') && !stringLine) {
      // 添加导出语句
      exports.add(lines[i]);
    } else if (lines[i].startsWith('library ') && lines[i].endsWith(';') && !stringLine) {
      // 添加库声明语句
      librarys.add(lines[i]);
    } else {
      // 检查是否在多行字符串中
      var containsThreeQuotes = lines[i].contains("'''");
      if (containsThreeQuotes) {
        stringLine = !stringLine;
      }
      // 添加其他代码行
      contentLines.add(lines[i]);
    }
  }

  // 如果没有任何导入或导出语句，直接返回原始内容
  if (dartImports.isEmpty && flutterImports.isEmpty && packageImports.isEmpty && projectImports.isEmpty && projectRelativeImports.isEmpty && exports.isEmpty) {
    return content;
  }

  // 如果需要重命名导入路径，则替换路径分隔符
  if (renameImport) {
    projectImports.replaceAll(_replacePath);
    projectRelativeImports.replaceAll(_replacePath);
  }

  // 如果需要使用相对路径，则替换项目导入路径为相对路径
  if (filePath.isNotEmpty && useRelative) {
    projectImports.replaceAll((element) => replaceToRelativeImport(element, filePath));
    projectRelativeImports.addAll(projectImports);
    projectImports.clear();
  }

  // 对所有类型的导入和导出语句进行排序
  dartImports.sort();
  flutterImports.sort();
  packageImports.sort();
  projectImports.sort();
  projectRelativeImports.sort();
  exports.sort();
  librarys.sort();

  // 组合排序后的导入、导出和其他代码行
  var sortedLines = <String>[...librarys, '', ...dartImports, '', ...flutterImports, '', ...packageImports, '', ...projectImports, '', ...projectRelativeImports, '', ...exports, '', ...contentLines];

  // 返回格式化后的排序结果
  return formatterDartFile(sortedLines.join('\n'));
}

/// 替换路径分隔符为当前系统的分隔符
String _replacePath(String str) {
  var separator = PubspecUtils.separatorFileType!;
  return replacePathTypeSeparator(str, separator);
}
