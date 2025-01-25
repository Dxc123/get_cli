import 'package:http/http.dart';
import 'package:recase/recase.dart';

import '../../core/generator.dart';

//定义了一个 Dart 的混合类，用于处理命令行参数。
mixin ArgsMixin {
  /// 存储从命令行传递的所有参数。
  final List<String> _args = GetCli.arguments;

  /// all arguments
  ///
  /// example run
  /// `get create page:product on home`
  ///
  /// ```
  /// print(args); // [page:product]
  /// ```
  List<String> args = _getArgs();

  /// all flags
  ///
  /// example run
  /// `get sort . --skipRename --relative`
  ///
  /// ```
  /// print(flags); // [--skipRename, --relative]
  /// ```
  List<String> flags = _getFlags();

  /// return parameter `on`
  ///
  /// example run
  /// `get create page:product on home`
  ///
  /// ```
  /// print(onCommand); // home
  /// ```
  String get onCommand {
    return _getArg('on');
  }

  /// return parameter `with`
  ///
  /// example run
  /// `get g model with assets/model/user.json`
  ///
  /// ```
  /// print(withArgument); //  assets/model/user.json
  /// ```
  String get withArgument {
    return _getArg('with');
  }

  /// return parameter `from`
  ///
  /// example run
  /// `get g model from 'YOUR_MODEL_URL'`
  ///
  /// ```
  /// print(fromArgument); // 'YOUR_MODEL_URL'
  /// ```
  String get fromArgument {
    return _getArg('from');
  }

  /// return parameter `name`
  ///
  /// example run
  /// `get create page:product on home`
  ///
  /// ```
  /// print(name); // product
  /// ```
  String get name {
    var args = List.of(_args);
    _removeDefaultArgs(args);
    if (args.length > 1) {
      if (args[0] == 'create' || args[0] == '-c') {
        var arg = args[1];
        var split = arg.split(':');
        var type = split.first;
        var name = split.last;

        if (name == type) {
          if (args.length > 2) {
            name = args[2];
          } else {
            name = '';
          }
        }
        if (type == 'project') {
          return name.isEmpty ? '.' : name.snakeCase;
        }
        return name;
      }
    }
    return '';
  }

  /// return [true] if conatains flags
  ///
  /// example run
  /// `get sort . --skipRename`
  ///
  /// ```
  /// print(containsArg('--skipRename')); // true
  /// print(containsArg('--relative')); // false
  /// ```
  bool containsArg(String flag) {
    return _args.contains(flag);
  }
}

/// 获取所有非标志（flag）参数
List<String> _getArgs() {
  var args = List.of(GetCli.arguments);
  _removeDefaultArgs(args);
  args.removeWhere((element) => element.startsWith('-'));
  return args;
}

/// 移除默认参数（如 `on`, `from`, `with`）及其对应的值。
void _removeDefaultArgs(List<String> args) {
  var defaultArgs = ['on', 'from', 'with'];

  for (var arg in defaultArgs) {
    var indexArg = args.indexWhere((element) => (element == arg));
    if (indexArg != -1 && indexArg < args.length) {
      args.removeAt(indexArg);
      if (indexArg < args.length) {
        args.removeAt(indexArg);
      }
    }
  }
}

/// 获取所有标志（flag）参数。
List<String> _getFlags() {
  var args = List.of(GetCli.arguments);
  var flags = args.where((element) {
    return element.startsWith('-') && element != '--debug';
  }).toList();

  return flags;
}

/// 获取指定参数在参数列表中的索引。
int _getIndexArg(String arg) {
  return GetCli.arguments.indexWhere((element) => element == arg);
}

/// 获取指定参数的值。
String _getArg(String arg) {
  var index = _getIndexArg(arg);
  if (index != -1) {
    if (index + 1 < GetCli.arguments.length) {
      index++;
      return GetCli.arguments[index];
    } else {
      throw ClientException("the '$arg' argument is empty");
    }
  }

  return '';
}
