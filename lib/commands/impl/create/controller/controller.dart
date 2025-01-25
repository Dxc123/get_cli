import 'dart:io';

import 'package:http/http.dart';
import 'package:path/path.dart';

import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../core/structure.dart';
import '../../../../exception_handler/exceptions/cli_exception.dart';
import '../../../../functions/binding/add_dependencies.dart';
import '../../../../functions/binding/find_bindings.dart';
import '../../../../functions/create/create_single_file.dart';
import '../../../../functions/is_url/is_url.dart';
import '../../../../functions/replace_vars/replace_vars.dart';
import '../../../../samples/impl/get_controller.dart';
import '../../../interface/command.dart';

/*
/ 创建控制器命令类
/ 用于生成一个基本的 GetX 控制器文件
/ 默认模板为：
/ ```dart
/ import 'package:get/get.dart';
/
/ class NameController extends GetxController {
/
/ }
/ ```
* */
class CreateControllerCommand extends Command {
  @override
  String? get hint => LocaleKeys.hint_create_controller.tr;

  /// 命令使用示例
  /// 包含可选参数 [on] 和 [with] 的说明
  @override
  String get codeSample => 'get create controller:name [OPTINAL PARAMETERS] \n'
      '${LocaleKeys.optional_parameters.trArgs(['[on, with]'])} ';

  /// 验证命令参数
  /// 检查是否存在多余的参数
  /// 如果参数数量超过2个，则抛出异常
  @override
  bool validate() {
    super.validate();
    if (args.length > 2) {
      var unnecessaryParameter = args.skip(2).toList();
      throw CliException(
          LocaleKeys.error_unnecessary_parameter.trArgsPlural(
            LocaleKeys.error_unnecessary_parameter_plural,
            unnecessaryParameter.length,
            [unnecessaryParameter.toString()],
          ),
          codeSample: codeSample);
    }
    return true;
  }

  /// 执行控制器创建命令
  @override
  Future<void> execute() async {
    return createController(name,
        withArgument: withArgument, onCommand: onCommand);
  }

  /// 创建控制器文件
  /// [name] 控制器名称
  /// [withArgument] 自定义模板的URL或文件路径
  /// [onCommand] 指定创建位置的路径
  Future<void> createController(String name,
      {String withArgument = '', String onCommand = ''}) async {
    // 创建控制器示例对象
    var sample = ControllerSample('', name, PubspecUtils.isServerProject);

    // 处理自定义模板
    if (withArgument.isNotEmpty) {
      if (isURL(withArgument)) {
        // 从URL获取模板
        var res = await get(Uri.parse(withArgument));
        if (res.statusCode == 200) {
          var content = res.body;
          sample.customContent = replaceVars(content, name);
        } else {
          throw CliException(
              LocaleKeys.error_failed_to_connect.trArgs([withArgument]));
        }
      } else {
        // 从本地文件获取模板
        var file = File(withArgument);
        if (file.existsSync()) {
          var content = file.readAsStringSync();
          sample.customContent = replaceVars(content, name);
        } else {
          throw CliException(
              LocaleKeys.error_no_valid_file_or_url.trArgs([withArgument]));
        }
      }
    }

    // 创建控制器文件
    var controllerFile = handleFileCreate(
      name,
      'controller',
      onCommand,
      true,
      sample,
      'controllers',
    );

    // 查找并更新绑定文件
    var binindingPath =
        findBindingFromName(controllerFile.path, basename(onCommand));
    var pathSplit = Structure.safeSplitPath(controllerFile.path);
    pathSplit.remove('.');
    pathSplit.remove('lib');
    if (binindingPath.isNotEmpty) {
      addDependencyToBinding(binindingPath, name, pathSplit.join('/'));
    }
  }

  @override
  String get commandName => 'controller';

  @override
  int get maxParameters => 0;
}
