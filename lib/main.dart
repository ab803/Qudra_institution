import 'package:flutter/material.dart';
import 'package:flutter_paymob/flutter_paymob.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/paymentService/constants.dart';
import 'core/utilities/gettit.dart';
import 'core/utilities/gorouter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Supabase must init before everything
  await Supabase.initialize(
    url: 'https://lybzbbgsumqwzmenpvow.supabase.co',
    anonKey: 'sb_publishable_Lnf83gYp257M9DN26sQ0Lg_udB4Rmoq',
  );


  await FlutterPaymob.instance.initialize(
    apiKey: Constants.apiKey,
    integrationID: int.parse(Constants.integrationId),
    walletIntegrationId: int.parse(Constants.wallet),
    iFrameID: int.parse(Constants.iframeId),
  );
  // ✅ GetIt must be set up before runApp
  setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      routerConfig: AppRouter.router,
    );
  }
}