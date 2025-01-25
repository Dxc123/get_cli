import 'dart:convert';
import 'dart:io';

import 'package:recase/recase.dart';

import '../../common/utils/logger/log_utils.dart';
import '../../core/internationalization.dart';
import '../../core/locales.g.dart';
import '../../core/structure.dart';
import '../../samples/impl/arctekko/arc_routes.dart';
import '../create/create_navigation.dart';
import '../create/create_single_file.dart';
import '../formatter_dart_file/frommatter_dart_file.dart';

/// 添加新的路由到项目中
///
/// [nameRoute] 是新路由的名称
void arcAddRoute(String nameRoute) {
  // 获取路由文件路径并初始化文件对象
  var routesFile = File(Structure.replaceAsExpected(path: 'lib/infrastructure/navigation/routes.dart'));

  // 初始化行列表用于存储文件内容
  var lines = <String>[];

  // 如果路由文件不存在，则创建一个新的路由文件并读取其内容
  if (!routesFile.existsSync()) {
    ArcRouteSample(nameRoute.snakeCase.toUpperCase()).create();
    lines = routesFile.readAsLinesSync();
  } else {
    // 如果文件存在，格式化文件内容并分割成行列表
    var content = formatterDartFile(routesFile.readAsStringSync());
    lines = LineSplitter.split(content).toList();
  }

  // 构建新的路由常量定义
  var line = 'static const ${nameRoute.snakeCase.toUpperCase()} = \'/${nameRoute.snakeCase.toLowerCase().replaceAll('_', '-')}\';';

  // 检查是否已存在相同的路由定义
  if (lines.contains(line)) {
    return;
  }

  // 移除末尾的空行
  while (lines.last.isEmpty) {
    lines.removeLast();
  }

  // 添加新的路由定义
  lines.add(line);

  // 对路由进行排序
  _routesSort(lines);

  // 将更新后的内容写回文件
  writeFile(routesFile.path, lines.join('\n'), overwrite: true);

  // 记录成功日志
  LogService.success(Translation(LocaleKeys.sucess_route_created).trArgs([nameRoute]));

  // 添加导航逻辑
  addNavigation(nameRoute);
}

/// 对路由定义进行排序
///
/// [lines] 是包含所有文件内容的行列表
List<String> _routesSort(List<String> lines) {
  var routes = <String>[]; // 存储所有的路由定义
  var lines2 = <String>[]; // 复制原始行列表以避免修改原列表

  // 复制原始行列表
  lines2.addAll(lines);

  // 提取所有路由定义并移除它们
  for (var line in lines2) {
    if (line.contains('static const')) {
      routes.add(line);
      lines.remove(line);
    }
  }

  // 对路由定义进行排序
  routes.sort();

  // 将排序后的路由定义插入到文件内容的最后一行之前
  lines.insertAll(lines.length - 1, routes);

  // 返回更新后的行列表
  return lines;
}
