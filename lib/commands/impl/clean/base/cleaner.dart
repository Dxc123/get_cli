import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'cleaning_command_executor.dart';
import 'cleaning_result.dart';
import 'directory_helper.dart';
import 'gaza_cleaner_exception.dart';

class Cleaner {
  Directory directory;
  List<String> filesToCheck;
  DirectoryHelper directoryHelper;
  CommandExecutor commandExecutor;

  Cleaner({
    required this.directory,
    required this.filesToCheck,
    required this.directoryHelper,
    required this.commandExecutor,
  });

  GazaCleanerExceptionType? getErrorType(int exitCode) {
    if (exitCode == 0) {
      return null;
    } else if (exitCode == -2) {
      return GazaCleanerExceptionType.commandTimeout;
    } else {
      return GazaCleanerExceptionType.unknownError;
    }
  }

  Stream<CleaningResult> clean() async* {
    // 检查当前目录是否是一个flutter项目
    bool isTheGivenDirectoryProject = await validateFlutterProject(
      directory: directory,
      filesToCheck: filesToCheck.map((file) => File(path.join(directory.path, file))).toList(),
    );

    // 列出所有子目录
    List<Directory> directories = await directoryHelper.getAllSubDirectories(directory: directory);

    // 处理-项目中的清除操作
    if (directories.isEmpty && isTheGivenDirectoryProject) {
      await commandExecutor.runCleaning(
        directoryPath: directory.path,
      );
      throw GazaCleanerException(
        errorType: GazaCleanerExceptionType.calledInsideProjectItSelf,
      );
    }

    // 处理-没有找到项目
    if (directories.isEmpty && !isTheGivenDirectoryProject) {
      throw GazaCleanerException(
        errorType: GazaCleanerExceptionType.noProjectsFound,
      );
    }

    // 清理目录中的项目（如果适用）
    if (directories.isNotEmpty && !isTheGivenDirectoryProject) {
      await commandExecutor.runCleaning(
        directoryPath: directory.path,
      );
    }

    // 列出所有有效项目
    List<Directory> validProjects = [];
    await Future.forEach(directories, (d) async {
      bool isValidProject = await validateFlutterProject(
        directory: d,
        filesToCheck: filesToCheck.map((file) => File(path.join(d.path, file))).toList(),
      );
      if (isValidProject) validProjects.add(d);
    });

    //检查是否没有找到有效的项目
    if (validProjects.isEmpty) {
      throw GazaCleanerException(
        errorType: GazaCleanerExceptionType.noProjectsFound,
      );
    }

    // 清理有效的项目并将结果作为流发出
    for (var validProject in validProjects) {
      double sizeBeforeCleaning = await directoryHelper.calculateDirectorySize(
        directory: validProject,
      );

      int cleaningResult = await commandExecutor.runCleaning(
        directoryPath: validProject.path,
      );

      // *) -2 is timeout exception so we dont have to mark all the porcess
      // *) as failure we can only mark this directory as failed to be cleaned
      // if(cleaningResult != 0 && cleaningResult != -2) {
      //   throw GazaCleanerException(
      //     command: cleaningCommand,
      //     errorType: getErrorType(cleaningResult)!,
      //   );
      // }

      double sizeAfterCleaning = await directoryHelper.calculateDirectorySize(
        directory: validProject,
      );

      yield CleaningResult(
        directory: validProject,
        success: cleaningResult == 0,
        sizeBeforeCleaning: sizeBeforeCleaning,
        sizeAfterCleaning: sizeAfterCleaning,
      );
    }
  }

  /// 检查是否是 Flutter 项目
  /// (pubspec.yaml 和 lib 存在，返回 true)
  Future<bool> validateFlutterProject({required Directory directory, required List<File> filesToCheck}) async {
    final pubspecFile = File('${directory.path}/pubspec.yaml');
    final libDir = Directory('${directory.path}/lib');
    bool pubspecFileExists = await pubspecFile.exists();
    bool libDirExists = await libDir.exists();
    return pubspecFileExists && libDirExists;
  }
}
