import 'dart:io';

import 'package:get_cli/samples/impl/get_view_stf.dart';
import 'package:http/http.dart';
import 'package:recase/recase.dart';

import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../exception_handler/exceptions/cli_exception.dart';
import '../../../../functions/create/create_single_file.dart';
import '../../../../functions/is_url/is_url.dart';
import '../../../../functions/replace_vars/replace_vars.dart';
import '../../../../samples/impl/get_view.dart';
import '../../../interface/command.dart';

/// 创建视图命令类
/// 用于生成一个独立的视图文件，可以是对话框、组件等
class CreateViewCommand extends Command {
  @override
  String get commandName => 'view';
  @override
  String? get hint => Translation(LocaleKeys.hint_create_view).tr;

  @override
  bool validate() {
    return true;
  }

  /// 执行视图创建命令
  @override
  Future<void> execute() async {
    return createView(name, withArgument: withArgument, onCommand: onCommand);
  }

  /// 命令使用示例
  @override
  String get codeSample => 'get create view:delete_dialog';

  @override
  int get maxParameters => 0;
}

/// 创建视图文件
/// [name] 视图名称
/// [withArgument] 自定义模板的URL或文件路径
/// [onCommand] 指定创建位置的路径
Future<void> createView(String name, {String withArgument = '', String onCommand = ''}) async {
  // var sample = GetViewSample(
  //   '',
  //   '${name.pascalCase}View',
  //   '',
  //   '',
  //   PubspecUtils.isServerProject,
  // );
  var sample = GetViewStfSample(
    '',
    '${name.pascalCase}View',
    '',
    '',
    PubspecUtils.isServerProject,
  );
  if (withArgument.isNotEmpty) {
    if (isURL(withArgument)) {
      var res = await get(Uri.parse(withArgument));
      if (res.statusCode == 200) {
        var content = res.body;
        sample.customContent = replaceVars(content, name);
      } else {
        throw CliException(LocaleKeys.error_failed_to_connect.trArgs([withArgument]));
      }
    } else {
      var file = File(withArgument);
      if (file.existsSync()) {
        var content = file.readAsStringSync();
        sample.customContent = replaceVars(content, name);
      } else {
        throw CliException(LocaleKeys.error_no_valid_file_or_url.trArgs([withArgument]));
      }
    }
  }

  handleFileCreate(name, 'view', onCommand, true, sample, 'views');
}
