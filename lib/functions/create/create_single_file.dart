import 'dart:io';

import 'package:path/path.dart';

import '../../common/utils/logger/log_utils.dart';
import '../../common/utils/pubspec/pubspec_utils.dart';
import '../../core/internationalization.dart';
import '../../core/locales.g.dart';
import '../../core/structure.dart';
import '../../samples/interface/sample_interface.dart';
import '../sorter_imports/sort.dart';

/// Creates a file based on the given parameters and sample
/// 根据给定的参数和示例创建文件
///
/// [name] - name of the file to create 文件名
/// [command] - type of file to create (controller, view, etc.) 文件类型
/// [on] - target directory 目标目录
/// [extraFolder] - whether to create an extra folder 是否创建额外文件夹
/// [sample] - template to use 使用的模板
/// [folderName] - name of the folder to create 要创建的文件夹名称
/// [sep] - separator to use between name and command 名称和命令之间的分隔符
File handleFileCreate(String name, String command, String on, bool extraFolder,
    Sample sample, String folderName,
    [String sep = '_']) {
  folderName = folderName;
  /* if (folderName.isNotEmpty) {
    extraFolder = PubspecUtils.extraFolder ?? extraFolder;
  } */
  final fileModel = Structure.model(name, command, extraFolder,
      on: on, folderName: folderName);
  var path = '${fileModel.path}$sep${fileModel.commandName}.dart';
  sample.path = path;
  return sample.create();
}

/// Create or edit the contents of a file
/// 创建或编辑文件内容
///
/// [path] - path to the file 文件路径
/// [content] - content to write 要写入的内容
/// [overwrite] - whether to overwrite existing file 是否覆盖现有文件
/// [skipFormatter] - whether to skip formatting 是否跳过格式化
/// [logger] - whether to log success message 是否记录成功消息
/// [skipRename] - whether to skip renaming 是否跳过重命名
/// [useRelativeImport] - whether to use relative imports 是否使用相对导入
File writeFile(String path, String content,
    {bool overwrite = false,
    bool skipFormatter = false,
    bool logger = true,
    bool skipRename = false,
    bool useRelativeImport = false}) {
  var newFile = File(Structure.replaceAsExpected(path: path));

  if (!newFile.existsSync() || overwrite) {
    // Format dart files
    // 格式化 dart 文件
    if (!skipFormatter) {
      if (path.endsWith('.dart')) {
        try {
          content = sortImports(
            content,
            renameImport: !skipRename,
            filePath: path,
            useRelative: useRelativeImport,
          );
        } on Exception catch (_) {
          if (newFile.existsSync()) {
            LogService.info(
                LocaleKeys.error_invalid_dart.trArgs([newFile.path]));
          }
          rethrow;
        }
      }
    }

    // Handle file type separator
    // 处理文件类型分隔符
    if (!skipRename && newFile.path != 'pubspec.yaml') {
      var separatorFileType = PubspecUtils.separatorFileType!;
      if (separatorFileType.isNotEmpty) {
        newFile = newFile.existsSync()
            ? newFile = newFile
                .renameSync(replacePathTypeSeparator(path, separatorFileType))
            : File(replacePathTypeSeparator(path, separatorFileType));
      }
    }

    // Create and write file
    // 创建并写入文件
    newFile.createSync(recursive: true);
    newFile.writeAsStringSync(content);
    if (logger) {
      LogService.success(
        LocaleKeys.sucess_file_created.trArgs(
          [basename(newFile.path), newFile.path],
        ),
      );
    }
  }
  return newFile;
}

/// Replace the file name separator
/// 替换文件名分隔符
///
/// [path] - file path to process 要处理的文件路径
/// [separator] - separator to use 要使用的分隔符
String replacePathTypeSeparator(String path, String separator) {
  if (separator.isNotEmpty) {
    // Find file type pattern
    // 查找文件类型模式
    var index = path.indexOf(RegExp(r'controller.dart|model.dart|provider.dart|'
        'binding.dart|view.dart|screen.dart|widget.dart|repository.dart'));
    if (index != -1) {
      // Replace separator
      // 替换分隔符
      var chars = path.split('');
      index--;
      chars.removeAt(index);
      if (separator.length > 1) {
        chars.insert(index, separator[0]);
      } else {
        chars.insert(index, separator);
      }
      return chars.join();
    }
  }

  return path;
}
