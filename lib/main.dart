import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hasad_app/models/detection_result.dart';
import 'package:hasad_app/pages/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hasad_app/firebase_options.dart';
import 'package:hasad_app/services/firebase_messaging_service.dart';
import 'package:hasad_app/services/local_notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 🐝 Initialisation de Hive
  await Hive.initFlutter();

  // Enregistrement de l'adaptateur
  Hive.registerAdapter(DetectionResultAdapter());

  // Ouverture de la boîte
  await Hive.openBox<DetectionResult>('detection_results');

  // notification

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(
      localNotificationsService: localNotificationsService);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // 🔁 Méthode statique pour changer la locale depuis n'importe quelle page
  static void setLocale(BuildContext context, Locale newLocale) {
    final _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hasad App',
      debugShowCheckedModeBanner: false,

      // 🗺️ Langue dynamique
      locale: _locale,

      // 🌍 Localisation
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
        Locale('fr'), // French
      ],

      home: const SplashScreen(),
    );
  }
}
