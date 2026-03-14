import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/app_scope.dart';
import 'core/di/app_di.dart';
import 'firebase_options.dart';
import 'presentation/screens/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final di = AppDi();
  runApp(MainApp(di: di));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.di});

  final AppDi di;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      di: di,
      child: MaterialApp(
        title: '2048',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFEDC22E),
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1A1A2E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}


