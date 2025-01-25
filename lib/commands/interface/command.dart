import '../../common/utils/logger/log_utils.dart';
import '../../core/generator.dart';
import '../../core/locales.g.dart';
import '../../exception_handler/exceptions/cli_exception.dart';
import '../../extensions.dart';
import '../impl/args_mixin.dart';

/// CLI命令的抽象基类，定义了命令的基本结构和行为
abstract class Command with ArgsMixin {
  /// 构造函数
  /// 处理命令行参数，移除命令名称和子命令名称
  Command() {
    while (
        ((args.contains(commandName) || args.contains('$commandName:$name'))) &&
            args.isNotEmpty) {
      args.removeAt(0);
    }
    if (args.isNotEmpty && args.first == name) {
      args.removeAt(0);
    }
  }

  /// 命令允许的最大参数数量
  int get maxParameters;

  /// 命令的示例代码
  String? get codeSample;

  /// 命令的名称
  String get commandName;

  /// 命令的别名列表
  List<String> get alias => [];

  /// 命令接受的标志列表
  List<String> get acceptedFlags => [];

  /// 命令的提示信息
  String? get hint;

  /// 验证命令行参数
  /// 检查标志和参数数量是否合法
  /// 返回 true 表示验证通过
  bool validate() {
    if (GetCli.arguments.contains(commandName) ||
        GetCli.arguments.contains('$commandName:$name')) {
      // 检查不支持的标志
      var flagsNotAceppts = flags;
      flagsNotAceppts.removeWhere((element) => acceptedFlags.contains(element));
      if (flagsNotAceppts.isNotEmpty) {
        LogService.info(LocaleKeys.info_unnecessary_flag.trArgsPlural(
          LocaleKeys.info_unnecessary_flag_prural,
          flagsNotAceppts.length,
          [flagsNotAceppts.toString()],
        )!);
      }

      // 检查多余的参数
      if (args.length > maxParameters) {
        List pars = args.skip(maxParameters).toList();
        throw CliException(
            LocaleKeys.error_unnecessary_parameter.trArgsPlural(
              LocaleKeys.error_unnecessary_parameter_plural,
              pars.length,
              [pars.toString()],
            ),
            codeSample: codeSample);
      }
    }
    return true;
  }

  /// 执行命令的具体逻辑
  Future<void> execute();

  /// 获取子命令列表
  List<Command> get childrens => [];
}
