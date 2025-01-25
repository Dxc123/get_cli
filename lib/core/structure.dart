import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';

import '../exception_handler/exceptions/cli_exception.dart';
import '../models/file_model.dart';
import 'internationalization.dart';
import 'locales.g.dart';

/// 项目结构管理类，用于处理文件路径和目录结构
class Structure {
  /// 预定义的项目路径映射
  /// 包含了不同类型文件（页面、控制器、模型等）的默认存放路径
  static final Map<String, String> _paths = {
    // 页面文件路径，优先使用 lib/pages，不存在则使用 lib/app/modules
    'page': Directory(replaceAsExpected(path: '${Directory.current.path}/lib/pages/')).existsSync() ? replaceAsExpected(path: 'lib/pages') : replaceAsExpected(path: 'lib/app/modules'),
    // 各种组件的默认路径
    'widget': replaceAsExpected(path: 'lib/app/widgets/'),
    'model': replaceAsExpected(path: 'lib/app/data/models'),
    'init': replaceAsExpected(path: 'lib/'),
    'route': replaceAsExpected(path: 'lib/routes/'),
    'repository': replaceAsExpected(path: 'lib/app/data/'),
    'provider': replaceAsExpected(path: 'lib/app/data'),
    'controller': replaceAsExpected(path: 'lib/app'),
    'binding': replaceAsExpected(path: 'lib/app'),
    'view': replaceAsExpected(path: 'lib/app/views/'),
    // artekko 架构相关文件路径
    'screen': replaceAsExpected(path: 'lib/presentation'),
    'controller.binding': replaceAsExpected(path: 'lib/infrastructure/navigation/bindings'),
    'navigation': replaceAsExpected(path: 'lib/infrastructure/navigation/navigation.dart'),
    // 生成的本地化文件路径
    'generate_locales': replaceAsExpected(path: 'lib/generated'),
  };

  /// 创建文件模型
  /// [name] 文件名
  /// [command] 用于确定默认路径的命令
  /// [wrapperFolder] 是否在文件外创建一个文件夹
  /// [on] 可选的自定义路径
  /// [folderName] 可选的文件夹名
  static FileModel model(String? name, String command, bool wrapperFolder, {String? on, String? folderName}) {
    if (on != null && on != '') {
      // 处理自定义路径
      on = replaceAsExpected(path: on).replaceAll('\\\\', '\\');
      var current = Directory('lib');
      final list = current.listSync(recursive: true, followLinks: false);
      // 查找指定目录
      final contains = list.firstWhere((element) {
        if (element is File) {
          return false;
        }

        return '${element.path}${p.separator}'.contains('$on${p.separator}');
      }, orElse: () {
        return list.firstWhere((element) {
          if (element is File) {
            return false;
          }
          return element.path.contains(on!);
        }, orElse: () {
          throw CliException(LocaleKeys.error_folder_not_found.trArgs([on]));
        });
      });

      return FileModel(
        name: name,
        path: Structure.getPathWithName(
          contains.path,
          ReCase(name!).snakeCase,
          createWithWrappedFolder: wrapperFolder,
          folderName: folderName,
        ),
        commandName: command,
      );
    }
    // 使用默认路径创建文件模型
    return FileModel(
      name: name,
      path: Structure.getPathWithName(
        _paths[command],
        ReCase(name!).snakeCase,
        createWithWrappedFolder: wrapperFolder,
        folderName: folderName,
      ),
      commandName: command,
    );
  }

  /// 根据平台替换路径分隔符
  /// [path] 需要处理的路径
  static String replaceAsExpected({required String path}) {
    if (path.contains('\\')) {
      if (Platform.isLinux || Platform.isMacOS) {
        return path.replaceAll('\\', '/');
      } else {
        return path;
      }
    } else if (path.contains('/')) {
      if (Platform.isWindows) {
        return path.replaceAll('/', '\\\\');
      } else {
        return path;
      }
    } else {
      return path;
    }
  }

  /// 组合路径名称
  /// [firstPath] 基础路径
  /// [secondPath] 次级路径
  /// [createWithWrappedFolder] 是否创建包装文件夹
  /// [folderName] 文件夹名称
  static String? getPathWithName(String? firstPath, String secondPath, {bool createWithWrappedFolder = false, required String? folderName}) {
    late String betweenPaths;
    // 根据平台设置路径分隔符
    if (Platform.isWindows) {
      betweenPaths = '\\\\';
    } else if (Platform.isMacOS || Platform.isLinux) {
      betweenPaths = '/';
    }
    if (betweenPaths.isNotEmpty) {
      if (createWithWrappedFolder) {
        return firstPath! + betweenPaths + folderName! + betweenPaths + secondPath;
      } else {
        return firstPath! + betweenPaths + secondPath;
      }
    }
    return null;
  }

  /// 安全地分割路径字符串
  /// [path] 需要分割的路径
  static List<String> safeSplitPath(String path) {
    return path.replaceAll('\\', '/').split('/')..removeWhere((element) => element.isEmpty);
  }

  /// 将路径转换为导入语句格式
  /// [path] 需要转换的路径
  static String pathToDirImport(String path) {
    var pathSplit = safeSplitPath(path)..removeWhere((element) => element == '.' || element == 'lib');
    return pathSplit.join('/');
  }
}
