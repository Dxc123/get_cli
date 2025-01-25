import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import '../../../common/utils/logger/my_logger.dart';
import '../../../core/internationalization.dart';
import '../../../core/locales.g.dart';
import '../../interface/command.dart';
import 'base/cleaner.dart';
import 'base/cleaning_command_executor.dart';
import 'base/cleaning_result.dart';
import 'base/directory_helper.dart';
import 'base/gaza_cleaner_exception.dart';

class CleanAllCommand extends Command {
  @override
  String get commandName => 'cleanAll';

  @override
  List<String> get acceptedFlags => ['-cAll'];

  @override
  Future<void> execute() async {
    Progress progress = MyLogger.logProgress('Cleaning all the projects please wait');
    try {
      Directory directory = Directory.current;
      List<String> filesToCheck = [
        'lib',
        'pubspec.yaml',
      ];
      CommandExecutor commandExecutor = CommandExecutor();
      DirectoryHelper directoryHelper = DirectoryHelper();

      Cleaner cleaner = Cleaner(
        directory: directory,
        commandExecutor: commandExecutor,
        filesToCheck: filesToCheck,
        directoryHelper: directoryHelper,
      );
      final cleaningStream = cleaner.clean();

      // *) Process individual CleaningResult objects from the stream
      List<CleaningResult> results = [];
      await for (var result in cleaningStream) {
        results.add(result);
        if (result.success && result.calculateDeletedFilesSize() > 0) {
          progress.update('Successfully cleaned ${path.basename(result.directory.path)} ✅ ');
        } else if (result.success && result.calculateDeletedFilesSize() == 0) {
          progress.update('${path.basename(result.directory.path)} is already clean ✨ ');
        } else {
          progress.update('Failed to clean ${result.directory.path} 😭 ');
        }
      }

      // *) Finish progress
      progress.complete('Process done successfully, check the results below below: 🔻 ');

      // *) leave empty space to differ between result and process
      MyLogger.logInfo(' ');

      // *) Format message to show it to user
      Map<String, dynamic> formattedMessage = formatProcessResultMessage(cleaningResults: results);

      // *) Show success messages
      if (formattedMessage['successMessage'] != null) {
        MyLogger.logSuccess('${formattedMessage['successMessage']}');
      }

      // *) Show success message
      if (formattedMessage['alreadyCleanedMessage'] != null) {
        MyLogger.logWarn('${formattedMessage['alreadyCleanedMessage']}');
      }

      // *) Show error messages
      if (formattedMessage['failuresMessage'] != null) {
        MyLogger.logError('${formattedMessage['failuresMessage']}');
      }

      exit(0);
    } on GazaCleanerException catch (error) {
      progress.fail(error.toString());
      exit(ExitCode.ioError.code);
    } catch (error) {
      progress.fail(error.toString());
      exit(ExitCode.usage.code);
    }
  }

  /// 打印将向用户显示的最终消息消息将包含所有已成功清理的项目，
  /// 以及从每个文件中删除了多少缓存的所有详细信息，
  /// 以及总数，它还包含所有无法清理的项目
  Map<String, dynamic> formatProcessResultMessage({
    required List<CleaningResult> cleaningResults,
  }) {
    final finalResult = <String, dynamic>{};
    final successMessage = StringBuffer();
    final failureMessage = StringBuffer();
    final alreadyCleanedMessage = StringBuffer();

    int totalCleanedFiles = cleaningResults.where((cr) => cr.success && cr.calculateDeletedFilesSize() > 0).length;
    int totalAlreadyCleanedFiles = cleaningResults.where((cr) => cr.success && cr.calculateDeletedFilesSize() == 0).length;
    int totalFailedToCleanFiles = cleaningResults.where((cr) => !cr.success).length;

    double totalSizeOfDeletedFiles = 0;
    cleaningResults.where((cr) => cr.success).forEach((cr) {
      if (cr.success) totalSizeOfDeletedFiles += cr.calculateDeletedFilesSize();
    });

    if (totalCleanedFiles > 0) {
      successMessage.writeln('--------------------------------------');
      successMessage.writeln('$totalCleanedFiles Projects successfully cleaned ✅🇵🇸 ');
      successMessage.writeln('${formatedSizeMessage(totalSizeOfDeletedFiles)} 🗑️ ');
      successMessage.writeln('--------------------------------------');

      finalResult['successMessage'] = successMessage.toString();
    }

    if (totalAlreadyCleanedFiles > 0) {
      alreadyCleanedMessage.writeln('--------------------------------------');
      alreadyCleanedMessage.writeln('$totalAlreadyCleanedFiles Projects were already clean ✨ ');
      alreadyCleanedMessage.writeln('--------------------------------------');

      finalResult['alreadyCleanedMessage'] = alreadyCleanedMessage.toString();
    }

    if (totalFailedToCleanFiles > 0) {
      failureMessage.writeln('--------------------------------------');
      failureMessage.writeln('$totalFailedToCleanFiles Projects failed to be cleaned ❌ ');
      failureMessage.writeln('--------------------------------------');

      finalResult['failuresMessage'] = failureMessage.toString();
    }

    finalResult['totalDeletedFilesSize'] = totalSizeOfDeletedFiles;

    return finalResult;
  }

  String formatedSizeMessage(double sizeInMB) {
    if (sizeInMB >= 1024) {
      double sizeInGB = sizeInMB / 1024;
      return 'Total deleted cache files = ${sizeInGB.toStringAsFixed(2)}GB';
    } else {
      return 'Total deleted cache files = ${sizeInMB.toStringAsFixed(2)}MB';
    }
  }

  @override
  String? get hint => Translation(LocaleKeys.hint_clean).tr;

  @override
  List<String> get alias => ['cleanAll'];

  @override
  bool validate() {
    super.validate();
    return true;
  }

  @override
  String get codeSample => 'get cleanAll';

  @override
  int get maxParameters => 0;
}
