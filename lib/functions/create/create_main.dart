import 'dart:io';

import 'package:commander_ui/commander_ui.dart';

import '../../common/menu/menu.dart';
import '../../common/utils/logger/log_utils.dart';
import '../../core/internationalization.dart';
import '../../core/locales.g.dart';
import '../../core/structure.dart';

/// 创建或覆盖 main.dart 文件
/// 如果文件被创建/覆盖返回 true，如果用户选择不覆盖则返回 false
Future<bool> createMain() async {
  // 为 main.dart 创建文件模型
  var newFileModel = Structure.model('', 'init', false);

  var main = File('${newFileModel.path}main.dart');

  if (main.existsSync()) {
    /// 只有 create project 和 init 命令会调用此函数，
    /// 这两个函数都会初始化项目并覆盖文件

    // // 显示覆盖确认菜单
    // final menu = Menu(
    //   [LocaleKeys.options_yes.tr, LocaleKeys.options_no.tr],
    //   title: LocaleKeys.ask_lib_not_empty.tr,
    // );
    // final result = menu.choose();
    final commander = Commander(level: Level.verbose);
    final result = await commander.select(
      LocaleKeys.ask_lib_not_empty.tr,
      onDisplay: (value) => value,
      placeholder: '使用上下方向箭头选择值',
      defaultValue: LocaleKeys.options_yes.tr,
      options: [
        LocaleKeys.options_yes.tr,
        LocaleKeys.options_no.tr,
      ],
    );
    // result.index == 1
    if (result == LocaleKeys.options_no.tr) {
      // 用户选择不覆盖
      LogService.info(LocaleKeys.info_no_file_overwritten.tr);
      return false;
    }

    // 删除现有的 lib 目录
    await Directory('lib/').delete(recursive: true);
  }
  return true;
}
