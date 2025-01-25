import 'dart:io';

import '../../../../common/utils/logger/log_utils.dart';
import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../core/structure.dart';
import '../../../../functions/create/create_list_directory.dart';
import '../../../../functions/create/create_main.dart';
import '../../../../samples/impl/arctekko/arc_main.dart';
import '../../../../samples/impl/arctekko/config_example.dart';
import '../../commads_export.dart';
import '../../install/install_get.dart';

/// Initialize project with CLEAN Architecture by Arktekko
/// 使用 Arktekko 的 CLEAN 架构初始化项目
Future<void> createInitKatekko() async {
  // Create or check main.dart file
  // 创建或检查 main.dart 文件
  var canContinue = await createMain();
  if (!canContinue) return;

  // Install Get package for Flutter projects
  // 为 Flutter 项目安装 Get 包
  if (!PubspecUtils.isServerProject) {
    await installGet();
  }

  // Define initial directory structure
  // 定义初始目录结构
  var initialDirs = [
    // Core interfaces
    // 核心接口
    Directory(Structure.replaceAsExpected(path: 'lib/domain/core/interfaces/')),

    // Navigation bindings
    // 导航绑定
    Directory(Structure.replaceAsExpected(
        path: 'lib/infrastructure/navigation/bindings/controllers/')),
    Directory(Structure.replaceAsExpected(
        path: 'lib/infrastructure/navigation/bindings/domains/')),

    // Data access layer
    // 数据访问层
    Directory(
        Structure.replaceAsExpected(path: 'lib/infrastructure/dal/daos/')),
    Directory(
        Structure.replaceAsExpected(path: 'lib/infrastructure/dal/services/')),

    // Presentation and theme
    // 表现层和主题
    Directory(Structure.replaceAsExpected(path: 'lib/presentation/')),
    Directory(Structure.replaceAsExpected(path: 'lib/infrastructure/theme/')),
  ];

  // Create initial files
  // 创建初始文件
  ArcMainSample().create();
  ConfigExampleSample().create();

  // Create initial screen
  // 创建初始屏幕
  await Future.wait([
    CreateScreenCommand().execute(),
  ]);

  // Create directory structure
  // 创建目录结构
  createListDirectory(initialDirs);

  // Show success message
  // 显示成功消息
  LogService.success(Translation(LocaleKeys.sucess_clean_Pattern_generated).tr);
}
