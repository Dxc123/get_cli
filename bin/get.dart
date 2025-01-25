import 'package:get_cli/exception_handler/exception_handler.dart';
import 'package:get_cli/functions/version/version_update.dart';
import 'package:get_cli/get_cli.dart';

/// CLI程序入口点
/// @param arguments 命令行参数列表
Future<void> main(List<String> arguments) async {
  // 创建性能计时器
  var time = Stopwatch();
  time.start();

  // 初始化CLI并查找对应命令
  final command = GetCli(arguments).findCommand();

  // 根据是否包含debug参数决定执行模式
  if (arguments.contains('--debug')) {
    // Debug模式：直接执行，不捕获异常
    if (command.validate()) {
      await command.execute().then((value) => checkForUpdate());
    }
  } else {
    // 正常模式：带异常处理的执行
    try {
      if (command.validate()) {
        await command.execute().then((value) => checkForUpdate());
      }
    } on Exception catch (e) {
      ExceptionHandler().handle(e);
    }
  }

  // 输出执行时间统计
  time.stop();
  LogService.info('Time: ${time.elapsed.inMilliseconds} Milliseconds');
}

/* 旧版本入口函数实现
void main(List<String> arguments) {
 Core core = Core();
  core
      .generate(arguments: List.from(arguments))
      .then((value) => checkForUpdate());
} */
