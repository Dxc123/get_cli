import 'dart:io';

import '../../functions/create/create_single_file.dart';

/// [Sample] is the Base class in which the files for each command
/// will be built.
///
/// Sample 是文件生成的基类，用于构建各个命令的文件模板
/// 提供了文件创建的基本功能和属性
abstract class Sample {
  /// Custom content that can be used instead of the default template
  /// 自定义内容，当需要使用自定义模板而不是默认模板时使用
  String customContent = '';

  /// The path where the sample file will be added
  /// 文件创建路径，指定生成的文件将被添加到的位置
  String path;

  /// If the file is found in the path, it can be ignored or
  /// overwritten. If overrite = false, the source file will not be changed.
  /// The default is [false].
  ///
  /// 文件覆盖标志
  /// 如果路径中已存在文件：
  /// - true: 覆盖现有文件
  /// - false: 保持源文件不变（默认值）
  bool overwrite;

  /// Store the content that will be written to the file in a String or
  /// Future <String> in that variable. It is used to fill the file created
  /// by path.
  ///
  /// 文件内容
  /// 存储将写入文件的内容，可以是字符串或 Future<String>
  /// 用于填充在 path 中创建的文件
  String get content;

  /// Constructor for Sample class
  /// [path] - file path
  /// [overwrite] - whether to overwrite existing file, defaults to false
  ///
  /// 构造函数
  /// [path] 文件路径
  /// [overwrite] 是否覆盖现有文件，默认为 false
  Sample(this.path, {this.overwrite = false});

  /// This function will create the file in [path] with the
  /// content of [content].
  ///
  /// 创建文件
  /// 在指定的 [path] 创建文件，并写入 [content] 或 [customContent]
  /// [skipFormatter] 是否跳过格式化，默认为 false
  /// 返回创建的文件对象
  File create({bool skipFormatter = false}) {
    return writeFile(
      path,
      customContent.isNotEmpty ? customContent : content,
      overwrite: overwrite,
      skipFormatter: skipFormatter,
      useRelativeImport: true,
    );
  }
}
