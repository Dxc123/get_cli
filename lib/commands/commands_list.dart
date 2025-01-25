import 'impl/clean/clean.dart';
import 'impl/clean/clean_all.dart';
import 'impl/commads_export.dart';
import 'impl/generate/icon/icons.dart';
import 'interface/command.dart';

/// 所有可用命令的列表
final List<Command> commands = [
  // 创建相关命令组
  CommandParent(
    'create',
    [CreateControllerCommand(), CreatePageCommand(), CreateProjectCommand(), CreateProviderCommand(), CreateScreenCommand(), CreateViewCommand()],
    ['-c'],
  ),
  // 生成相关命令组
  CommandParent(
    'generate',
    [
      GenerateLocalesCommand(),
      GenerateModelCommand(),
      GenerateIconsCommand(),
    ],
    ['-g'],
  ),
  // 其他独立命令
  HelpCommand(),
  VersionCommand(),
  InitCommand(),
  InstallCommand(),
  RemoveCommand(),
  SortCommand(),
  UpdateCommand(),
  CleanCommand(),
  CleanAllCommand(),
];

/// 命令组父类，用于组织相关命令
class CommandParent extends Command {
  /// 命令组名称
  final String _name;

  /// 命令组别名
  final List<String> _alias;

  /// 子命令列表
  final List<Command> _childrens;

  /// 构造函数
  /// [_name] 命令组名称
  /// [_childrens] 子命令列表
  /// [_alias] 命令组别名，默认为空列表
  CommandParent(this._name, this._childrens, [this._alias = const []]);

  @override
  String get commandName => _name;
  // 名称
  @override
  List<Command> get childrens => _childrens;
  // 别名
  @override
  List<String> get alias => _alias;
  // 执行
  @override
  Future<void> execute() async {}
  // 提示
  @override
  String get hint => '';

  @override
  bool validate() => true;

  // 命令示例
  @override
  String get codeSample => '';

  @override
  int get maxParameters => 0;
}
