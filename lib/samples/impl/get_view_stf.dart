import '../../common/utils/pubspec/pubspec_utils.dart';
import '../interface/sample_interface.dart';

class GetViewStfSample extends Sample {
  final String _controllerDir;
  final String _viewName;
  final String _controller;
  final bool _isServer;

  GetViewStfSample(
    super.path,
    this._viewName,
    this._controller,
    this._controllerDir,
    this._isServer, {
    super.overwrite,
  });

  String get import => _controllerDir.isNotEmpty ? '''import 'package:${PubspecUtils.projectName}/$_controllerDir';''' : '';

  String get _controllerName => _controller.isNotEmpty ? 'GetView<$_controller>' : 'GetView';

  String get _flutterView => '''
import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
$import

class $_viewName extends StatefulWidget {
  const $_viewName({super.key});
  @override
  State<$_viewName> createState() => _${_viewName}State();
}
class _${_viewName}State extends State<$_viewName>with AutomaticKeepAliveClientMixin {
  final controller = Get.put($_controller());
  @override
  bool get wantKeepAlive => true;
  @override
  void dispose() {
    Get.delete<$_controller>();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
   super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('$_viewName'),
        centerTitle: true,
      ),
      body:const Center(
        child: Text(
          '$_viewName is working', 
          style: TextStyle(fontSize:20),
        ),
      ),
    );
  }
}
  ''';

  String get _serverView => '''import 'package:get_server/get_server.dart'; $import

class $_viewName extends $_controllerName {
  @override
  Widget build(BuildContext context) {
    return const Text('GetX to Server is working!');
  }
}
  ''';

  @override
  String get content => _isServer ? _serverView : _flutterView;

  @override
  bool get overwrite => true;
}
