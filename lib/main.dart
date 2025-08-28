import 'package:bayanat/core/local/shared_prefrences.dart';
import 'package:bayanat/core/utils/constance_manager.dart';
import 'package:bayanat/modules/main/presentation_layer/bloc/main_bloc.dart';
import 'package:bayanat/modules/main/presentation_layer/screens/main_screen.dart';
import 'package:bayanat/modules/petty_cash/data_layer/data_sources/petty_cash_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:sizer/sizer.dart';
import 'core/services/dep_injection.dart';
import 'core/utils/theme_manager.dart';
import 'modules/authentication/presentation_layer/bloc/auth_bloc.dart';
import 'modules/authentication/presentation_layer/screens/splash_screen.dart';
import 'modules/main/presentation_layer/screens/pdfs/amc_card_pdf.dart';
import 'modules/main/presentation_layer/screens/pdfs/amc_pdf.dart';
import 'modules/main/presentation_layer/screens/pdfs/fault_pdf.dart';
import 'modules/petty_cash/presentation_layer/bloc/petty_cash_bloc.dart';
import 'modules/petty_cash/presentation_layer/bloc/pending_bills_bloc.dart';
// import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await ServiceLocator().init();
  FaultPdf.init();
  AmcCardPdf.init();
  AmcPdf.init();
  await CacheHelper.getData(key: "image").then((value) {
    if (value != false) {
      ConstanceManager.image = value;
    }
  });
  await CacheHelper.getData(key: "sessionId").then((value) {
    if (value != false) {
      ConstanceManager.sessionId = value;
    }
  });
  await CacheHelper.getData(key: "userId").then((value) {
    if (value != false) {
      ConstanceManager.userId = value;
    }
  });
  await CacheHelper.getData(key: "workPhone").then((value) {
    if (value != false) {
      ConstanceManager.workPhone = value;
    }
  });
  ConstanceManager.name = await CacheHelper.getData(key: "name");
  Get.put(PettyCashController());

  runApp(const MyApp());

  // runApp(
  //   DevicePreview(
  //     enabled: !kReleaseMode, // Enable in debug only
  //     builder: (context) => const MyApp(),
  //   ),
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
              create: (BuildContext context) =>
                  sl() //..add(const GetMyDataEvent()),
              ),
          BlocProvider<MainBloc>(
              create: (BuildContext context) => sl()
                ..add(const GetProductsEvent())
                ..add(GetJobCardEvent(context: context))
                ..add(GetAmcCardsEvent(
                  context: context,
                )) //..add(const GetMyDataEvent()),
              ),
          // BlocProvider<PettyCashBloc>(create: (_) => sl()),
          // BlocProvider<PendingBillsBloc>(create: (_) => sl()),
        ],
        child: GetMaterialApp(
          // locale: DevicePreview.locale(context),
          // builder: DevicePreview.appBuilder,
          debugShowCheckedModeBanner: false,
          theme: getAppTheme(),
          home: FutureBuilder(
            future: CacheHelper.getData(key: "sessionId"),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final sessionId = snapshot.data as String?;
                if (sessionId != null) {
                  return const JobCardScreen();
                } else {
                  return const SplashScreen();
                }
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      );
    });
  }
}
