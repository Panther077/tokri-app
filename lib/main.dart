import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'models/user_model.dart';

import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // We try to initialize with default options, but since I can't run flutterfire configure for the user,
  // I will wrap this in a try-catch or just use ensureInitialized.
  // Ideally, the user needs to provide firebase_options.dart.
  // For now, I will assume it exists or fail gracefully if they need to add it.

  // NOTE: If firebase_options.dart is missing, this will fail.
  // I will comment out the options part and let standard init run, expecting google-services.json to be there.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase init failed: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        StreamProvider<AppUser?>(
          create: (context) => context.read<AuthService>().currentUserData,
          initialData: null,
          catchError: (_, __) => null,
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Tokri',
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
