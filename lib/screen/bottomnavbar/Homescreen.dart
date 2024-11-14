import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer/Auth/log_in.dart';
import 'package:soccer/Auth/provider.dart';

import 'package:soccer/provider/inapppurcahse.dart';
import 'package:soccer/provider/inappropriate.dart';


class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // List of screens to navigate between
  final List<Widget> _screens = [
    HomeScreen(),
    PracticeScreen(),
    StatisticsScreen(),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.red,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Lar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run),
            label: 'Prática',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estatística',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Minha conta',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  Widget build(BuildContext context) {
    
       final signupProvider = Provider.of<SignupProvider>(context);

    final PurchaseProvider purchaseProvider = Provider.of(context);

      return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white38,
        automaticallyImplyLeading: false,

        title: 
            Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 20,
              child: Icon(Icons.person, color: Colors.white),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bem–vindo', style: TextStyle(color: Colors.black,fontSize: 18)),
                Text('User', style: TextStyle(color: Colors.black45,fontSize: 14)),
              ],
            ),
           
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: Drawer(
        child: Container(
          color: Color(0xFF263238),
          child: SingleChildScrollView(
            // Remove Column and directly use ListView
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  currentAccountPicture: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (signupProvider.profileImageUrl != null &&
                            signupProvider.profileImageUrl!.isNotEmpty &&
                            (signupProvider.profileImageUrl!
                                    .startsWith('http://') ||
                                signupProvider.profileImageUrl!
                                    .startsWith('https://')))
                        ? NetworkImage(signupProvider.profileImageUrl!)
                        : AssetImage('img/Ellipse 2.png') as ImageProvider,
                  ),
                  accountName: null, // Ensure this is not null
                  accountEmail: null, // Ensure this is not null
                ),
                // Replace this with just one Drawer and remove the nested one
                ListTile(
                  leading: Icon(Icons.person, color: Colors.white),
                  title:
                      Text('Meu perfil', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  },
                ),

                InkWell(
                  splashColor: Color.lerp(Colors.white, Colors.white, 0.4),
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    if (purchaseProvider.products.isNotEmpty) {
                      await purchaseProvider
                          .buyProduct(purchaseProvider.products[0]);
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InAppPurchasePage()));
                  },
                  child: Container(
                    // Added Container for better hit area
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.remove_circle_outline_rounded,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8), // Add spacing
                        Text(
                          "Remover anúncios",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                // Restore Purchases section
                InkWell(
                  splashColor: Color.lerp(Colors.red, Colors.white, 0.4),
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    if (purchaseProvider.products.isNotEmpty) {
                      await purchaseProvider.restoreItem();
                    }
                    Navigator.pop(context);
                  },
                  child: Container(
                    // Added Container for better hit area
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        Icon(Icons.restore, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Restaurar compras",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                ListTile(
                  leading: Icon(
                    signupProvider.isGuest ? Icons.login : Icons.logout,
                    color: Colors.white,
                  ),
                  title: Text(
                    signupProvider.isGuest ? 'Conecte_se' : "Sair",
                    style: TextStyle(color: Colors.white),
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
                  title: Text('Excluir conta',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Provider.of<SignupProvider>(context, listen: false)
                        .deleteAccount(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Masterclass Card
Container(
  width: 360,
  height: 200,
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.red,
    borderRadius: BorderRadius.circular(15),
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
            onPressed: () {},
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
      // Positioned image on the right side of the ElevatedButton
      Positioned(
        right: -16,
        bottom:-16,
        child: Image.asset(
          "assets/file (45) 1.png",
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    ],
  ),
),

            SizedBox(height: 20),

            // Skills Section
            Text(
              'Habilidades e dicas de futebol',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Melhore o seu jogo com dicas específicas para cada habilidade',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 10),

            // Skills Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SkillChip(label: 'Drible', isSelected: true),
                SkillChip(label: 'Passagem'),
                SkillChip(label: 'Tiroteio'),
                SkillChip(label: 'Defesa'),
                SkillChip(label: 'Goleiro'),
              ],
            ),
            SizedBox(height: 20),

            // Dribble Tips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dicas de drible', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Ver tudo', style: TextStyle(color: Colors.blue)),
              ],
            ),
            SizedBox(height: 10),
            // Tips List
            TipCard(),
            TipCard(),
            TipCard(),
            TipCard(),
          ],
        ),
      ),
        )
    );
  }
}

class PracticeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Prática')),
    );
  }
}

class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Estatística')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Minha conta')),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  SkillChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
        selectedColor: Colors.green,
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.asset('assets/soccer.png', width: 50, height: 50, fit: BoxFit.cover), // Add your own image asset here
        title: Text('Close control'),
        trailing: Icon(Icons.play_circle_outline, color: Colors.green),
      ),
    );
  }
}
