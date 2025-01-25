import '../../interface/sample_interface.dart';

class GetLogUntilSample extends Sample {
  final bool? isServer;
  final String? name;
  GetLogUntilSample({this.isServer,this.name}) : super('lib/${name}_log_until.dart', overwrite: true);

  String get _flutterMain => '''import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AppLogTool extends Logger {
  static final Logger _logger = Logger(
    printer: PrefixPrinter(
      PrettyPrinter(
          methodCount: 1, //要展示的方法调用的数量
          stackTraceBeginIndex: 5,
          errorMethodCount: 8, // 如果提供了 stacktrace，方法调用的数量
          lineLength: 120, //输出的宽度
          colors: true, //  是否带颜色输出日志信息
          printEmojis: true, //  为每个日志信息打印颜文字
          dateTimeFormat: DateTimeFormat.dateAndTime //  是否每一个日志打印包含一个时间戳
          ), //直接打印方法位置
    ),
    output: AppLogConsoleOutput(), //它将所有内容发送到系统控制台。
  );


  static void debug(Object message) {
    _logger.d(message);

  }
  
}
class AppLogConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    event.lines.forEach(printWrapped);
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  // This works too.
  void printWrapped2(String text) => debugPrint(text, wrapWidth: 1024);
}
  ''';

  String get _serverMain => '''import 'package:get_server/get_server.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(GetServer(
    getPages: AppPages.routes,
  ));
}
  ''';

  @override
  String get content => isServer! ? _serverMain : _flutterMain;
}
