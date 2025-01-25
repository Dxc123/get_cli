import 'dart:io';

import 'package:commander_ui/commander_ui.dart';
import 'package:dcli/dcli.dart';
import 'package:get_cli_pro/samples/impl/get_view_stf.dart';
import 'package:recase/recase.dart';

import '../../../../common/menu/menu.dart';
import '../../../../common/utils/logger/log_utils.dart';
import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../core/generator.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../core/structure.dart';
import '../../../../functions/create/create_single_file.dart';
import '../../../../functions/routes/get_add_route.dart';
import '../../../../samples/impl/get_binding.dart';
import '../../../../samples/impl/get_controller.dart';
import '../../../../samples/impl/get_view.dart';
import '../../../interface/command.dart';

/// 创建页面命令类
/// 用于生成一个完整的页面，包含 Binding、Controller 和 View 文件
class CreatePageCommand extends Command {
  @override
  String get commandName => 'page';

  /// 命令的别名列表
  /// 可以使用 'module'、'-p' 或 '-m' 来调用此命令
  @override
  List<String> get alias => ['module', '-p', '-m'];

  /// 执行页面创建命令
  /// 如果是项目创建过程中的页面创建，默认创建 'home' 页面
  @override
  Future<void> execute() async {
    var isProject = false;
    if (GetCli.arguments[0] == 'create' || GetCli.arguments[0] == '-c') {
      isProject = GetCli.arguments[1].split(':').first == 'project';
    }
    var name = this.name;
    if (name.isEmpty) {
      // || isProject
      name = 'home';
    } else {
      if (isProject) {
        List nameList = name.split("");
        // 前缀
        final namePrefix = (nameList.first + nameList[1]).toLowerCase();
        name = '${namePrefix}_home';
      }
    }
    checkForAlreadyExists(name);
  }

  @override
  String? get hint => LocaleKeys.hint_create_page.tr;

  /// 检查页面是否已存在
  /// [name] 页面名称
  /// 如果页面已存在，提供三个选项：
  /// 1. 覆盖现有页面
  /// 2. 取消操作
  /// 3. 重命名页面
  void checkForAlreadyExists(String? name) async {
    var newFileModel = Structure.model(name, 'page', true, on: onCommand, folderName: name);
    var pathSplit = Structure.safeSplitPath(newFileModel.path!);

    pathSplit.removeLast();
    var path = pathSplit.join('/');
    path = Structure.replaceAsExpected(path: path);

    if (Directory(path).existsSync()) {
      // // 显示选项菜单
      // final menu = Menu(
      //   [
      //     LocaleKeys.options_yes.tr,
      //     LocaleKeys.options_no.tr,
      //     LocaleKeys.options_rename.tr,
      //   ],
      //   title: Translation(LocaleKeys.ask_existing_page.trArgs([name])).toString(),
      // );
      // final result = menu.choose();

      final commander = Commander(level: Level.verbose);
      final result = await commander.select(
        Translation(LocaleKeys.ask_existing_page.trArgs([name])).toString(),
        onDisplay: (value) => value,
        placeholder: '使用上下方向箭头选择值',
        defaultValue: LocaleKeys.options_yes.tr,
        options: [
          LocaleKeys.options_yes.tr,
          LocaleKeys.options_no.tr,
          LocaleKeys.options_rename.tr,
        ],
      );
      // result.index == 0
      if (result == LocaleKeys.options_yes.tr) {
        // 选择覆盖
        _writeFiles(path, name!, overwrite: true);
      } else if (result == LocaleKeys.options_rename.tr) {
        // result.index == 2
        // 选择重命名
        var name = ask(LocaleKeys.ask_new_page_name.tr);
        checkForAlreadyExists(name.trim().snakeCase);
      }
    } else {
      // 创建新目录并写入文件
      Directory(path).createSync(recursive: true);
      _writeFiles(path, name!, overwrite: false);
    }
  }

  /// 创建页面相关文件
  /// [path] 文件创建路径
  /// [name] 页面名称
  /// [overwrite] 是否覆盖现有文件
  void _writeFiles(String path, String name, {bool overwrite = false}) {
    var isServer = PubspecUtils.isServerProject;
    var extraFolder = PubspecUtils.extraFolder ?? true;

    // 创建控制器文件
    var controllerFile = handleFileCreate(
      name,
      'controller',
      path,
      extraFolder,
      ControllerSample(
        '',
        name,
        isServer,
        overwrite: overwrite,
      ),
      'controllers',
    );

    var controllerDir = Structure.pathToDirImport(controllerFile.path);

    // 创建视图文件
    var viewFile = handleFileCreate(
      name,
      'view',
      path,
      extraFolder,
      // GetViewSample(
      //   '',
      //   '${name.pascalCase}View',
      //   '${name.pascalCase}Controller',
      //   controllerDir,
      //   isServer,
      //   overwrite: overwrite,
      // ),
      GetViewStfSample(
        '',
        '${name.pascalCase}View',
        '${name.pascalCase}Controller',
        controllerDir,
        isServer,
        overwrite: overwrite,
      ),
      'views',
    );

    // 创建绑定文件
    var bindingFile = handleFileCreate(
      name,
      'binding',
      path,
      extraFolder,
      BindingSample(
        '',
        name,
        '${name.pascalCase}Binding',
        controllerDir,
        isServer,
        overwrite: overwrite,
      ),
      'bindings',
    );

    // 添加路由配置
    addRoute(
      name,
      Structure.pathToDirImport(bindingFile.path),
      Structure.pathToDirImport(viewFile.path),
    );

    // 显示成功消息
    LogService.success(LocaleKeys.sucess_page_create.trArgs([name.pascalCase]));
  }

  @override
  String get codeSample => 'get create page:product';

  @override
  int get maxParameters => 0;
}
