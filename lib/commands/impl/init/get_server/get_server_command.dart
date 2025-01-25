import 'dart:io';

import 'package:path/path.dart';

import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../samples/impl/analysis_options.dart';
import '../../../../samples/impl/get_server/pubspec.dart';
import '../../../interface/command.dart';
import '../flutter/init_getxpattern.dart';

/// Get Server 项目初始化命令类
class InitGetServer extends Command {
  @override
  String get commandName => 'init';

  @override
  Future<void> execute() async {
    // bool canContinue = await createMain();
    // if (!canContinue) return;

    // 创建 pubspec.yaml 文件
    GetServerPubspecSample(basename(Directory.current.path)).create();

    // 创建代码分析配置文件
    AnalysisOptionsSample(
      include: 'include: package:pedantic/analysis_options.yaml',
    ).create();

    // 添加项目依赖
    // 添加 get_server 依赖
    await PubspecUtils.addDependencies('get_server', runPubGet: false);
    // 添加开发依赖 pedantic（代码分析工具）
    await PubspecUtils.addDependencies('pedantic', isDev: true, runPubGet: false);
    // 添加开发依赖 test（测试框架）
    await PubspecUtils.addDependencies('test', isDev: true, runPubGet: false);

    // 使用 GetX Pattern 初始化项目结构
    await createInitGetxPattern();
  }

  /// Generate the  structure initial for get server
  /// 生成 Get Server 的初始项目结构
  @override
  String get hint => 'Generate the  structure initial for get server';

  @override
  bool validate() {
    super.validate();

    return true;
  }

  @override
  String get codeSample => '';

  @override
  int get maxParameters => 0;
}
