import '../../interface/sample_interface.dart';

class GetXMainSample extends Sample {
  final bool? isServer;
  GetXMainSample({this.isServer}) : super('lib/main.dart', overwrite: true);

  String get _flutterMain => '''import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() {
WidgetsFlutterBinding.ensureInitialized();
  runApp(
     ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return GetMaterialApp(
          title: "Application",
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          debugShowCheckedModeBanner: false,
          // locale: Get.deviceLocale,
          // fallbackLocale: const Locale('en', 'US'),
          // translationsKeys: AppTranslation.translations,
          builder: EasyLoading.init(
            builder: (context, widget) {
              return widget!;
            },
          ),
        );
      },
    ),
  );
}
  ''';

  String get _serverMain => '''import 'package:get_server/get_server.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(GetServer(
    getPages: AppPages.routes,
  ));
}
  ''';

  @override
  String get content => isServer! ? _serverMain : _flutterMain;
}
