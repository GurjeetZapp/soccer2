import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:soccer/Auth/log_in.dart';
import 'package:soccer/apputils/appcolor.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "title": "Domine os fundamentos do futebol",
      "description":
          "Aprenda o jogo com guias detalhados, desde o drible até o arremesso, e leve suas habilidades para o próximo nível.",
      "imagepath": "assets/image1  (1).png",
    },
    {
      "title": "Acompanhe seu progresso",
      "description":
          "Defina sessões práticas, acompanhe suas estatísticas e avalie as melhorias com feedback em tempo real sobre seu desempenho.",
      "imagepath": "assets/image1  (1).png",
    },
    {
      "title": "Eleve o seu jogo com treinamento personalizado",
      "description":
          "Crie rotinas de treino personalizadas, execute vários exercícios e siga dicas de especialistas adaptadas à sua jornada no futebol..",
      "imagepath": "assets/image1  (2).png",
    },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: color2,
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => OnboardingContent(
                  title: onboardingData[index]["title"]!,
                  description: onboardingData[index]["description"]!,
                  imagepath: onboardingData[index]["imagepath"]!,
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(360, 40),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 18),
                ),
                onPressed: _nextPage,
                child: Text(
                  _currentPage == onboardingData.length - 1
                      ? "Comece"
                      : "Próximo",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String title;
  final String description;
  final String imagepath;

  const OnboardingContent({
    Key? key,
    required this.title,
    required this.description,
    required this.imagepath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image (Full Screen)
        Positioned(
          left: 100,
          top: 10,
          child: Container(
            height: 451,
            width: 196,
            child: Image.asset(
              imagepath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Centered Blurred Text Container at the Bottom
        Positioned(
          bottom: 10, // Adjusted to make the container more visible
          left: 20,
          right: 20,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 10), // Reduced blur intensity
              child: Container(
                height: 213,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), // Adjusted for better visibility
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
