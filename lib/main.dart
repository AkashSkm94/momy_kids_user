import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/localization/appLocalization.dart';
import 'core/localization/appLanguage.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'core/navigation/navigation_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppLanguage>(
      create: (context) => AppLanguage(),
      child: Consumer<AppLanguage>(
        builder: (context, appLanguage, child) {
          return MaterialApp(
            title: 'Momy Kids',
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService.navigatorKey,
            locale: appLanguage.appLocal,
            supportedLocales: const [
              Locale('en', ''),
              Locale('ar', ''),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              fontFamily: 'Montserrat',
              textTheme: const TextTheme(
                displayLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                displayMedium: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                displaySmall: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
                headlineLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                headlineMedium: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                headlineSmall: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                titleLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w600),
                titleMedium: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
                titleSmall: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
                bodyLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.normal),
                bodyMedium: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.normal),
                bodySmall: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.normal),
                labelLarge: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
                labelMedium: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
                labelSmall: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500),
              ),
            ),
            builder: (context, child) {
              return Directionality(
                textDirection: appLanguage.appLocal.languageCode == 'ar' 
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
            onUnknownRoute: (settings) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(
                    child: Text('Page Not Found'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
