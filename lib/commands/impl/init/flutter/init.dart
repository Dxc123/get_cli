import 'package:commander_ui/commander_ui.dart';

import '../../../../common/menu/menu.dart';
import '../../../../common/utils/logger/log_utils.dart';
import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../common/utils/shell/shel.utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../interface/command.dart';
import 'init_getxpattern.dart';
import 'init_katteko.dart';

/// Flutter 项目初始化命令
/// 允许用户选择不同的项目架构：
/// - GetX Pattern by Kauê
/// - CLEAN Architecture by Arktekko
class InitCommand extends Command {
  @override
  String get commandName => 'init';

  /// 执行初始化命令
  @override
  Future<void> execute() async {
    // // 显示架构选择菜单
    // final menu = Menu([
    //   'GetX Pattern (by Kauê)',
    //   'CLEAN (by Arktekko)',
    // ], title: '您要使用哪种架构？');
    // final result = menu.choose();
    // // 初始化选择的架构
    // result.index == 0 ? await createInitGetxPattern() : await createInitKatekko();

    final commander = Commander(level: Level.verbose);
    final result = await commander.select(
      '您要使用哪种架构?',
      onDisplay: (value) => value,
      placeholder: '使用上下方向箭头选择值',
      defaultValue: 'GetX Pattern (by Kauê)',
      options: [
        'GetX Pattern (by Kauê)',
        'CLEAN (by Arktekko)',
      ],
    );
    // print(result);
    var name = this.name;
    result == 'GetX Pattern (by Kauê)' ? await createInitGetxPattern(name: name) : await createInitKatekko();

    // 为 Flutter 项目运行 pub get
    if (!PubspecUtils.isServerProject) {
      await ShellUtils.pubGet();
      await ShellUtils.fix();
      await ShellUtils.format();
    }
    return;
  }

  @override
  String? get hint => Translation(LocaleKeys.hint_init).tr;

  @override
  bool validate() {
    super.validate();
    return true;
  }

  @override
  String? get codeSample => LogService.code('get init');

  @override
  int get maxParameters => 0;
}
