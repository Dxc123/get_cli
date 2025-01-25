import 'dart:io';

import 'package:commander_ui/commander_ui.dart';
import 'package:dcli/dcli.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';

import '../../../../common/menu/menu.dart';
import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../common/utils/shell/shel.utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../core/structure.dart';
import '../../../../samples/impl/analysis_options.dart';
import '../../../interface/command.dart';
import '../../init/flutter/init.dart';
import '../../init/get_server/get_server_command.dart';

/// 创建项目命令类
/// 用于创建新的 Flutter 项目或 Get Server 项目
class CreateProjectCommand extends Command {
  @override
  String get commandName => 'project';

  /// 执行项目创建命令
  @override
  Future<void> execute() async {
    // // 显示项目类型选择菜单
    // final menu = Menu([
    //   'Flutter Project',
    //   'Get Server',
    // ], title: '选择要创建的项目类型 ?');
    // final result = menu.choose();

    final commander = Commander(level: Level.verbose);
    final result = await commander.select(
      '选择要创建的项目类型?',
      onDisplay: (value) => value,
      placeholder: '使用上下方向箭头选择值',
      defaultValue: 'Flutter Project',
      options: [
        'Flutter Project',
        'Get Server',
      ],
    );
    // print(result);

    // 获取项目名称
    String? nameProject = name;
    if (name == '.') {
      nameProject = ask(LocaleKeys.ask_name_to_project.tr);
    }

    // 创建项目目录
    var path = Structure.replaceAsExpected(path: Directory.current.path + p.separator + nameProject.snakeCase);
    await Directory(path).create(recursive: true);

    // 切换到项目目录
    Directory.current = path;

    // 创建 Flutter 项目  //result.index == 0
    if (result == "Flutter Project") {
      // 获取公司域名
      var org = ask(
        '${LocaleKeys.ask_company_domain.tr} \x1B[33m '
        '${LocaleKeys.example.tr} com.yourcompany \x1B[0m',
      );

      // // 选择 iOS 开发语言
      // final iosLangMenu = Menu(['Swift', 'Objective-C'], title: LocaleKeys.ask_ios_lang.tr);
      // final iosResult = iosLangMenu.choose();
      // var iosLang = iosResult.index == 0 ? 'swift' : 'objc';

      final iosLangMenu = Commander(level: Level.verbose);
      final iosResult = await iosLangMenu.select(
        LocaleKeys.ask_ios_lang.tr,
        onDisplay: (value) => value,
        placeholder: '使用上下方向箭头选择值',
        defaultValue: 'Swift',
        options: [
          'Swift',
          'Objective-C',
        ],
      );
      var iosLang = iosResult == "Swift" ? 'swift' : 'objc';

      // // 选择 Android 开发语言
      // final androidLangMenu = Menu(['Kotlin', 'Java'], title: LocaleKeys.ask_android_lang.tr);
      // final androidResult = androidLangMenu.choose();
      // var androidLang = androidResult.index == 0 ? 'kotlin' : 'java';

      final androidLangMenu = Commander(level: Level.verbose);
      final androidResult = await androidLangMenu.select(
        LocaleKeys.ask_android_lang.tr,
        onDisplay: (value) => value,
        placeholder: '使用上下方向箭头选择值',
        defaultValue: 'kotlin',
        options: [
          'kotlin',
          'Java',
        ],
      );
      var androidLang = androidResult == "kotlin" ? 'kotlin' : 'java';

      // // 是否使用代码检查工具
      // final linterMenu = Menu([
      //   'Yes',
      //   'No',
      // ], title: LocaleKeys.ask_use_linter.tr);
      // final linterResult = linterMenu.choose();

      final linterMenu = Commander(level: Level.verbose);
      final linterResult = await linterMenu.select(
        LocaleKeys.ask_use_linter.tr,
        onDisplay: (value) => value,
        placeholder: '使用上下方向箭头选择值',
        defaultValue: 'Yes',
        options: [
          'Yes',
          'No',
        ],
      );
      // 创建 Flutter 项目
      await ShellUtils.flutterCreate(path, org, iosLang, androidLang);

      // 清空测试文件
      File('test/widget_test.dart').writeAsStringSync('');

      // 配置代码检查工具 linterResult.index
      switch (linterResult == "Yes" ? 0 : 1) {
        case 0:
          if (PubspecUtils.isServerProject) {
            // 服务端项目使用 lints
            await PubspecUtils.addDependencies('lints', isDev: true, runPubGet: true);
            AnalysisOptionsSample(include: 'include: package:lints/recommended.yaml').create();
          } else {
            // Flutter 项目使用 flutter_lints
            await PubspecUtils.addDependencies('flutter_lints', isDev: true, runPubGet: true);
            AnalysisOptionsSample(include: 'include: package:flutter_lints/flutter.yaml').create();
          }
          break;

        default:
          // 不使用代码检查工具，创建默认配置
          AnalysisOptionsSample().create();
      }

      // 初始化 Flutter 项目
      await InitCommand().execute();
    } else {
      // 初始化 Get Server 项目
      await InitGetServer().execute();
    }
  }

  @override
  String? get hint => LocaleKeys.hint_create_project.tr;

  @override
  bool validate() {
    return true;
  }

  @override
  String get codeSample => 'get create project';

  @override
  int get maxParameters => 0;
}
