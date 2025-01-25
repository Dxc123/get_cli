import 'dart:io';

import 'package:recase/recase.dart';

import '../../common/utils/logger/log_utils.dart';
import '../../common/utils/pubspec/pubspec_utils.dart';
import '../../core/internationalization.dart';
import '../../core/locales.g.dart';
import '../../extensions.dart';
import '../../samples/impl/get_route.dart';
import '../find_file/find_file_by_name.dart';
import 'get_app_pages.dart';
import 'get_support_children.dart';

/// 此命令将创建到新页面的路由
///
/// [nameRoute] 新页面的名称，用于生成路由常量名。
/// [bindingDir] 绑定文件所在的目录路径。
/// [viewDir] 视图文件所在的目录路径。
void addRoute(String nameRoute, String bindingDir, String viewDir) {
  // 查找名为 'app_routes.dart' 的文件
  var routesFile = findFileByName('app_routes.dart');

  // 如果找不到 app_routes.dart 文件，则创建一个新的路由模板文件
  if (routesFile.path.isEmpty) {
    RouteSample().create();
    routesFile = File(RouteSample().path);
  }

  // 将视图目录路径按斜杠分割成列表
  var pathSplit = viewDir.split('/');

  /// 移除路径中的文件名部分
  pathSplit.removeLast();

  /// 如果 pubspec 配置中指定了额外文件夹，则移除路径中的最后一个元素（通常是 view 文件夹）
  if (PubspecUtils.extraFolder ?? true) {
    pathSplit.removeLast();
  }

  // 移除路径中的 'app' 或 'modules' 目录
  pathSplit.removeWhere((element) => element == 'app' || element == 'modules');

  // 将路径中的每个部分转换为小写蛇形命名，并替换下划线为连字符
  for (var i = 0; i < pathSplit.length; i++) {
    pathSplit[i] = pathSplit[i].snakeCase.snakeCase.toLowerCase().replaceAll('_', '-');
  }

  // 将处理后的路径部分用斜杠连接成完整的路由路径
  var route = pathSplit.join('/');

  // 定义路由常量声明语句
  var declareRoute = 'static const ${nameRoute.snakeCase.toUpperCase()} =';
  var line = "$declareRoute '/$route';";

  // 如果支持子路由，则使用 _pathsToRoute 方法生成路径枚举
  if (supportChildrenRoutes) {
    line = '$declareRoute ${_pathsToRoute(pathSplit)};';
    var linePath = "$declareRoute '/${pathSplit.last}';";
    routesFile.appendClassContent('_Paths', linePath);
  }

  // 将路由常量添加到 Routes 类中
  routesFile.appendClassContent('Routes', line);

  // 添加应用页面配置
  addAppPage(nameRoute, bindingDir, viewDir);

  // 打印成功日志
  LogService.success(Translation(LocaleKeys.sucess_route_created).trArgs([nameRoute]));
}

/// 根据路径列表生成路由枚举字符串
///
/// [pathSplit] 路径部分的列表。
String _pathsToRoute(List<String> pathSplit) {
  var sb = StringBuffer();
  for (var e in pathSplit) {
    sb.write('_Paths.');
    sb.write(e.snakeCase.toUpperCase());
    if (e != pathSplit.last) {
      sb.write(' + ');
    }
  }
  return sb.toString();
}
