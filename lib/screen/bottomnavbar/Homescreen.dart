import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer/Auth/log_in.dart';
import 'package:soccer/Auth/provider.dart';
import 'package:soccer/appconstant.dart';
import 'package:soccer/apputils/appcolor.dart';

import 'package:soccer/provider/inapppurcahse.dart';
import 'package:soccer/provider/inappropriate.dart';
import 'package:soccer/screen/allskillscreen.dart';
import 'package:soccer/screen/bottomnavbar/Myprofile.dart';
import 'package:soccer/screen/bottomnavbar/practicsescreen.dart';
import 'package:soccer/screen/skilldatascreen.dart';
import 'package:soccer/screen/soccer1.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:soccer/screen/tipscreen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of screens to navigate between
  final List<Widget> _screens = [
    HomeScreen(),
    PractiseScreen(),
    MyStatisticsScreen(),
    ProfileScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7C0C11), Color(0xFF9E181D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30), // Circular border at top-left
            topRight: Radius.circular(30), // Circular border at top-right
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent, // Keep transparent for gradient
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            elevation: 0, // Remove default elevation
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 0 ? Colors.white24 : Colors.transparent,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Image.network(
                    "${AppConstant.awsBaseUrl}/403/Vector.png",
                    height: 24,
                    width: 24,
                  ),
                ),
                label: 'Lar',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 1 ? Colors.white24 : Colors.transparent,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Image.network(
                    "${AppConstant.awsBaseUrl}/403/calendar-day 1.png",
                    height: 24,
                    width: 24,
                  ),
                ),
                label: 'Prática',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 2 ? Colors.white24 : Colors.transparent,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Image.network(
                    "${AppConstant.awsBaseUrl}/403/chart-pie-alt 1.png",
                    height: 24,
                    width: 24,
                  ),
                ),
                label: 'Estatística',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == 3 ? Colors.white24 : Colors.transparent,
                  ),
                  padding: EdgeInsets.all(8),
                  child: Image.network(
                    "${AppConstant.awsBaseUrl}/403/user (3) 1.png",
                    height: 24,
                    width: 24,
                  ),
                ),
                label: 'Minha conta',
              ),
            ],
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
String? selectedSkill = 'Drible'; 
 String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
   final FirebaseFirestore _firestore = FirebaseFirestore.instance; 
    final FirebaseAuth _auth = FirebaseAuth.instance;
     String? _currentUserId;
  bool isNOTValidUser = FirebaseAuth.instance.currentUser == null;
    // To store the selected skill type
 final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
   String? userId;
  String username = '';
  String email = '';
  String phoneNumber = '';
  String? firebaseImageUrl;
  bool isGuestUser = false;

  

   @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _currentUserId = _auth.currentUser?.uid;
    _getCurrentUserId();
    _initializeUser();
   // Get the current user's ID
  }
   Future<void> _getCurrentUserId() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    setState(() {
      currentUserId = userId;
    });
  }
   void showRateDialog(BuildContext context) {
    double rating = 0;

    // Replace with your app's Play Store URL
    final String playStoreUrl =
        'https://play.google.com/store/apps/details?id=your.app.package.name';

    Future<void> _launchPlayStore() async {
      if (await canLaunch(playStoreUrl)) {
        await launch(playStoreUrl);
      } else {
        throw 'Could not launch $playStoreUrl';
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Avalie nosso aplicativo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Avalie sua experiência:'),
              SizedBox(height: 10),
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 40.0,
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('Rating: $rating');
                _launchPlayStore();
                Navigator.of(context).pop();
              },
              child: Text('Enviar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
   Future<void> showDeleteConfirmationDialog(BuildContext context,
      {required VoidCallback onDelete}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar exclusão"),
          content: Text(
              "Aem certeza de que deseja excluir sua conta? Esta ação não pode ser desfeita."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog before deleting
                onDelete(); // Execute delete action
              },
              child: Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  Future<void> showYesNoAlertDialog(BuildContext context,
      {required String confirmMessage,
      required VoidCallback onYesClicked}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text(confirmMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                onYesClicked(); // Execute Yes action
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void onTapped(
      int i, BuildContext context, PurchaseProvider purchaseProvider) async {
    switch (i) {
      // case 0:
      //   navigatePopContext(context);
      //   navigateWithTransitionToScreen(context, InAppPurchasePage());
      //   break;
      case 0:
        if (isNOTValidUser) {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
          return;
        }
        showDeleteConfirmationDialog(context, onDelete: () async {
          try {
            final FirebaseAuth auth = FirebaseAuth.instance;
            User? user = auth.currentUser;
            if (user != null) {
              print("username ${user.email}");
              print("username state ${user.email}");
              try {
                await user.delete();
              } catch (e) {
                print("username delete err $e ");
              }
              print("username state after ${user.email}");
            }
            Navigator.pop(context);
            // _clearAllCache();
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => LoginScreen()));
          } catch (e) {
            Navigator.pop(context);
          }
        });
        break;
      case 1:
        if (isNOTValidUser) {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
          return;
        }
        await showYesNoAlertDialog(context,
            confirmMessage: "Do you really want to sign out?",
            onYesClicked: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        });
        break;
      case 2:
        if (isNOTValidUser) {
          Navigator.pop(context);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
          return;
        }
        break;
      default:
    }
  }

  // Map to store the skills for each skill type
  // Map to store the skills for each skill type
  final Map<String, List<Map<String, dynamic>>> skillData = {
   'Drible': [
  {
    'name': 'Fechar controle',
    "image": "/403/371 tips Images/Dribbling tips/1.webp",
    'data': {
      "title": "1. Drible: Controle Próximo",
       "image": "/403/371 tips Images/Dribbling tips/1.webp",
      "subtitle": "Domine suas habilidades de controle próximo",
      "description": "O controle próximo é a capacidade de manter a bola perto dos pés enquanto se movimenta ao redor dos oponentes. É uma habilidade vital para jogadores atacantes em espaços apertados.",
      "keyTechniques": [
        "Mantenha a bola perto dos pés usando toques curtos.",
        "Use o corpo para proteger a bola e impedir que os defensores a roubem.",
        "Use toques suaves com ambos os pés para ajustar a posição da bola sem perder o ritmo."
      ],
      "drills": [
        "Drible em zigue-zague com cones usando toques rápidos e curtos.",
        "Pratique driblar com um parceiro que atua como defensor, focando em manter a bola próxima."
      ],
      "mistakesToAvoid": [
        "Não faça muitos toques em espaços apertados; passe ou chute quando necessário.",
        "Não exponha a bola aos defensores; sempre proteja-a com o corpo."
      ],
      "cta": "Iniciar Prática"
    }
  },
  {
    'name': 'Drible sob pressão',
    "image": "/403/371 tips Images/Dribbling tips/2.webp",
    'data': {
      "title": "2. Drible: Sob Pressão",
      "subtitle": "Desenvolva sua habilidade de driblar sob pressão",
      "description": "Driblar sob pressão é manter o controle da bola enquanto os oponentes se aproximam. É crucial para decisões rápidas e retenção da bola em situações apertadas.",
      "keyTechniques": [
        "Use toques rápidos e leves para manter a bola em movimento e dificultar a vida dos oponentes.",
        "Mantenha a cabeça erguida para estar ciente dos defensores ao redor.",
        "Domine a habilidade de driblar com ambos os pés para aumentar a imprevisibilidade."
      ],
      "drills": [
        "Pratique driblar em espaços confinados com obstáculos ou jogadores aplicando pressão leve.",
        "Exercícios de Rondo: passe e drible em pequenos grupos sob pressão de defensores."
      ],
      "mistakesToAvoid": [
        "Não entre em pânico sob pressão; mantenha a calma e a compostura.",
        "Não ignore a visão periférica; sempre verifique os desafios e espaços abertos."
      ],
      "cta": "Iniciar Prática"
    }
  },
  {
    'name': 'Drible de velocidade',
    "image": "/403/371 tips Images/Dribbling tips/3.webp",
    'data': {
      "title": "3. Drible: Velocidade",
      "subtitle": "Aumente sua velocidade de drible",
      "description": "O drible em velocidade é a capacidade de mover a bola rapidamente enquanto mantém o controle, permitindo que os jogadores se afastem dos defensores ou explorem espaços abertos.",
      "keyTechniques": [
        "Empurre a bola com o peito do pé para uma velocidade controlada.",
        "Mantenha a cabeça erguida para ajustar a velocidade de acordo com a distância dos defensores.",
        "Use toques maiores em espaços abertos para cobrir terreno rapidamente."
      ],
      "drills": [
        "Exercícios de sprint e drible: alterne entre sprintar e driblar através de cones.",
        "Exercícios de perseguição: pratique driblar fugindo de um defensor que está te perseguindo."
      ],
      "mistakesToAvoid": [
        "Não perca o controle em alta velocidade; pratique manter o controle.",
        "Não dependa de apenas um pé; ajuste a bola com ambos os pés enquanto dribla em velocidade."
      ],
      "cta": "Iniciar Prática"
    }
  },
  {
    'name': 'Manuseamento de bola em espaços apertados',
    "image": "/403/371 tips Images/Dribbling tips/4.webp",
    'data': {
      "title": "4. Drible: Controle em Espaços Apertados",
      "subtitle": "Domine o controle da bola em áreas confinadas",
      "description": "O controle da bola em espaços apertados refere-se a manter a posse em áreas congestionadas, onde movimentos rápidos e decisões são essenciais.",
      "keyTechniques": [
        "Use toques pequenos e frequentes para manter a bola próxima.",
        "Use fintas corporais para enganar os oponentes e criar espaço.",
        "Giros de 360°: gire rapidamente usando o interior e o exterior do pé para mudar de direção."
      ],
      "drills": [
        "Drible em zigue-zague com cones usando toques pequenos.",
        "Jogos de Rondo: controle de bola em pequenos grupos enquanto defensores tentam ganhar a bola."
      ],
      "mistakesToAvoid": [
        "Não perca a compostura em áreas apertadas para evitar decisões apressadas.",
        "Não faça toques demais; saiba quando passar, driblar ou chutar."
      ],
      "cta": "Iniciar Prática"
    }
  },
  {
    'name': 'Protegendo a bola',
    "image": "/403/371 tips Images/Dribbling tips/5.webp",
    'data': {
      "title": "5. Drible: Protegendo a Bola",
      "subtitle": "Proteja a bola dos oponentes",
      "description": "Proteger a bola envolve usar o corpo para mantê-la longe dos oponentes, dando tempo para fazer um passe ou se movimentar.",
      "keyTechniques": [
        "Posição lateral: posicione o corpo entre o defensor e a bola.",
        "Centro de gravidade baixo: flexione levemente os joelhos para dificultar que os oponentes te empurrem.",
        "Uso dos braços: use os braços (sem fazer falta) para manter o defensor afastado."
      ],
      "drills": [
        "Exercícios de proteção 1v1: pratique proteger a bola enquanto procura opções de passe.",
        "Exercícios de costas para o gol: receba a bola de costas para o gol e proteja-a antes de girar."
      ],
      "mistakesToAvoid": [
        "Não use uma posição corporal fraca; use uma postura forte para proteger a bola.",
        "Não dependa muito dos braços; use mais o corpo para evitar faltas."
      ],
      "cta": "Iniciar Prática"
    }
  },
  {
    'name': 'Dribles um contra um',
    "image": "/403/371 tips Images/Dribbling tips/6.webp",
    'data': {
      "title": "6. Drible: Um Contra Um",
      "subtitle": "Supere os defensores em situações um contra um",
      "description": "O drible 1v1 é a habilidade de enfrentar e vencer um defensor em um duelo frente a frente, usando habilidades e decisões rápidas.",
      "keyTechniques": [
        "Espere pelo momento certo: espere o defensor se comprometer antes de fazer seu movimento.",
        "Use fintas: use fintas corporais e jogo de pés para enganar o defensor.",
        "Acelere após vencer o defensor: uma vez que você o ultrapassou, acelere para criar separação."
      ],
      "drills": [
        "Exercícios de ataque 1v1: pratique enfrentar um defensor em um espaço confinado.",
        "Exercícios de finta e arranque: pratique fintas para ultrapassar um defensor estático e, em seguida, corra para o espaço."
      ],
      "mistakesToAvoid": [
        "Não seja previsível; use uma variedade de movimentos para confundir o defensor.",
        "Não esqueça de acelerar após vencer o defensor."
      ],
      "cta": "Iniciar Prática"
    }
  }
],

'Passagem': [
  {
    'name': 'Passes Curtos', 
    'image': "/403/371 tips Images/Passing Tips section/1.webp",
    'data': {
      "title": "1. Passe: Passes Curtos",
      "subtitle": "Domine a Arte do Passe Curto Preciso",
      "description": "Um passe curto é um passe de baixo risco, geralmente cobrindo uma pequena distância até um companheiro de equipe próximo, crucial para manter a posse de bola e construir jogadas.",
      "keyTechniques": [
        "Use a parte interna do pé: toque na bola com a parte interna do pé para obter precisão e controle.",
        "Mantenha a bola no chão: passes curtos devem permanecer no chão para garantir precisão e facilitar o controle pelo companheiro.",
        "Posicionamento corporal: angule seu corpo na direção do alvo e siga o movimento após o passe."
      ],
      "drills": [
        "Exercício de passe de um toque: pratique passes rápidos com um parceiro, focando em precisão e tempo.",
        "Exercício de passe em triângulo: monte um triângulo de cones e pratique passes rápidos e precisos com vários companheiros."
      ],
      "mistakesToAvoid": [
        "Passar com muita força; passes curtos devem ser controlados, não muito fortes.",
        "Focar demais na bola; esteja sempre ciente do movimento dos companheiros e adversários."
      ],
      "cta": "Iniciar Prática"
    }
  },
  {
    'name': 'Passes Longos', 
    'image': '/403/371 tips Images/Passing Tips section/2.webp',
    'data': {
      "title": "2. Passe: Passes Longos",
      "subtitle": "Aprenda a Realizar Passes Longos Precisos",
      "description": "Um passe longo é um passe mais avançado que cobre uma distância maior, frequentemente usado para mudar o jogo ou alcançar um companheiro de equipe em espaço aberto.",
      "keyTechniques": [
        "Toque com o peito do pé: use o peito do pé para acertar a bola com força, mantendo-a baixa e precisa.",
        "Levante a bola: se necessário, eleve ligeiramente a bola para passar por cima dos defensores.",
        "Siga o movimento: estenda o movimento para gerar mais distância e controle."
      ],
      "drills": [
        "Exercício de mudança de jogo: pratique mudar o jogo com passes longos para um companheiro no lado oposto do campo.",
        "Exercício de precisão de passe longo: configure alvos a várias distâncias e pratique entregar passes longos com precisão."
      ],
      "mistakesToAvoid": [
        "Passar com muita força; foque mais na precisão do que na força ao realizar passes longos.",
        "Posicionamento incorreto do corpo; certifique-se de que seu corpo está angulado na direção do alvo para maior precisão."
      ],
      "cta": "Iniciar Prática"
    }
  },
  {
    'name': 'Cruzamento da Bola', 
    'image': '/403/371 tips Images/Passing Tips section/3.webp',
    'data': {
      "title": "3. Passe: Cruzamento da Bola",
      "subtitle": "Aprenda a Fazer o Cruzamento Perfeito",
      "description": "Um cruzamento é um passe feito a partir das áreas laterais para a área do gol, visando encontrar um companheiro em posição de marcar.",
      "keyTechniques": [
        "Levante a cabeça antes de cruzar: olhe para ver onde seus companheiros e defensores estão posicionados antes de cruzar.",
        "Corte a bola com efeito: use a parte interna do pé para cruzar a bola com curva e velocidade.",
        "Mire no segundo poste: mirar no segundo poste dá mais tempo para os atacantes ajustarem-se à bola."
      ],
      "drills": [
        "Exercício de cruzamento e finalização: pratique cruzar a bola a partir de posições laterais enquanto seus companheiros atacam a bola na área.",
        "Exercício de precisão de cruzamentos: configure alvos na área e pratique entregar cruzamentos precisos nesses alvos."
      ],
      "mistakesToAvoid": [
        "Não levantar a cabeça; sempre olhe antes de cruzar para garantir que você escolha um companheiro.",
        "Cruzar com pouca força; coloque força suficiente para que a bola ultrapasse o primeiro defensor."
      ],
      "cta": "Iniciar Prática"
    }
  },
  {
    'name': 'Bolas em Profundidade', 
    'image': '/403/371 tips Images/Passing Tips section/4.webp',
    'data': {
      "title": "4. Passe: Bolas em Profundidade",
      "subtitle": "Aprenda a Jogar Bolas em Profundidade",
      "description": "Um passe em profundidade é um passe que divide a defesa, enviando a bola entre os defensores para um companheiro avançar.",
      "keyTechniques": [
        "Use o tempo certo: passe a bola quando seu companheiro começar a correr, dando espaço para ele alcançar.",
        "Dê a força certa: o passe deve ter a força perfeita, não muito forte nem muito fraco, para que o companheiro o alcance em movimento.",
        "Encontre brechas na defesa: procure espaços entre os defensores para passar a bola."
      ],
      "drills": [
        "Exercício de passe em profundidade 2v2: pratique passes em profundidade enquanto é marcado por dois defensores.",
        "Exercício de corridas cronometradas: pratique passes em profundidade enquanto um companheiro faz corridas cronometradas."
      ],
      "mistakesToAvoid": [
        "Tempo incorreto; não passe a bola muito cedo ou tarde, pratique a sincronização com a corrida do seu companheiro.",
        "Passes muito fortes; um passe em profundidade muito forte ultrapassará seu companheiro. Pratique a precisão."
      ],
      "cta": "Iniciar Prática"
    }
  },
  {
    'name': 'Passe de Primeira', 
    'image': '/403/371 tips Images/Passing Tips section/5.webp',
    'data': {
      "title": "5. Passe: Passe de Primeira",
      "subtitle": "Domine Passes Rápidos e Fluídos",
      "description": "O passe de primeira envolve jogar a bola para um companheiro com um único toque, frequentemente usado em sequências rápidas para mover a bola ao redor dos adversários.",
      "keyTechniques": [
        "Antecipe a bola: esteja pronto para receber a bola e saiba para onde vai o próximo passe antes dela chegar.",
        "Use a parte interna do pé: toque a bola com a parte interna do pé para melhor precisão ao passar rapidamente.",
        "Mantenha o equilíbrio: mantenha seu corpo equilibrado e em controle para manter a velocidade e precisão do passe."
      ],
      "drills": [
        "Exercício de um toque no rondo: jogue um jogo rondo em grupos pequenos onde todos os passes devem ser de um toque.",
        "Exercício de passe contra a parede: pratique passes contra uma parede com um toque, mantendo a bola em movimento rapidamente."
      ],
      "mistakesToAvoid": [
        "Primeiro toque ruim; trabalhe para melhorar seu primeiro toque para que você possa passar rapidamente.",
        "Hesitação; não pense demais no próximo movimento, o passe de um toque requer decisões rápidas."
      ],
      "cta": "Iniciar Prática"
    }
  },
  {
    'name': 'Mudança de Jogo', 
    'image': '/403/371 tips Images/Passing Tips section/6.webp',
    'data': {
      "title": "6. Passe: Mudança de Jogo",
      "subtitle": "Aprenda a Mudar o Jogo Eficazmente",
      "description": "Mudar o jogo é uma técnica usada para mover a bola de um lado do campo para o outro, esticando a defesa e criando novas oportunidades de ataque.",
      "keyTechniques": [
        "Levante a bola sobre os defensores: use um passe elevado para mudar o jogo sobre os defensores e alcançar companheiros no lado oposto.",
        "Verifique o campo primeiro: antes de receber a bola, observe onde estão seus companheiros para decidir se mudar o jogo é a melhor opção.",
        "Use a parte externa do pé para curvas: se mudar o jogo em distâncias curtas, você pode usar a parte externa do pé para curvar a bola."
      ],
      "drills": [
        "Exercício de mudança de jogo: pratique passar longas bolas para a ala oposta, focando em precisão e tempo.",
        "Exercício de passe cruzado: configure alvos do outro lado do campo e pratique acertá-los com passes elevados."
      ],
      "mistakesToAvoid": [
        "Passe curto; certifique-se de levantar a bola o suficiente para ultrapassar os defensores ao mudar o jogo.",
        "Não observar o campo; sempre verifique suas opções antes de mudar o jogo para evitar perder a posse."
      ],
      "cta": "Iniciar Prática"
    }
  }
],
'Dicas de tiro': [
  {'name': 'Chutes Potentes', 'image': '/403/371 tips Images/shooting/1.webp','data':{  
    "title": "1. Chutes: Chutes Potentes",
    "subtitle": "Aprenda a Chutar a Bola com Potência",
    "description": "Um chute potente envolve golpear a bola com força máxima para aumentar a velocidade e a distância do chute. É usado para surpreender o goleiro com velocidade.",
    "keyTechniques": [
      "Use o peito do pé para golpear a bola com força máxima.",
      "Plante o pé de apoio firmemente ao lado da bola para estabilidade e equilíbrio.",
      "Finalize bem o movimento após o chute para adicionar mais potência."
    ],
    "drills": [
      "Chutes de longa distância: pratique chutes de fora da área para gerar potência.",
      "Finalização de um toque: pratique chutar de primeira após receber um passe, focando em golpes potentes."
    ],
    "mistakesToAvoid": [
      "Não incline o corpo muito para trás, pois isso pode fazer a bola passar por cima do gol.",
      "Certifique-se de golpear a parte central ou inferior da bola para maior potência."
    ],
    "cta": "Comece a Praticar"
  }},
  {'name': 'Chutes Colocados', 'image': '/403/371 tips Images/shooting/2.webp','data':{ 
    "title": "2. Chutes: Chutes Colocados",
    "subtitle": "Domine a Arte dos Chutes Curvados e Precisos",
    "description": "Um chute colocado usa curva em vez de potência para vencer o goleiro, geralmente mirando no canto oposto ou nas extremidades.",
    "keyTechniques": [
      "Use a parte interna do pé para adicionar efeito à bola.",
      "Mire no canto mais distante, longe do alcance do goleiro.",
      "Certifique-se de seguir a curva do chute com o movimento do corpo."
    ],
    "drills": [
      "Chutes curvos em torno de obstáculos: coloque cones para simular defensores e pratique chutes curvos no gol.",
      "Exercício de alvo nos cantos: coloque pequenos alvos nos cantos do gol e pratique acertar esses pontos com chutes precisos."
    ],
    "mistakesToAvoid": [
      "Não complique demais o chute; foque na técnica, não na força.",
      "Evite aplicar rotação excessiva ou insuficiente; encontre o equilíbrio certo para enganar o goleiro."
    ],
    "cta": "Comece a Praticar"
  }},
  {'name': 'Chutes por Cavadinha', 'image': '/403/371 tips Images/shooting/3.webp','data':{
    "title": "3. Chutes: Cavadinha",
    "subtitle": "Aprenda a Cobrir a Bola sobre o Goleiro",
    "description": "Um chute por cobertura envolve levantar a bola sobre o goleiro ou defensor usando um toque delicado, geralmente quando o goleiro está adiantado.",
    "keyTechniques": [
      "Faça contato suave na parte inferior da bola para levantá-la sobre o goleiro.",
      "Use a ponta do pé ou o peito do pé para levantar a bola de forma controlada.",
      "Avalie a posição do goleiro antes de realizar o chute por cobertura."
    ],
    "drills": [
      "Exercício de cobertura 1v1: pratique cobrir o goleiro que avança em sua direção.",
      "Coberturas à distância: pratique chutes por cobertura de várias distâncias mirando em áreas pequenas no gol."
    ],
    "mistakesToAvoid": [
      "Não use muita força; chutes por cobertura exigem toque suave.",
      "Certifique-se de levantar a bola o suficiente para passar por cima do goleiro."
    ],
    "cta": "Comece a Praticar"
  }},
  {'name': 'Chutes de Voleio', 'image': '/403/371 tips Images/shooting/4.webp','data':{
    "title": "4. Chutes: Voleios",
    "subtitle": "Domine a Arte de Chutar a Bola no Ar",
    "description": "Um chute de voleio envolve golpear a bola enquanto ela está no ar antes de tocar o chão, normalmente após um cruzamento ou rebote.",
    "keyTechniques": [
      "Mantenha os olhos na bola para cronometrar o chute no momento certo.",
      "Use o peito do pé ou a parte interna para chutar com potência.",
      "Mantenha o equilíbrio e o corpo levemente inclinado para controlar a direção e a força do chute."
    ],
    "drills": [
      "Exercício de cruzamento e voleio: pratique receber cruzamentos e chutar a bola no ar.",
      "Exercício de rebote de voleio: pratique chutar a bola após rebotes na trave ou no poste."
    ],
    "mistakesToAvoid": [
      "Erros de tempo: um voleio depende de um bom timing. Pratique o tempo certo.",
      "Inclinar-se demais para trás pode fazer a bola ir por cima do gol. Mantenha o corpo levemente inclinado para frente."
    ],
    "cta": "Comece a Praticar"
  }},
  {'name': 'Chutes de Longa Distância', 'image': '/403/371 tips Images/shooting/5.webp','data':{
    "title": "5. Chutes: Longa Distância",
    "subtitle": "Chute de Distância com Potência e Precisão",
    "description": "Chutes de longa distância são tentativas de gol de fora da área, exigindo tanto potência quanto precisão para vencer o goleiro.",
    "keyTechniques": [
      "Use o peito do pé para gerar mais força.",
      "Mire em chutes baixos e fortes nos cantos do gol para dificultar a defesa do goleiro.",
      "Certifique-se de um follow-through forte para maximizar a distância e precisão."
    ],
    "drills": [
      "Exercício de chute à distância: pratique chutes de fora da área mirando diferentes pontos do gol.",
      "Chutes de longa distância de primeira: receba passes e chute de primeira de fora da área."
    ],
    "mistakesToAvoid": [
      "Falta de follow-through pode resultar em chutes fracos ou imprecisos.",
      "Sempre leia a posição do goleiro antes de chutar para explorar quaisquer brechas."
    ],
    "cta": "Comece a Praticar"
  }},
  {'name': 'Cobranças de Falta', 'image': '/403/371 tips Images/shooting/6.webp','data':{
    "title": "6. Chutes: Cobranças de Falta",
    "subtitle": "Domine a Arte das Cobranças Diretas",
    "description": "Uma cobrança de falta direta é uma oportunidade de marcar após uma falta, onde o jogador pode chutar diretamente para o gol.",
    "keyTechniques": [
      "Posicione a bola corretamente para um chute limpo.",
      "Use a parte interna ou o peito do pé para controle ou potência.",
      "Adicione efeito ajustando a posição do pé para curvar a bola ao redor da barreira."
    ],
    "drills": [
      "Exercício de falta com barreira: monte uma barreira e pratique chutes curvos no gol.",
      "Prática de alvo: coloque alvos no gol e pratique acertar esses pontos com chutes de falta."
    ],
    "mistakesToAvoid": [
      "Não apresse o chute; tome seu tempo para se concentrar antes de chutar.",
      "Certifique-se de um follow-through completo para adicionar efeito ou potência ao chute."
    ],
    "cta": "Comece a Praticar"
  }}
],

'Defesa': [
  {
    'name': 'Desarme', 
    'image': '/403/371 tips Images/Defending Tips/1.webp', 
    'data': {
      "title": "2. Defendendo: Contenção",
      "subtitle": "Controle o Espaço, Force os Adversários para Longe",
      "description": "A contenção é uma técnica defensiva em que você se posiciona entre o atacante e o gol, forçando-o para áreas menos perigosas sem realizar um desarme.",
      "keyTechniques": [
        "Mantenha-se baixo: mantenha um centro de gravidade baixo para reagir rapidamente aos movimentos do atacante.",
        "Angule seu corpo: posicione-se de lado em relação ao atacante, cortando seu caminho em direção ao gol.",
        "Mantenha a distância: fique perto o suficiente para desafiar, mas longe o bastante para reagir a mudanças de direção."
      ],
      "drills": [
        "Exercício de contenção 1v1: pratique o posicionamento contra um atacante, mantendo-o longe do gol.",
        "Exercício de sombra: pratique seguir os movimentos de um oponente sem realizar contato, focando no trabalho de pés."
      ],
      "mistakesToAvoid": [
        "Não se apresse no desarme; seja paciente e force o atacante a cometer um erro.",
        "Evite dar muito espaço; dê ao atacante o suficiente para atraí-lo, mas não tanto que ele possa passar facilmente."
      ],
      "cta": "Comece a Praticar"
    }
  },
  {
    'name': 'Marcação', 
    'image': '/403/371 tips Images/Defending Tips/2.webp', 
    'data': {
      "title": "3. Defendendo: Marcação e Posicionamento",
      "subtitle": "Aprenda a Controlar os Adversários",
      "description": "Marcação refere-se a permanecer próximo ao seu oponente designado, evitando que ele receba ou jogue a bola. Posicionamento envolve estar no lugar certo para interceptar passes ou bloquear chutes.",
      "keyTechniques": [
        "Fique perto do seu oponente: sempre mantenha-se a poucos metros do jogador que está marcando.",
        "Mantenha seu corpo entre o adversário e o gol: posicione-se no caminho do atacante para bloquear seu movimento em direção ao gol.",
        "Leia o jogo: antecipe para onde a bola vai e ajuste seu posicionamento conforme necessário."
      ],
      "drills": [
        "Exercício de marcação 1v1: pratique marcar um adversário, garantindo que ele tenha pouco espaço para atuar.",
        "Exercício de interceptação de passes: pratique posicionar-se para bloquear ou interceptar passes ao atacante."
      ],
      "mistakesToAvoid": [
        "Evite observar somente a bola; mantenha os olhos tanto na bola quanto no jogador que está marcando.",
        "Evite ficar parado; esteja nas pontas dos pés, pronto para reagir rapidamente ao movimento do oponente."
      ],
      "cta": "Comece a Praticar"
    }
  },
  {
    'name': 'Bloqueio de Chutes', 
    'image': '/403/371 tips Images/Defending Tips/3.webp', 
    'data': {
      "title": "4. Defendendo: Interceptações",
      "subtitle": "Corte Passes e Crie Recuperações",
      "description": "Uma interceptação ocorre quando um defensor corta um passe destinado a um adversário, evitando uma jogada ofensiva e recuperando a posse de bola para seu time.",
      "keyTechniques": [
        "Leia o jogo: antecipe para onde a bola será passada e mova-se para essa área.",
        "Posicionamento: coloque-se nas linhas de passe para aumentar a chance de uma interceptação.",
        "Reação rápida: assim que a bola for passada, reaja rapidamente para ganhar a posse."
      ],
      "drills": [
        "Exercício de interceptação em linha de passe: pratique cortar passes posicionando-se nas linhas de passe do oponente.",
        "Jogos em espaço reduzido: jogue em grupos pequenos focando em ler o jogo e fazer interceptações."
      ],
      "mistakesToAvoid": [
        "Não se apresse fora de posição; só intercepte quando tiver certeza de que pode ganhar a bola.",
        "Falta de atenção; esteja sempre atento a onde estão a bola e os oponentes no campo."
      ],
      "cta": "Comece a Praticar"
    }
  },
  {
    'name': "Intercepções",
    'image': "/403/371 tips Images/Defending Tips/4.webp",
    'data': {
      "title": "5. Intercepções",
      "subtitle": "Impeça os Adversários de Finalizarem",
      "description": "O bloqueio consiste em usar o corpo para evitar que um chute chegue ao gol, posicionando-se no caminho da bola e absorvendo o impacto.",
      "keyTechniques": [
        "Mantenha-se baixo e equilibrado: esteja pronto para mover-se rapidamente para bloquear o chute.",
        "Posicionamento corporal: angule seu corpo para se tornar maior sem expor suas mãos ou braços.",
        "Comprometa-se totalmente com o bloqueio; não hesite ao bloquear."
      ],
      "drills": [
        "Exercício de bloqueio de chutes: pratique posicionar-se para bloquear chutes durante exercícios com vários atacantes.",
        "Exercício de bloqueio de rebotes: pratique reagir rapidamente para bloquear chutes após rebotes."
      ],
      "mistakesToAvoid": [
        "Não vire as costas para a bola ao tentar bloquear um chute.",
        "Não hesite; comprometa-se totalmente ao bloqueio para evitar que a bola passe."
      ],
      "cta": "Comece a Praticar"
    }
  },
  {
    'name': "Defesa 1v1",
    'image': "/403/371 tips Images/Defending Tips/5.webp",
    'data': {
      "title": "6. Defendendo: Defesa 1v1",
      "subtitle": "Domine a Defesa Individual",
      "description": "Defender 1v1 refere-se a defender contra um único atacante em uma situação cara a cara, onde o tempo, posicionamento e tomada de decisão são críticos para o sucesso.",
      "keyTechniques": [
        "Posicione seu corpo corretamente: fique de lado em relação ao atacante, forçando-o para longe do gol.",
        "Espere pelo momento certo: não se jogue muito cedo; espere o atacante cometer um erro ou um toque pesado.",
        "Mantenha-se equilibrado e reativo: tenha um centro de gravidade baixo e esteja pronto para mudar de direção rapidamente."
      ],
      "drills": [
        "Exercício 1v1: pratique defender contra um atacante em espaços pequenos, focando no posicionamento e no tempo.",
        "Exercício de espelho: pratique seguir os movimentos do atacante sem contato, focando no trabalho de pés e equilíbrio."
      ],
      "mistakesToAvoid": [
        "Não se jogue muito cedo; seja paciente e force o atacante a cometer um erro.",
        "Não seja muito passivo; não dê ao atacante muito espaço para ganhar impulso."
      ],
      "cta": "Comece a Praticar"
    }
  }
],
"Goleiro": [
  {
    "name": "Defesa de Tiros",
    "image": "/403/371 tips Images/goalkeeping Tips/1.webp",
    "data": {
      "title": "1. Defesa de Goleiro: Parada de Chutes",
      "subtitle": "Domine o Básico de Parar Chutes",
      "description": "Shot stopping refere-se à habilidade do goleiro de impedir que a bola entre no gol, usando suas mãos, pés ou corpo para bloquear ou agarrar a bola.",
      "keyTechniques": [
        "Posicionamento: mantenha-se no centro do gol e esteja pronto para reagir a ambos os lados.",
        "Reflexos rápidos: desenvolva tempos de reação rápidos para parar chutes de diferentes ângulos.",
        "Agarre ou desvie: decida se deve agarrar a bola ou desviá-la, dependendo da força e da colocação do chute."
      ],
      "drills": [
        "Exercício de defesa rápida: um treinador ou parceiro chuta rapidamente de diferentes distâncias e ângulos, focando em seus reflexos.",
        "Exercício de bloqueio à queima-roupa: pratique parar chutes de curta distância, concentrando-se no posicionamento e reações rápidas."
      ],
      "mistakesToAvoid": [
        "Comprometer-se cedo demais: mantenha o equilíbrio e não se jogue cedo demais, dando mais tempo para reagir.",
        "Posição incorreta das mãos: mantenha as mãos em uma posição pronta para bloquear chutes."
      ],
      "cta": "Começar Prática"
    }
  },
  {
    "name": "Agarra",
    "image": "/403/371 tips Images/goalkeeping Tips/2.webp",
    "data": {
      "title": "2. Defesa de Goleiro: Posicionamento",
      "subtitle": "Aprenda a Estar no Lugar Certo na Hora Certa",
      "description": "Posicionamento refere-se à habilidade do goleiro de estar no local ideal para defender um chute, bloquear um cruzamento ou cortar ângulos, dificultando a vida dos atacantes.",
      "keyTechniques": [
        "Mantenha-se centralizado: posicione-se no centro do gol quando a bola estiver à sua frente, ajustando-se conforme o jogo se desenvolve.",
        "Movimente-se com a bola: ajuste seu posicionamento com base na localização da bola, movendo-se para cobrir todos os ângulos.",
        "Antecipe o chute: mantenha os olhos na bola e esteja pronto para ajustar o posicionamento em caso de movimento repentino."
      ],
      "drills": [
        "Exercício de movimento lateral: pratique mover-se rapidamente de um lado para o outro no gol enquanto a bola se move, mantendo o posicionamento correto.",
        "Exercício de posicionamento 1v1: pratique sair do gol em um cenário de um contra um, focando em cortar ângulos de chute."
      ],
      "mistakesToAvoid": [
        "Ficar muito atrás na linha do gol: avance para cortar os ângulos do atacante.",
        "Ficar estático: mova-se sempre com a bola; estar parado diminui sua capacidade de reagir."
      ],
      "cta": "Começar Prática"
    }
  },
  {
    "name": "Socando",
    "image": "/403/371 tips Images/goalkeeping Tips/3.webp",
    "data": {
      "title": "4. Defesa de Goleiro: Distribuição da Bola",
      "subtitle": "Aprenda a Começar o Ataque com Boa Distribuição",
      "description": "Distribuição refere-se à forma como o goleiro joga a bola para seus companheiros após uma defesa, tiro de meta ou ao iniciar um contra-ataque.",
      "keyTechniques": [
        "Role ou arremesse para passes curtos: ao passar para companheiros próximos, use um arremesso ou rolar a bola para garantir precisão.",
        "Use tiros de meta ou chutes para passes longos: chute a bola para alcançar companheiros em posições avançadas.",
        "Observe o campo: antes de distribuir, observe o campo para encontrar a melhor opção e evitar perder a posse de bola."
      ],
      "drills": [
        "Exercício de distribuição do goleiro: pratique lançar, rolar e chutar a bola para companheiros a diferentes distâncias.",
        "Distribuição sob pressão: trabalhe na distribuição enquanto está sob pressão dos atacantes, fazendo decisões rápidas e precisas."
      ],
      "mistakesToAvoid": [
        "Distribuir com pressa: não tenha pressa; avalie a melhor opção antes de soltar a bola.",
        "Falta de precisão: pratique precisão em vez de distância para evitar perder a posse."
      ],
      "cta": "Começar Prática"
    }
  },
  {
    "name": "Técnica de Mergulho",
    "image": "/403/371 tips Images/goalkeeping Tips/4.webp",
    "data": {
      "title": "6. Defesa de Goleiro: Técnica de Mergulho",
      "subtitle": "Aperfeiçoe Suas Defesas em Mergulho",
      "description": "Mergulhar é uma técnica usada pelo goleiro para alcançar e parar chutes que estão fora de seu alcance normal, projetando-se horizontal ou diagonalmente pelo gol.",
      "keyTechniques": [
        "Comece com boa movimentação de pés: dê um passo rápido para o lado antes de mergulhar para cobrir mais espaço.",
        "Mergulhe baixo para chutes nos cantos inferiores: concentre-se em descer rapidamente para parar chutes direcionados aos cantos inferiores.",
        "Estenda-se totalmente: estenda seu corpo e braços completamente para cobrir a maior área possível do gol."
      ],
      "drills": [
        "Exercício de mergulho com cones: pratique mergulhos para ambos os lados enquanto um treinador ou parceiro chuta para os cantos do gol.",
        "Exercício de reação de mergulho: reaja rapidamente a chutes imprevisíveis, focando em sua técnica de mergulho."
      ],
      "mistakesToAvoid": [
        "Movimentação ruim: sempre dê um passo em direção à bola antes de mergulhar para cobrir mais espaço.",
        "Não estender completamente: falhar em se estender totalmente pode reduzir seu alcance e permitir que a bola passe."
      ],
      "cta": "Começar Prática"
    }
  },
  {
    "name": "Defesas de Pênalti",
    "image": "/403/371 tips Images/goalkeeping Tips/5.webp",
    "data": {
      "title": "5. Defesa de Goleiro: Salvar Pênaltis",
      "subtitle": "Aprenda as Técnicas para Salvar Pênaltis",
      "description": "Salvar pênaltis envolve impedir um gol em uma cobrança de pênalti, antecipando a direção do chute e fazendo a defesa necessária.",
      "keyTechniques": [
        "Leia o cobrador: observe a linguagem corporal e a posição do pé do cobrador para antecipar a direção do chute.",
        "Mantenha-se centralizado: comece no centro do gol, dando alcance igual para ambos os lados.",
        "Reaja rapidamente: uma vez que a bola for chutada, reaja o mais rápido possível, mergulhando na direção do chute."
      ],
      "drills": [
        "Exercício de defesa de pênaltis: pratique enfrentando cobranças de pênaltis, focando em ler a linguagem corporal e reagir ao chute.",
        "Exercício de reflexos rápidos: trabalhe seus reflexos salvando chutes de curta distância, reagindo assim que a bola for chutada."
      ],
      "mistakesToAvoid": [
        "Chutar muito cedo: mantenha o equilíbrio e não se jogue cedo demais; espere o cobrador fazer o movimento.",
        "Ficar muito atrás: não fique na linha do gol; posicione-se ligeiramente à frente para reduzir o ângulo."
      ],
      "cta": "Começar Prática"
    }
  }
],

'conjunto de peças': [
  {'name': 'Cantos Atacantes', 'image': '/403/371 tips Images/Set pieces/1.webp','data': {
    "title": "1. Jogadas Ensaiadas: Escanteios Ofensivos",
    "subtitle": "Domine a Arte de Atacar com Escanteios",
    "description": "Um escanteio ofensivo é uma jogada ensaiada onde a equipe ofensiva entrega a bola na área de pênalti a partir do canto do campo, visando marcar um gol.",
    "keyTechniques": [
      "Cruzamento com velocidade: use o interior do pé para cruzar a bola na área com velocidade e efeito.",
      "Alvo em áreas-chave: mire no primeiro poste, segundo poste ou no ponto de pênalti, dependendo da configuração da sua equipe.",
      "Corridas cronometradas: os atacantes devem fazer corridas bem cronometradas para encontrar a bola no seu ponto mais alto."
    ],
    "drills": [
      "Exercício de cruzamento e cabeceio: pratique a entrega de escanteios enquanto os atacantes praticam cabeceios em direção ao gol.",
      "Simulação de jogada ensaiada: simule condições reais de jogo com atacantes, defensores e um goleiro para praticar escanteios."
    ],
    "mistakesToAvoid": [
      "Bola fraca ou muito forte: certifique-se de cruzar a bola com a velocidade e precisão certas para dar chance aos seus companheiros.",
      "Falta de comunicação: os atacantes devem se comunicar sobre posicionamento e tempo para uma execução eficaz."
    ],
    "cta": "Comece a Praticar"
  }},
  {'name': 'Cantos Defensivos', 'image': '/403/371 tips Images/Set pieces/2.webp','data':  {
    "title": "2. Jogadas Ensaiadas: Escanteios Defensivos",
    "subtitle": "Aprenda a Defender Contra Escanteios Perigosos",
    "description": "Defender escanteios envolve organizar a defesa para evitar que a equipe adversária marque, geralmente marcando jogadores e afastando a bola da zona de perigo.",
    "keyTechniques": [
      "Marcar o adversário: use marcação homem a homem ou zonal para garantir que todos os atacantes estejam cobertos.",
      "Limpe a bola na primeira tentativa: não hesite—afaste a bola no primeiro toque para evitar rebotes.",
      "Esteja atento para segundas bolas: após o primeiro desvio, esteja pronto para reagir a novas chances."
    ],
    "drills": [
      "Exercício de marcação: pratique marcar atacantes durante escanteios, mantendo-se próximo e evitando cabeceios.",
      "Exercício de afastamento: pratique afastar bolas de escanteios com cabeçadas ou pés, garantindo distância e precisão."
    ],
    "mistakesToAvoid": [
      "Apenas seguir a bola: esteja sempre ciente do seu adversário enquanto acompanha a bola.",
      "Falta de comunicação: defensores e goleiros devem se comunicar para evitar confusões e falhas na marcação."
    ],
    "cta": "Comece a Praticar"
  }},
  {'name': 'Faltas Diretas', 'image': '/403/371 tips Images/Set pieces/3.webp','data':{
    "title": "3. Jogadas Ensaiadas: Faltas Diretas",
    "subtitle": "Aperfeiçoe a Habilidade de Marcar em Faltas Diretas",
    "description": "Um tiro livre direto é uma jogada onde o jogador pode marcar diretamente do chute sem a necessidade da bola tocar outro jogador.",
    "keyTechniques": [
      "Mire nos cantos: tiros livres são mais eficazes quando direcionados aos cantos superiores ou inferiores, onde o goleiro tem menos alcance.",
      "Adicione efeito: use o interior do pé para curvar a bola ao redor da barreira ou em direção aos cantos.",
      "Varie sua técnica: pratique chutes baixos, retos e curvados, dependendo da distância até o gol."
    ],
    "drills": [
      "Exercício de precisão: coloque alvos nos cantos do gol e pratique tiros livres a partir de várias distâncias.",
      "Exercício com barreira: monte uma barreira e pratique curvas ao redor dela para atingir o gol."
    ],
    "mistakesToAvoid": [
      "Chutar na barreira: concentre-se em levantar a bola ou curvá-la ao redor da barreira.",
      "Pensar demais no chute: mantenha sua técnica simples—foco na força, precisão e colocação."
    ],
    "cta": "Comece a Praticar"
  }},
  {'name': 'Execução de Lançamentos', 'image': '/403/371 tips Images/Set pieces/4.webp','data':{
    "title": "4. Jogadas Ensaiadas: Faltas Indiretas",
    "subtitle": "Aprenda a Utilizar Faltas Indiretas de Forma Eficaz",
    "description": "Um tiro livre indireto é concedido por faltas menos graves, onde a bola deve tocar outro jogador antes de resultar em gol.",
    "keyTechniques": [
      "Passes rápidos de um-dois: use um passe curto para um companheiro que então pode chutar ou cruzar.",
      "Planeje uma jogada ensaiada: tenha um plano claro—passe curto para preparar o chute ou cruze na área para cabeceio.",
      "Disfarce suas intenções: use linguagem corporal para enganar a defesa, tornando incerto se você vai chutar ou passar."
    ],
    "drills": [
      "Exercício de jogada ensaiada: trabalhe com companheiros em rotinas planejadas de tiros livres indiretos, focando em comunicação e execução.",
      "Exercício de entrega indireta: pratique a entrega de tiros livres indiretos com foco em encontrar companheiros ou preparar o chute."
    ],
    "mistakesToAvoid": [
      "Falta de comunicação: certifique-se de que todos os jogadores conheçam suas funções antes de executar a jogada ensaiada.",
      "Demorar muito: execute rapidamente para evitar dar tempo para a defesa se organizar."
    ],
    "cta": "Comece a Praticar"
  }},
  {'name': 'Arremessos Laterais', 'image': '/403/371 tips Images/Set pieces/5.webp','data': {
    "title": "5. Jogadas Ensaiadas: Arremessos Laterais",
    "subtitle": "Domine a Técnica de Realizar Arremessos Laterais Eficazes",
    "description": "Um arremesso lateral é concedido quando a bola cruza a linha lateral, permitindo que a equipe que não tocou por último recomece o jogo.",
    "keyTechniques": [
      "Use ambas as mãos: segure a bola com ambas as mãos, garantindo que o lançamento comece atrás da cabeça e seja liberado por cima da cabeça.",
      "Pés no chão: mantenha ambos os pés firmemente no chão ao soltar a bola para evitar um lançamento ilegal.",
      "Mire no espaço: procure companheiros em espaços livres em vez de forçar a bola em áreas congestionadas."
    ],
    "drills": [
      "Exercício de precisão no arremesso: pratique entregas precisas para companheiros enquanto evita os defensores.",
      "Exercício de arremesso longo: trabalhe na geração de força e distância em seus arremessos, praticando técnica e forma."
    ],
    "mistakesToAvoid": [
      "Levantar os pés: certifique-se de que ambos os pés permaneçam no chão para evitar perder a posse.",
      "Pressa no arremesso: tire seu tempo para encontrar a melhor opção em vez de lançar rapidamente e perder a posse."
    ],
    "cta": "Comece a Praticar"
  }},
  {'name': 'Pênaltis', 'image': '/403/371 tips Images/Set pieces/6.webp','data': {
    "title": "6. Jogadas Ensaiadas: Cobrança de Pênaltis",
    "subtitle": "Aprenda a Cobrar Pênaltis com Calma e Composição",
    "description": "Um pênalti é concedido após uma falta na área de pênalti. A bola é colocada no ponto de pênalti, e o cobrador deve chutar a 12 metros com apenas o goleiro para defender.",
    "keyTechniques": [
      "Escolha seu canto: decida onde vai chutar antes de executar e mantenha sua decisão.",
      "Mantenha a calma: foque na técnica e mantenha a calma sob pressão.",
      "Use o interior do pé para precisão: chute com o interior do pé para melhor controle e precisão."
    ],
    "drills": [
      "Exercício de cobrança de pênaltis: pratique cobranças múltiplas, focando em colocar a bola em diferentes áreas do gol.",
      "Exercício de pênalti sob pressão: simule situações de alta pressão com companheiros ou treinadores observando você cobrar pênaltis."
    ],
    "mistakesToAvoid": [
      "Mudar de ideia: uma vez que escolheu o canto, mantenha sua decisão—mudar no último momento pode resultar em um chute ruim.",
      "Forçar demais: foque mais na precisão do que na força para garantir um chute eficaz."
    ],
    "cta": "Comece a Praticar"
  }},
],

  };
  

  Future<void> _initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      isGuestUser = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('guestUserId') ?? Uuid().v4();
      prefs.setString('guestUserId', userId!);
    } else {
      isGuestUser = false;
      userId = user.uid;
    }

    await _loadUserData();
  }
  Future<void> _loadUserData() async {
    try {
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          username = data?['name'] ?? 'USER';
          email = data?['email'] ?? '';
          phoneNumber = data?['phone_number'] ?? '';
           firebaseImageUrl = data?['profile_image'] ?? '';
        } else if (isGuestUser) {
          
          SharedPreferences prefs = await SharedPreferences.getInstance();
          username = prefs.getString('guestUsername') ?? 'Guest';
          email = prefs.getString('guestEmail') ?? '';
          phoneNumber = prefs.getString('guestPhoneNumber') ?? '';
             firebaseImageUrl= prefs.getString('guestProfileImage') ?? '';
        }
        setState(() {});
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    final signupProvider = Provider.of<SignupProvider>(context);
    final purchaseProvider = Provider.of<PurchaseProvider>(context);
    return SafeArea(
      child: Scaffold(
        
        key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Padding(
  padding: const EdgeInsets.all(8.0),
  child: CircleAvatar(
    radius: 30,
    backgroundImage: firebaseImageUrl != null && firebaseImageUrl!.isNotEmpty
        ? NetworkImage('${AppConstant.awsBaseUrlUpload}$firebaseImageUrl')
        : AssetImage('assets/default_avatar.png') as ImageProvider, // Provide a fallback if the image URL is empty
  ),
),

        title:   Text(
          " $username",
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ],
      ),
     drawer: Drawer(
  child: Container(
    color: Color.fromRGBO(124, 12, 17, 1), // Deep red background color
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Color.fromRGBO(124, 12, 17, 1),
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                CircleAvatar(
  radius: 50, // Larger size for prominence
  backgroundImage: firebaseImageUrl != null && firebaseImageUrl!.isNotEmpty
      ? NetworkImage('${AppConstant.awsBaseUrlUpload}$firebaseImageUrl') // If a Firebase URL exists
      : NetworkImage('${AppConstant.awsBaseUrl}/389/icons img/499f8320580c7ae3e569ed0c371bf600.png'), // Fallback image
  backgroundColor: Colors.white, // Circle background
),

                SizedBox(height: 15), // Space below the avatar
                Text(
                  "$username", // Replace with dynamic username if available
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "$email", // Replace with dynamic email if available
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white38, thickness: 1), // Separator line
          ListTile(
            leading: Icon(Icons.restore, color: Colors.white),
            title: Text(
              'Restaurar compras',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () async {
              await purchaseProvider.restoreItem();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              signupProvider.isGuest ? Icons.login : Icons.logout,
              color: Colors.white,
            ),
            title: Text(
              signupProvider.isGuest ? 'Conecte-se' : 'Sair',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () async {
              if (signupProvider.isGuest) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } else {
                await signupProvider.signOut(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.white),
            title: Text(
              'Excluir conta',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () {
              signupProvider.deleteAccount(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.restore, color: Colors.white),
            title: Text(
              'Remover anúncios',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onTap: () async {
              if (purchaseProvider.products.isNotEmpty) {
                await purchaseProvider.buyProduct(purchaseProvider.products[0]);
              }
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InAppPurchasePage()),
              );
            },
          ),
          
        ],
      ),
    ),
  ),
),

        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Consumer<SignupProvider>(builder: (context, signupProvider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 360,
                  height: 200,
                  
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(image: ExactAssetImage("assets/pikaso_embed 1.png"),fit: BoxFit.cover)
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          Text(
                            'Masterclass de futebol',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Do iniciante ao profissional: domine\n todos os aspectos do jogo',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>SoccerHomeScreen()));
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(Icons.play_arrow, size: 20),
                            ),
                            label: Text(
                              'Comece a aprender',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        right: -16,
                        bottom: -16,
                        child: Image.network(
                           "${AppConstant.awsBaseUrl}/403/file (45) 1.png" ,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Skill Cards Section
                Text(
                  'Habilidades e dicas de futebol',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text("Melhore o seu jogo com dicas específicas para cada habilidade"),
                SizedBox(height: 10),
                // Skill Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SkillChip(
                          label: 'Drible',
                          isSelected: selectedSkill == 'Drible',
                          onTap: () {
                            setState(() {
                              selectedSkill = 'Drible';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SkillChip(
                          label: 'Passagem',
                          isSelected: selectedSkill == 'Passagem',
                          onTap: () {
                            setState(() {
                              selectedSkill = 'Passagem';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SkillChip(
                          label: 'Dicas de tiro',
                          isSelected: selectedSkill == 'Dicas de tiro',
                          onTap: () {
                            setState(() {
                              selectedSkill = 'Dicas de tiro';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SkillChip(
                          label: 'Defesa',
                          isSelected: selectedSkill == 'Defesa',
                          onTap: () {
                            setState(() {
                              selectedSkill = 'Defesa';
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SkillChip(
                          label: 'Goleiro',
                          isSelected: selectedSkill == 'Goleiro',
                          onTap: () {
                            setState(() {
                              selectedSkill = 'Goleiro';
                            });
                          },
                        ),
                      ),
                       Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SkillChip(
                          label: 'conjunto de peças',
                          isSelected: selectedSkill == 'conjunto de peças',
                          onTap: () {
                            setState(() {
                              selectedSkill = 'conjunto de peças';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              
                // Display the skills based on the selected skill
                if (selectedSkill != null)
                  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures proper spacing
              children: [
                Expanded(
                  child: Text(
                    '${selectedSkill!}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis, // Prevents overflow
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (selectedSkill != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllSkillsScreen(selectedSkill: selectedSkill!),
              ),
            );
                    }
                  },
                  child: Text(
                    "View all",
                    style: TextStyle(color: Colors.black, fontSize: 19),
                  ),
                ),
              ],
            ),
            
                SizedBox(height: 10),
                if (selectedSkill != null)
                  ListView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: skillData[selectedSkill]?.length ?? 0,
  itemBuilder: (context, index) {
    final skill = skillData[selectedSkill]![index];
    final data = skill["data"];
    return Container(
  height: 120,
  margin: EdgeInsets.symmetric(vertical: 10),
  child: Card(
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    color: Colors.white,
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15), // Rounded corners
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
             child: Image.network(
  '${AppConstant.awsBaseUrl}${skill['image']}', // Concatenating the base URL and image path
  fit: BoxFit.cover,
),

            ),
          ),
        ),
        SizedBox(width: 15), // Space between image and text
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                skill["name"],
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8), // Space between name and description
              // Text(
              //   data["subtitle"] ?? "Description not available",
              //   style: TextStyle(
              //     color: Colors.black54,
              //     fontSize: 14,
              //   ),
              //   maxLines: 2,
              //   overflow: TextOverflow.ellipsis,
              // ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15),
          child: IconButton(
            icon: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.lightGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SkillDetailScreen(skillData: data),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
);

  },
)

              ],
          
            );
          }
          ),
        ),
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;  // Callback to update selection

  SkillChip({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,  // Handle tap and call the callback
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? Colors.green : Colors.white,
      ),
    );
  }
}


class Tip {
  final String title;
  final List<String> skills;

  Tip({required this.title, required this.skills});
}
