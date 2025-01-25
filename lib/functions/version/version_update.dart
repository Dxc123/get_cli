import 'dart:io';

import 'package:version/version.dart';

import '../../cli_config/cli_config.dart';
import '../../common/utils/logger/log_utils.dart';
import '../../common/utils/pub_dev/pub_dev_api.dart';
import '../../common/utils/pubspec/pubspec_lock.dart';
import '../../core/internationalization.dart';
import '../../core/locales.g.dart';
import 'check_dev_version.dart';
import 'print_get_cli.dart';

/// 检查CLI工具是否有新版本可用
/// 该函数会检查pub.dev上的最新版本，并与本地安装的版本进行比较
/// 这个文件的主要功能是：
// 1.版本检查机制
// 检查是否需要执行版本检查
// 避免重复检查（每天只检查一次）
// 跳过开发版本的检查
// 2.版本比较逻辑
// 获取 pub.dev 上的最新版本
// 获取本地安装的版本
// 使用 Version 类进行版本比较
// 3·更新提示
// 显示版本信息
// 提供更新命令
// 支持国际化的提示信息
// 4.异常处理
// 处理版本获取失败的情况
// 处理无法获取本地版本的情况
void checkForUpdate() async {
  // 检查今天是否已经检查过更新
  if (!CliConfig.updateIsCheckingToday()) {
    // 检查是否为开发版本
    if (!isDevVersion()) {
      // 从pub.dev获取最新版本
      await PubDevApi.getLatestVersionFromPackage('get_cli')
          .then((versionInPubDev) async {
        // 获取本地安装的版本
        await PubspecLock.getVersionCli(disableLog: true)
            .then((versionInstalled) async {
          // 如果无法获取已安装版本，退出程序
          if (versionInstalled == null) exit(2);

          // 解析版本号
          final v1 = Version.parse(versionInPubDev!);  // pub.dev上的版本
          final v2 = Version.parse(versionInstalled);  // 本地安装的版本

          // 比较版本号
          // compareTo返回值：
          // 1  表示需要更新
          // 0  表示版本相同
          // -1 表示本地版本更新
          final needsUpdate = v1.compareTo(v2);

          // 如果需要更新
          if (needsUpdate == 1) {
            // 显示更新提示信息
            LogService.info(Translation(
                    LocaleKeys.info_update_available.trArgs([versionInstalled]))
                .toString());

            // 打印CLI信息
            printGetCli();

            // 生成更新命令示例
            final String codeSample = LogService.code('get update');

            // 显示更新提示和命令
            LogService.info(
                '${LocaleKeys.info_update_available2.trArgs([
                      versionInPubDev
                    ])}${' $codeSample'}',
                false,
                true);
          }
        });
      });

      // 记录今天已经检查过更新
      CliConfig.setUpdateCheckToday();
    }
  }
}
