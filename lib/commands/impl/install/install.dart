import '../../../common/utils/logger/log_utils.dart';
import '../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../common/utils/shell/shel.utils.dart';
import '../../../core/internationalization.dart';
import '../../../core/locales.g.dart';
import '../../../exception_handler/exceptions/cli_exception.dart';
import '../../interface/command.dart';

/// Install command for adding dependencies to the project
/// 安装命令，用于向项目添加依赖
class InstallCommand extends Command {
  @override
  String get commandName => 'install';

  @override
  List<String> get alias => ['-i'];

  /// Execute the install command
  /// 执行安装命令
  @override
  Future<void> execute() async {
    var isDev = containsArg('--dev') || containsArg('-dev');
    var runPubGet = false;

    // Iterate through provided arguments to install packages
    // 遍历提供的参数以安装包
    for (var element in args) {
      var packageInfo = element.split(':');
      LogService.info('Installing package "${packageInfo.first}" …');
      if (packageInfo.length == 1) {
        runPubGet = await PubspecUtils.addDependencies(packageInfo.first,
                isDev: isDev, runPubGet: false)
            ? true
            : runPubGet;
      } else {
        runPubGet = await PubspecUtils.addDependencies(packageInfo.first,
                version: packageInfo[1], isDev: isDev, runPubGet: false)
            ? true
            : runPubGet;
      }
    }

    // Run pub get if any dependencies were added
    // 如果添加了任何依赖，则运行 pub get
    if (runPubGet) await ShellUtils.pubGet();
  }

  @override
  String? get hint => Translation(LocaleKeys.hint_install).tr;

  @override
  bool validate() {
    super.validate();

    // Ensure at least one package name is provided
    // 确保提供了至少一个包名
    if (args.isEmpty) {
      throw CliException(
          'Please, enter the name of a package you wanna install',
          codeSample: codeSample);
    }
    return true;
  }

  final String? codeSample1 = LogService.code('get install get:3.4.6');
  final String? codeSample2 = LogService.code('get install get');

  @override
  String get codeSample => '''
  $codeSample1
  if you wanna install the latest version:
  $codeSample2
''';

  @override
  int get maxParameters => 999;
}
