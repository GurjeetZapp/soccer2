import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer/Auth/provider.dart';

import 'package:soccer/firebase_options.dart';
import 'package:soccer/provider/inappropriate.dart';
import 'package:soccer/provider1.dart';
import 'package:soccer/screen/onboarding/splashscreen.dart';

void main() async{
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [

        // Adding PurchaseProvider
        ChangeNotifierProvider<PurchaseProvider>(
          lazy: false,
          create: (context) => PurchaseProvider(),
        ),
         ChangeNotifierProvider(
      create: (context) => SkipStatusProvider(),
      child: MyApp(),
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
