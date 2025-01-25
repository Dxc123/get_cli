import 'dart:io';

import 'package:recase/recase.dart';

import '../../common/utils/logger/log_utils.dart';
import '../../common/utils/pubspec/pubspec_utils.dart';
import '../../core/internationalization.dart';
import '../../core/locales.g.dart';
import '../create/create_single_file.dart';

///
/// 向绑定文件中添加一个新的依赖项。
///
///示例：假设你的绑定文件如下：
/// ```
///import 'package:get/get.dart';
///import 'home_controller.dart';
///class HomeBinding extends Bindings {
///   @override
///   void dependencies() {
///     Get.lazyPut<HomeController>(
///       () => HomeController()
///     );
///   }
///}
///
/// 调用 `addDependencyToBinding('PATH_YOUR_BINDING', 'DEPENDENCY_NAME', 'DEPENDENCY_DIR')` 后，
/// 文件将变为：
///
///import 'package:get/get.dart';
///import 'home_controller.dart';
///import 'package:example/DEPENDENCY_DIR';
///class HomeBinding extends Bindings {
///    @override
///    void dependencies() {
///      Get.lazyPut<DEPENDENCY_NAME>(
///        () => DEPENDENCY_NAME()
///       );
///      Get.lazyPut<HomeController>(
///        () => HomeController()
///       );
///    }
///}
///```
void addDependencyToBinding(String path, String controllerName, String import) {
  // 构建导入语句
  import = '''import 'package:${PubspecUtils.projectName}/$import';''';
  // 打开绑定文件
  var file = File(path);
  // 检查文件是否存在
  if (file.existsSync()) {
    // 读取文件内容并按行分割
    var lines = file.readAsLinesSync();
    // 在文件的第三行插入新的导入语句
    lines.insert(2, import);
    // 查找 `void dependencies() {` 的位置，并在其后插入新的依赖项
    var index = lines.indexWhere((element) {
      element = element.trim();
      return element.startsWith('void dependencies() {');
    });
    index++;
    lines.insert(index, '''Get.lazyPut<${controllerName.pascalCase}Controller>(
          () => ${controllerName.pascalCase}Controller(),
);''');
    // 将修改后的内容写回文件
    writeFile(file.path, lines.join('\n'), overwrite: true, logger: false);
    // 输出成功日志
    LogService.success(LocaleKeys.sucess_add_controller_in_bindings
        .trArgs([controllerName.pascalCase, path]));
  }
}
