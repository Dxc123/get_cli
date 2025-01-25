import '../commands/commands_list.dart';
import '../commands/impl/help/help.dart';
import '../commands/interface/command.dart';
import '../common/utils/logger/log_utils.dart';

/*
GetCli 类 - CLI工具的核心类，负责命令的查找和处理， 这个文件是 Get CLI 的核心实现，主要包含三个类：
1.GetCli - 核心类
使用单例模式管理实例
负责命令的查找和处理
支持命令的层级结构
2.ErrorCommand - 错误处理类
处理命令执行过程中的错误
提供友好的错误提示
引导用户使用帮助命令
3.NotFoundComannd - 命令未找到处理类
处理找不到命令的情况
提供默认的错误处理
待实现具体逻辑
* */
class GetCli {
  /// 存储命令行参数
  final List<String> _arguments;

  /// 构造函数 - 初始化并设置单例实例
  GetCli(this._arguments) {
    _instance = this;
  }

  /// 单例模式实现
  static GetCli? _instance;

  /// 获取 GetCli 实例的全局访问点
  static GetCli? get to => _instance;

  /// 获取命令行参数
  static List<String> get arguments => to!._arguments;

  /// 查找命令的公共方法
  Command findCommand() => _findCommand(0, commands);

  /// 递归查找命令的私有方法
  /// @param currentIndex 当前参数索引
  /// @param commands 要搜索的命令列表
  Command _findCommand(int currentIndex, List<Command> commands) {
    try {
      /// 获取当前参数，并分割掉可能的参数修饰符（例如 create:page 中的 :page）
      final currentArgument = arguments[currentIndex].split(':').first;

      /// 在命令列表中查找匹配的命令
      var command = commands.firstWhere((command) => command.commandName == currentArgument || command.alias.contains(currentArgument), orElse: () => ErrorCommand('command not found'));

      /// 处理子命令的逻辑
      if (command.childrens.isNotEmpty) {
        if (command is CommandParent) {
          /// 如果是父命令，直接递归查找子命令
          command = _findCommand(++currentIndex, command.childrens);
        } else {
          /// 尝试查找子命令，如果找到则使用子命令
          var childrenCommand = _findCommand(++currentIndex, command.childrens);
          if (childrenCommand is! ErrorCommand) {
            command = childrenCommand;
          }
        }
      }
      return command;

      /// 异常处理
    } on RangeError catch (_) {
      /// 参数不足时返回帮助命令
      return HelpCommand();
    } on Exception catch (_) {
      /// 其他异常则向上抛出
      rethrow;
    }
  }
}

/// 错误命令类 - 处理命令未找到等错误情况
class ErrorCommand extends Command {
  @override
  String get commandName => 'onerror';

  /// 存储错误信息
  String error;
  ErrorCommand(this.error);

  @override
  Future<void> execute() async {
    /// 输出错误信息
    LogService.error(error);

    /// 提示用户使用帮助命令
    LogService.info('run `get help` to help', false, false);
  }

  @override
  String get hint => 'Print on erro';

  @override
  String get codeSample => '';

  @override
  int get maxParameters => 0;

  @override
  bool validate() => true;
}

/// 命令未找到类 - 处理命令不存在的情况
class NotFoundComannd extends Command {
  @override
  String get commandName => 'Not Found Comannd';

  @override
  Future<void> execute() async {
    /// TODO: 实现命令未找到时的处理逻辑
  }

  @override
  String get hint => 'Not Found Comannd';

  @override
  String get codeSample => '';

  @override
  int get maxParameters => 0;

  @override
  bool validate() => true;
}
