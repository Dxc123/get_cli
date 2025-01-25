import '../../../common/utils/pubspec/pubspec_utils.dart';

/// Install the Get package for the project
/// 为项目安装 Get 包
Future<void> installGet([bool runPubGet = false]) async {
  // Remove existing Get dependency if present
  // 如果存在，移除现有的 Get 依赖
  PubspecUtils.removeDependencies('get', logger: false);

  // 添加 Get 依赖库
  await PubspecUtils.addDependencies('get', runPubGet: runPubGet);
  // dio
  await PubspecUtils.addDependencies('dio', runPubGet: runPubGet);
  //get_storage
  await PubspecUtils.addDependencies('get_storage', runPubGet: runPubGet);
  // logger
  await PubspecUtils.addDependencies('logger', runPubGet: runPubGet);
  // easy_refresh
  await PubspecUtils.addDependencies('easy_refresh', runPubGet: runPubGet);
  // flutter_easyloading
  await PubspecUtils.addDependencies('flutter_easyloading', runPubGet: runPubGet);
  // flutter_screenutil
  await PubspecUtils.addDependencies('flutter_screenutil', runPubGet: runPubGet);

  // 添加 json_annotation json序列化库
  await PubspecUtils.addDependencies('json_annotation', runPubGet: runPubGet);
  await PubspecUtils.addDependencies('json_serializable', isDev: true, runPubGet: runPubGet);
  await PubspecUtils.addDependencies('build_runner', isDev: true, runPubGet: runPubGet);
}
