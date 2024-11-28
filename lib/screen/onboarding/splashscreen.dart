import 'dart:async';

import 'package:flutter/material.dart';



import 'package:soccer/apputils/appcolor.dart';

import 'package:soccer/screen/onboarding/onbordingscreens.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Wait for 3 seconds before navigating
    await Future.delayed(Duration(seconds: 3));

    // Check if the user is still logged in (Firebase maintains session)
    // User? user = FirebaseAuth.instance.currentUser;

    // Fetch locally stored data
    // SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    // bool isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;
    // bool isGuest = sharedPreferences.getBool('guestLogin') ?? false;

    // if (user != null || isGuest) {
    //   Navigator.push(context,MaterialPageRoute(builder: (context)=>Homescreen()));
    //   // If the user is logged in or logged in as a guest
    //   print('User is logged in or guest. Navigating to HomePage.');
      
    // } else {
      Navigator.push(context,MaterialPageRoute(builder: (context)=>OnboardingScreen()));
      // If not logged in, navigate to onboarding
      print('User is not logged in. Navigating to OnboardingScreen.');
     
    }
  

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: color1, // Define your background color
       
      
    );
  }
  }
