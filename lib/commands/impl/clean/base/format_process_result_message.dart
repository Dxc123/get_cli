import 'cleaning_result.dart';

mixin ProcessMessageStarter {
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
}
