import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';

/// CLI配置类，用于管理命令行工具的配置信息
class CliConfig {
  /// 日期格式化工具，用于格式化日期为 'yyyy-MM-dd' 格式
  static final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  /// 获取配置文件
  /// 如果配置文件不存在，则创建一个新的配置文件
  /// 返回配置文件的 File 对象
  static File getFileConfig() {
    var scriptFile = Platform.script.toFilePath();
    var path = join(dirname(scriptFile), '.get_cli.yaml');
    var configFile = File(path);
    if (!configFile.existsSync()) {
      configFile.createSync(recursive: true);
    }
    return configFile;
  }

  /// 设置今天为更新检查日期
  /// 将当前日期写入配置文件中的 last_update_check 字段
  static void setUpdateCheckToday() {
    final now = DateTime.now();

    final formatted = _formatter.format(now);
    var configFile = getFileConfig();
    var lines = configFile.readAsLinesSync();
    var lastUpdateIndex = lines.indexWhere(
      (element) => element.startsWith('last_update_check:'),
    );
    if (lastUpdateIndex != -1) {
      lines.removeAt(lastUpdateIndex);
    }

    lines.add('last_update_check: $formatted');
    configFile.writeAsStringSync(lines.join('\n'));
  }

  /// 检查今天是否已经检查过更新
  /// 通过读取配置文件中的 last_update_check 字段来判断
  /// 返回 true 表示今天已经检查过更新，false 表示今天还未检查更新
  static bool updateIsCheckingToday() {
    var configFile = getFileConfig();

    var lines = configFile.readAsLinesSync();
    var lastUpdateIndex = lines.indexWhere(
      (element) => element.startsWith('last_update_check:'),
    );
    if (lines.isEmpty || lastUpdateIndex == -1) {
      return false;
    }
    var dateLatsUpdate = lines[lastUpdateIndex].split(':').last.trim();
    var now = _formatter.parse(_formatter.format(DateTime.now()));

    return _formatter.parse(dateLatsUpdate) == now;
  }
}
