import 'dart:io';

import 'package:commander_ui/commander_ui.dart';
import 'package:recase/recase.dart';

import '../../../../common/menu/menu.dart';
import '../../../../common/utils/pubspec/pubspec_utils.dart';
import '../../../../core/generator.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../../core/structure.dart';
import '../../../../functions/create/create_single_file.dart';
import '../../../../functions/exports_files/add_export.dart';
import '../../../../functions/routes/arc_add_route.dart';
import '../../../../samples/impl/get_binding.dart';
import '../../../../samples/impl/get_controller.dart';
import '../../../../samples/impl/get_view.dart';
import '../../../../samples/impl/get_view_stf.dart';
import '../../../interface/command.dart';

/// 创建屏幕命令类
/// 用于生成一个完整的屏幕，包含 Controller、Screen 和 Binding 文件
/// 遵循 Clean Architecture 架构模式
class CreateScreenCommand extends Command {
  @override
  String get commandName => 'screen';

  /// 执行屏幕创建命令
  /// 如果是项目创建过程中的屏幕创建，默认创建 'home' 屏幕
  @override
  Future<void> execute() async {
    // 检查是否是项目创建过程
    var isProject = false;
    if (GetCli.arguments[0] == 'create') {
      isProject = GetCli.arguments[1].split(':').first == 'project';
    }
    var name = this.name;
    if (name.isEmpty || isProject) {
      name = 'home';
    }

    // 创建文件模型并处理路径
    var newFileModel = Structure.model(name, 'screen', true, on: onCommand, folderName: name);
    var pathSplit = Structure.safeSplitPath(newFileModel.path!);

    pathSplit.removeLast();
    var path = pathSplit.join('/');
    path = Structure.replaceAsExpected(path: path);

    // 检查目录是否已存在
    if (Directory(path).existsSync()) {
      // // 显示覆盖确认菜单
      // final menu = Menu([
      //   LocaleKeys.options_yes.tr,
      //   LocaleKeys.options_no.tr,
      // ], title: LocaleKeys.ask_existing_page.trArgs([name]).toString());
      // final result = menu.choose();
      final commander = Commander(level: Level.verbose);
      final result = await commander.select(
        LocaleKeys.ask_existing_page.trArgs([name]).toString(),
        onDisplay: (value) => value,
        placeholder: '使用上下方向箭头选择值',
        defaultValue: 'GetX Pattern (by Kauê)',
        options: [
          LocaleKeys.options_yes.tr,
          LocaleKeys.options_no.tr,
        ],
      );
      // result.index == 0
      if (result == LocaleKeys.options_yes.tr) {
        // 选择覆盖现有文件
        _writeFiles(path, name, overwrite: true);
      }
    } else {
      // 创建新目录并生成文件
      Directory(path).createSync(recursive: true);
      _writeFiles(path, name);
    }
  }

  @override
  String? get hint => Translation(LocaleKeys.hint_create_screen).tr;

  @override
  bool validate() {
    return true;
  }

  /// 创建屏幕相关文件
  /// [path] 文件创建路径
  /// [name] 屏幕名称
  /// [overwrite] 是否覆盖现有文件
  void _writeFiles(String path, String name, {bool overwrite = false}) {
    var isServer = PubspecUtils.isServerProject;

    // 创建控制器文件
    var controller = handleFileCreate(name, 'controller', path, true, ControllerSample('', name, isServer), 'controllers', '.');

    var controllerImport = Structure.pathToDirImport(controller.path);

    // 创建屏幕视图文件
    var view = handleFileCreate(
        name,
        'screen',
        path,
        false,
        // GetViewSample(
        //   '',
        //   '${name.pascalCase}Screen',
        //   '${name.pascalCase}Controller',
        //   controllerImport,
        //   isServer,
        // ),
        GetViewStfSample(
          '',
          '${name.pascalCase}Screen',
          '${name.pascalCase}Controller',
          controllerImport,
          isServer,
        ),
        '',
        '.');

    // 创建绑定文件
    var binding = handleFileCreate(
        name,
        'controller.binding',
        '',
        true,
        BindingSample(
          '',
          name,
          '${name.pascalCase}ControllerBinding',
          controllerImport,
          isServer,
        ),
        'controllers',
        '.');

    // 添加视图导出语句
    var exportView = 'package:${PubspecUtils.projectName}/'
        '${Structure.pathToDirImport(view.path)}';
    addExport('lib/presentation/screens.dart', "export '$exportView';");

    // 添加绑定导出语句
    addExport('lib/infrastructure/navigation/bindings/controllers/controllers_bindings.dart', "export 'package:${PubspecUtils.projectName}/${Structure.pathToDirImport(binding.path)}'; ");

    // 添加路由配置
    arcAddRoute(name);
  }

  @override
  String get codeSample => 'get create screen:name';

  @override
  int get maxParameters => 0;
}
