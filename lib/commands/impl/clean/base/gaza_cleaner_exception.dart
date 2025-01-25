class GazaCleanerException implements Exception {
  final GazaCleanerExceptionType errorType;
  const GazaCleanerException({required this.errorType});

  @override
  String toString() {
    switch (errorType) {
      case GazaCleanerExceptionType.commandTimeout:
        return 'Took so much time to finish!';
      case GazaCleanerExceptionType.emptyDirectory:
        return 'The directory is empty!';
      case GazaCleanerExceptionType.noProjectsFound:
        return 'No projects found in the sub-directories.';
      case GazaCleanerExceptionType.calledInsideProjectItSelf:
        return 'Note: we cleaned this project but for better use run it on the root folder of your projects so it clean all the projects in one time!';
      case GazaCleanerExceptionType.unknownError:
        return 'unknownError';
      default:
        return 'unknownError.';
    }
  }
}

enum GazaCleanerExceptionType {
  // 命令未找到（未找到clean命令）
  commandNotFound,
  // 空目录
  emptyDirectory,
  // 在列出的目录中找不到项目
  noProjectsFound,
  // 用户在项目内部而不是项目目录中运行操作
  calledInsideProjectItSelf,
  // cleaning一些项目花了太多时间
  commandTimeout,
  // 其他类型的错误
  unknownError,
}
