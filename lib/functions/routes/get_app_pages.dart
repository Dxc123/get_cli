import 'dart:convert';
import 'dart:io';

import 'package:recase/recase.dart';

import '../../common/utils/logger/log_utils.dart';
import '../../common/utils/pubspec/pubspec_utils.dart';
import '../../samples/impl/get_app_pages.dart';
import '../create/create_single_file.dart';
import '../find_file/find_file_by_name.dart';
import '../formatter_dart_file/frommatter_dart_file.dart';
import 'get_support_children.dart';

/// 向应用页面配置文件中添加新的页面路由
///
/// [name] 是新页面的名称
/// [bindingDir] 是绑定文件的路径
/// [viewDir] 是视图文件的路径
void addAppPage(String name, String bindingDir, String viewDir) {
  // 查找 app_pages.dart 文件并初始化文件对象
  var appPagesFile = findFileByName('app_pages.dart');
  var path = viewDir;
  var lines = <String>[];

  // 如果 app_pages.dart 文件不存在，则创建一个新的文件并读取其内容
  if (appPagesFile.path.isEmpty) {
    AppPagesSample(initial: name).create(skipFormatter: true);
    appPagesFile = File(AppPagesSample().path);
    lines = appPagesFile.readAsLinesSync();
  } else {
    // 如果文件存在，格式化文件内容并分割成行列表
    var content = formatterDartFile(appPagesFile.readAsStringSync());
    lines = LineSplitter.split(content).toList();
  }

  // 确定使用 Routes 或 _Paths 常量
  var routesOrPath = 'Routes';

  // 找到静态路由定义的起始位置
  var indexRoutes = lines.indexWhere((element) => element.trim().contains('static final routes'));
  var index = lines.indexWhere((element) => element.contains('];'), indexRoutes);

  var tabEspaces = 2;

  // 如果支持子路由，则进行更复杂的处理
  if (supportChildrenRoutes) {
    routesOrPath = '_Paths';
    var pathSplit = path.split('/');
    pathSplit.removeLast(); // 移除最后一个元素（通常是文件名）
    pathSplit.removeLast(); // 再移除一个元素（通常是 views 目录）

    // 移除不必要的路径部分
    pathSplit.removeWhere((element) => element == 'app' || element == 'modules');

    // 查找匹配的父级路由
    var onPageIndex = -1;
    while (pathSplit.isNotEmpty && onPageIndex == -1) {
      onPageIndex = lines.indexWhere((element) => element.contains('_Paths.${pathSplit.last.snakeCase.toUpperCase()},'), indexRoutes);

      pathSplit.removeLast();
    }

    if (onPageIndex != -1) {
      // 查找 GetPage 定义的起始和结束位置
      var onPageStartIndex = lines.sublist(0, onPageIndex).lastIndexWhere((element) => element.contains('GetPage'));

      var onPageEndIndex = -1;

      if (onPageStartIndex != -1) {
        onPageEndIndex = lines.indexWhere((element) => element.startsWith('${_getTabs(_countTabs(lines[onPageStartIndex]))}),'), onPageStartIndex);
      } else {
        _logInvalidFormart();
      }

      if (onPageEndIndex != -1) {
        // 检查是否已有 children 属性
        var indexChildrenStart = lines.sublist(onPageStartIndex, onPageEndIndex).indexWhere((element) => element.contains('children'));

        if (indexChildrenStart == -1) {
          // 如果没有 children 属性，则添加
          tabEspaces = _countTabs(lines[onPageStartIndex]) + 1;
          index = onPageEndIndex;
          lines.insert(index, '${_getTabs(tabEspaces)}children: [');
          index++;
          lines.insert(index, '${_getTabs(tabEspaces)}],');
          tabEspaces++;
        } else {
          // 如果已有 children 属性，则找到其结束位置
          var indexChildrenEnd = -1;
          indexChildrenEnd = lines.indexWhere((element) => element.startsWith('${_getTabs(_countTabs(lines[onPageStartIndex]) + 1)}],'), onPageStartIndex);

          if (indexChildrenEnd != -1) {
            index = indexChildrenEnd;
            tabEspaces = _countTabs(lines[onPageStartIndex]) + 2;
          } else {
            _logInvalidFormart();
          }
        }
      } else {
        _logInvalidFormart();
      }
    }
  }

  // 构建新的页面路由定义
  var nameSnakeCase = name.snakeCase;
  var namePascalCase = name.pascalCase;
  var line = '''${_getTabs(tabEspaces)}GetPage(
${_getTabs(tabEspaces + 1)}name: $routesOrPath.${nameSnakeCase.toUpperCase()}, 
${_getTabs(tabEspaces + 1)}page:()=> const ${namePascalCase}View(), 
${_getTabs(tabEspaces + 1)}binding: ${namePascalCase}Binding(),
${_getTabs(tabEspaces)}),''';

  // 添加导入语句
  var import = "import 'package:${PubspecUtils.projectName}/";

  lines.insert(index, line);
  lines.insert(0, "$import$bindingDir';");
  lines.insert(0, "$import$viewDir';");

  // 将更新后的内容写回文件
  writeFile(
    appPagesFile.path,
    lines.join('\n'),
    overwrite: true,
    logger: false,
    useRelativeImport: true,
  );
}

/// 创建指定数量的缩进空格
///
/// [tabEspaces] 是缩进的数量
String _getTabs(int tabEspaces) {
  return '  ' * tabEspaces;
}

/// 计算给定行中的缩进数量
///
/// [line] 是要计算缩进的行
int _countTabs(String line) {
  return '  '.allMatches(line).length;
}

/// 记录无效文件格式的日志信息
void _logInvalidFormart() {
  LogService.info(
      'the app_pages.dart file does not meet the '
      'expected format, fails to create children pages',
      false,
      false);
}
