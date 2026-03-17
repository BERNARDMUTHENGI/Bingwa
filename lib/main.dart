import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 👈 kIsWeb
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'package:workmanager/workmanager.dart'; // 👈 added Workmanager

import 'core/themes/app_theme.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/offers/providers/offer_provider.dart';
import 'features/offers/models/offer.dart';
import 'features/quick_dial/services/queue_service.dart';
import 'features/balance/providers/balance_provider.dart';
import 'features/plans/providers/plan_provider.dart';
import 'features/subscriptions/providers/subscription_provider.dart';
import 'features/schedules/providers/schedule_provider.dart';
import 'features/admin/providers/admin_plan_provider.dart';
import 'features/admin/providers/admin_subscription_provider.dart';
import 'features/auth/providers/admin_auth_provider.dart';
import 'features/offers/ussd_codes/providers/ussd_code_provider.dart';
import 'features/configs/providers/config_provider.dart';
import 'features/transactions/providers/transaction_provider.dart';

/// ============================================
/// Workmanager Callback Dispatcher
/// ============================================
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Example background task logic
    debugPrint("Workmanager background task: $task, inputData: $inputData");

    // TODO: implement actual background work here, e.g., syncing offers or balances

    return Future.value(true); // must return true when the task completes successfully
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===========================
  // Workmanager initialization
  // ===========================
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // optional, shows logs for debugging
  );

  // ===========================
  // PLATFORM-SAFE HIVE INITIALIZATION
  // ===========================
  if (kIsWeb) {
    // Web has no file system → use IndexedDB internally
    await Hive.initFlutter();
  } else {
    // Mobile / Desktop → use app documents directory
    final appDocumentDir =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
  }

  // Register Hive adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(OfferAdapter());
  }

  await Hive.openBox<Offer>('offers');

  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core providers
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OfferProvider()),
        ChangeNotifierProvider(create: (_) => BalanceProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => UssdCodeProvider()),
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),

        // Admin providers
        ChangeNotifierProvider(create: (_) => AdminAuthProvider()),
        ChangeNotifierProvider(create: (_) => AdminSubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => AdminPlanProvider()),

        // QueueService depends on BalanceProvider and TransactionProvider
        ChangeNotifierProxyProvider2<BalanceProvider, TransactionProvider,
            QueueService>(
          create: (_) => QueueService(),
          update: (context, balanceProvider, transactionProvider, previous) {
            final service = previous ?? QueueService();
            service.setBalanceProvider(balanceProvider);
            service.setTransactionProvider(transactionProvider);
            return service;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Bingwa Hybrid',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const OnboardingScreen(),
      ),
    );
  }
}