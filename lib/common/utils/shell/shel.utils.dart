import 'dart:io';

import 'package:process_run/shell_run.dart'; //提供执行 shell 命令的功能。

import '../../../core/generator.dart';
import '../../../core/internationalization.dart';
import '../../../core/locales.g.dart';
import '../logger/log_utils.dart';
import '../pub_dev/pub_dev_api.dart';
import '../pubspec/pubspec_lock.dart';

// ShellUtils: 提供一系列用于执行shell命令行操作的静态方法。
class ShellUtils {
  // 清理当前项目
  static Future<void> clean() async {
    LogService.info('Running `flutter clean`…');
    await run('flutter clean', verbose: true);
  }
  //dart fix --apply: 修复当前目录下的 Dart 文件。
  static Future<void> fix() async {
    LogService.info('Running `dart fix --apply`…');
    await run('dart fix --apply', verbose: true);
  }

  //格式化当前目录下的所有 Dart 文件：
  static Future<void> format() async {
    LogService.info('Running `dart format .`…');
    await run('dart format .', verbose: true);
  }

  // 执行 dart pub get 命令以获取依赖包。
  static Future<void> pubGet() async {
    LogService.info('Running `flutter pub get` …');
    // run函数执行命令，并设置 verbose: true 以输出详细信息。
    await run('dart pub get', verbose: true);
  }

  // addPackage: 添加指定的包到项目中。
  static Future<void> addPackage(String package) async {
    LogService.info('Adding package $package …');
    await run('dart pub add $package', verbose: true);
  }

  // removePackage: 移除指定的包。
  static Future<void> removePackage(String package) async {
    LogService.info('Removing package $package …');
    await run('dart pub remove $package', verbose: true);
  }

  // flutterCreate: 创建一个新的 Flutter 项目。
  static Future<void> flutterCreate(
    String path,
    String? org,
    String iosLang,
    String androidLang,
  ) async {
    // 使用 LogService.info 记录正在创建的项目信息。
    LogService.info('Running `flutter create $path` …');
    // 使用 run 函数执行 flutter create 命令，并设置相关参数（如 iOS 和 Android 的语言、组织等），并设置 verbose: true 以输出详细信息。
    await run(
        'flutter create --no-pub -i $iosLang -a $androidLang --org $org'
        ' "$path"',
        verbose: true);
  }

  // update: 更新 get_cli 工具。
  static Future<void> update([bool isGit = false, bool forceUpdate = false]) async {
    // 检查命令行参数是否包含 --git 和 -f，分别设置 isGit 和 forceUpdate。
    isGit = GetCli.arguments.contains('--git');
    forceUpdate = GetCli.arguments.contains('-f');
    // 如果既不是从 Git 更新也不是强制更新，则检查当前安装版本是否已经是最新版本。如果是，则直接返回提示信息。
    if (!isGit && !forceUpdate) {
      var versionInPubDev = await PubDevApi.getLatestVersionFromPackage('get_cli');

      var versionInstalled = await PubspecLock.getVersionCli(disableLog: true);

      if (versionInstalled == versionInPubDev) {
        return LogService.info(Translation(LocaleKeys.info_cli_last_version_already_installed.tr).toString());
      }
    }

    LogService.info('Upgrading get_cli …');
    // 尝试执行更新命令：
    try {
      // 如果是在 Flutter 环境下，且指定了 --git 参数，则使用 Git 源进行更新；否则使用默认源更新。
      if (Platform.script.path.contains('flutter')) {
        if (isGit) {
          await run('flutter pub global activate -sgit https://github.com/jonataslaw/get_cli/', verbose: true);
        } else {
          await run('flutter pub global activate get_cli', verbose: true);
        }
      } else {
        if (isGit) {
          await run('flutter pub global activate -sgit https://github.com/jonataslaw/get_cli/', verbose: true);
        } else {
          await run('flutter pub global activate get_cli', verbose: true);
        }
      }
      return LogService.success(LocaleKeys.sucess_update_cli.tr);
    } on Exception catch (err) {
      LogService.info(err.toString());
      return LogService.error(LocaleKeys.error_update_cli.tr);
    }
  }
}
