import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer/Auth/provider.dart';

import 'package:soccer/firebase_options.dart';
import 'package:soccer/provider/inappropriate.dart';
import 'package:soccer/screen/onboarding/splashscreen.dart';

void main() async{
   WidgetsFlutterBinding.ensureInitialized();

  // Initializing Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        // Adding PurchaseProvider
        ChangeNotifierProvider<PurchaseProvider>(
          lazy: false,
          create: (context) => PurchaseProvider(),
        ),
        // Adding SignupProvider
        ChangeNotifierProvider(create: (_) => SignupProvider()),
      ],
    child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen()
    );
  }
}
