import 'dart:io';

import '../../../../common/utils/logger/log_utils.dart';
import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../core/structure.dart';
import '../../../../functions/create/create_list_directory.dart';
import '../../../../functions/create/create_main.dart';
import '../../../../samples/impl/getx_pattern/get_main.dart';
import '../../commads_export.dart';
import '../../install/install_get.dart';

/// 使用 GetX Pattern 初始化项目
Future<void> createInitGetxPattern({String name = 'Flutter'}) async {
  // 创建或检查 main.dart 文件
  var canContinue = await createMain();
  if (!canContinue) return;

  // 检查是否为服务器项目，如果不是则安装 Get 包
  var isServerProject = PubspecUtils.isServerProject;
  if (!isServerProject) {
    await installGet();
  }

  List nameList = name.split("");
  // 前缀
  final namePrefix = nameList.first.toLowerCase() + nameList[1].toLowerCase();

  // 定义初始目录结构
  var initialDirs = [
    // 数据层目录
    // Directory(Structure.replaceAsExpected(path: 'lib/app/data/')),
    Directory(Structure.replaceAsExpected(path: 'lib/app/data/${namePrefix}_api/')),
    Directory(Structure.replaceAsExpected(path: 'lib/app/data/${namePrefix}_components/')),
    Directory(Structure.replaceAsExpected(path: 'lib/app/data/${namePrefix}_extension/')),
    Directory(Structure.replaceAsExpected(path: 'lib/app/data/${namePrefix}_models/')),
    Directory(Structure.replaceAsExpected(path: 'lib/app/data/${namePrefix}_services/')),
    Directory(Structure.replaceAsExpected(path: 'lib/app/data/${namePrefix}_style/')),
    Directory(Structure.replaceAsExpected(path: 'lib/app/data/${namePrefix}_utils/')),
    Directory(Structure.replaceAsExpected(path: 'lib/app/data/${namePrefix}_values/')),
    Directory(Structure.replaceAsExpected(path: 'lib/app/data/${namePrefix}_widgets/')),
  ];

  // 使用 GetX pattern 创建主文件
  GetXMainSample(isServer: isServerProject).create();

  // 创建初始页面
  await Future.wait([
    CreatePageCommand().execute(),
  ]);

  // 创建目录结构
  createListDirectory(initialDirs);

  // 显示成功消息
  LogService.success(Translation(LocaleKeys.sucess_getx_pattern_generated));
}
