import '../../../common/utils/logger/log_utils.dart';
import '../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../common/utils/shell/shel.utils.dart';
import '../../../core/internationalization.dart';
import '../../../core/locales.g.dart';
import '../../../exception_handler/exceptions/cli_exception.dart';
import '../../interface/command.dart';

// 实现 remove 命令的具体逻辑
// 用于从 pubspec.yaml 文件中移除指定的依赖包，并更新依赖
class RemoveCommand extends Command {
  @override
  String get commandName => 'remove';

  // execute: 执行 remove 命令的具体逻辑。
  // 遍历传入的包名列表 args，调用 PubspecUtils.removeDependencies(package) 移除每个包的依赖。
  // 调用 ShellUtils.pubGet() 更新依赖（即执行 pub get）
  @override
  Future<void> execute() async {
    for (var package in args) {
      PubspecUtils.removeDependencies(package);
    }

    //if (GetCli.arguments.first == 'remove') {
    await ShellUtils.pubGet();
    //}
  }

  // hint: 返回该命令的帮助提示信息，通过国际化翻译获取。
  @override
  String? get hint => Translation(LocaleKeys.hint_remove).tr;

  // validate: 验证命令参数的有效性。
  // 如果 args 为空，则抛出 CliException 异常，并显示错误信息和示例代码。
  @override
  bool validate() {
    super.validate();
    if (args.isEmpty) {
      CliException(LocaleKeys.error_no_package_to_remove.tr, codeSample: codeSample);
    }
    return true;
  }

  // codeSample: 返回一个示例代码字符串，用于在异常提示中展示如何正确使用该命令。
  @override
  String? get codeSample => LogService.code('get remove http');

  //maxParameters: 返回该命令允许的最大参数数量，这里设置为 999 表示没有实际限制。
  @override
  int get maxParameters => 999;

  // alias: 返回该命令的别名列表，例如 -rm 可以作为 remove 的别名。
  @override
  List<String> get alias => ['-rm'];
}
