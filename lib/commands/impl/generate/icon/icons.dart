import '../../../../common/utils/logger/log_utils.dart';
import '../../../../core/internationalization.dart';
import '../../../../core/locales.g.dart';
import '../../../interface/command.dart';
import 'icon_gen.dart';

//图标字体代码生成器
class GenerateIconsCommand extends Command {
  @override
  String get commandName => 'icons';

  @override
  String? get hint => Translation(LocaleKeys.hint_generate_icons).tr;

  @override
  bool validate() {
    return true;
  }

  @override
  Future<void> execute() async {
    // final inputPath = args.isNotEmpty ? args.first : 'assets/icons_download.zip';
    //
    // if (!await Directory(inputPath).exists()) {
    //   LogService.error(LocaleKeys.error_nonexistent_directory.trArgs([inputPath]));
    //   return;
    // }
    await const IconGen().gen();
  }

  @override
  String? get codeSample => LogService.code('get generate icons assets/download.zip \n'
      'get generate icons assets/download.zip');

  @override
  int get maxParameters => 1;
}
