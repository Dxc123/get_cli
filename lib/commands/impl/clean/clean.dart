import '../../../common/utils/shell/shel.utils.dart';
import '../../../core/internationalization.dart';
import '../../../core/locales.g.dart';
import '../../interface/command.dart';

class CleanCommand extends Command {
  @override
  String get commandName => 'clean';
  @override
  List<String> get acceptedFlags => ['-c'];

  @override
  Future<void> execute() async {
    await ShellUtils.clean();
  }

  @override
  String? get hint => Translation(LocaleKeys.hint_clean).tr;

  @override
  List<String> get alias => ['clean'];

  @override
  bool validate() {
    super.validate();
    return true;
  }

  @override
  String get codeSample => 'get clean';

  @override
  int get maxParameters => 0;
}
