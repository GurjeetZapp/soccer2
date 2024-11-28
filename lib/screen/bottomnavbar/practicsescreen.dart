import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soccer/apputils/appcolor.dart';
import 'package:soccer/screen/bottomnavbar/Homescreen.dart';

class PractiseScreen extends StatefulWidget {
  @override
  _PractiseScreenState createState() => _PractiseScreenState();
}

class _PractiseScreenState extends State<PractiseScreen> {
  bool showPracticeData = true;
  int _selectedIndex = 0;

  String selectedCategory = 'All';

  String selectedTip = '';
  DateTime selectedDate = DateTime.now();
  TextEditingController timeSlotController = TextEditingController();
  int selectedSets = 1; // Initial value for sets
  String selectedTimeSlot = '';

  // Updated regex to allow valid time formats (e.g., "6am to 7am")
  final RegExp timeSlotValidator =
      RegExp(r'^[0-9]{1,2}[a|p]m\s*to\s*[0-9]{1,2}[a|p]m$');

  final List<String> categories = [
    'All',
    'Dribbling',
    'Shooting',
    'Defending',
    'Passing',
    'Goalkeeping',
    'Set-Pieces'
  ];

  final Map instructionsData = {
    'Power Shots': {
      "instructions": [
        "Coloque cones em uma linha reta.",
        "Drible a bola pelos cones usando toques pequenos e rápidos.",
        "Mantenha a bola próxima aos seus pés o tempo todo.",
        "Concentre-se em manter o controle enquanto aumenta gradualmente sua velocidade."
      ],
      "tipsForSuccess": [
        "Use os dois pés para manter o controle da bola.",
        "Mantenha a cabeça erguida enquanto dribla."
      ]
    }
  };
  final Map<String, List<String>> categoryData = {
    'Dribbling': [
      'Close Control',
      'Dribbling Under Pressure',
      'Speed Dribbling',
      'Ball Handling in Tight Spaces',
      'Shielding the Ball',
      'One-on-One Dribbling'
    ],
    'Shooting': [
      'Power Shots',
      'Finesse Shots',
      'Chip Shots',
      'Volley Shots',
      'Long-Range Shots',
      'Free Kicks'
    ],
    'Defending': [
      'Tackling Techniques',
      'Jockeying',
      'Marking and Positioning',
      'Interceptions',
      'Blocking Shots',
      '1v1 Defending'
    ],
    'Passing': [
      'Short Passes',
      'Long Passes',
      'Through Balls',
      'Crossing the Ball',
      'One-Touch Passing',
      'Switching Play'
    ],
    'Goalkeeping': [
      'Shot Stopping',
      'Positioning',
      'Catching Crosses',
      'Distributing the Ball',
      'Penalty Saves',
      'Diving Technique'
    ],
    'Set-Pieces': [
      'Attacking Corners',
      'Defending Corners',
      'Direct Free Kicks',
      'Indirect Free Kicks',
      'Taking Throw-Ins',
      'Penalty Kicks'
    ],
    'All': [
      'Close Control',
      'Dribbling Under Pressure',
      'Speed Dribbling',
      'Ball Handling in Tight Spaces',
      'Shielding the Ball',
      'One-on-One Dribbling',
      'Power Shots',
      'Finesse Shots',
      'Chip Shots',
      'Volley Shots',
      'Long-Range Shots',
      'Free Kicks',
      'Tackling Techniques',
      'Jockeying',
      'Marking and Positioning',
      'Interceptions',
      'Blocking Shots',
      '1v1 Defending',
      'Short Passes',
      'Long Passes',
      'Through Balls',
      'Crossing the Ball',
      'One-Touch Passing',
      'Switching Play',
      'Shot Stopping',
      'Positioning',
      'Catching Crosses',
      'Distributing the Ball',
      'Penalty Saves',
      'Diving Technique',
      'Attacking Corners',
      'Defending Corners',
      'Direct Free Kicks',
      'Indirect Free Kicks',
      'Taking Throw-Ins',
      'Penalty Kicks'
    ]
  };
  void _onToggleButton(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> uploadToFirebase(
      String userId, // The user's unique ID to locate their document
      String category,
      String tip,
      String timeSlot,
      int sets,
      String date,
      instructions,
      tipsForSuccess) async {
    try {
      // Reference to the user's document
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Map representing the new practice data
      final newPracticeData = {
        'category': category,
        'tip': tip,
        'time': timeSlot,
        'sets': sets,
        'timestamp': Timestamp.now(), // Firestore timestamp
        'date': date,
        'instructionsData': instructions,
        'tipsForSuccess': tipsForSuccess
        // Ensure this is in the correct format, e.g., "2024-11-28"
      };

      // Add the new data to the `practice` array
      await userDocRef.update({
        'practice': FieldValue.arrayUnion([newPracticeData]),
      });

      print('Practice data added successfully!');
    } catch (e) {
      print('Failed to add practice data: $e');
    }
  }

  void showPopup(BuildContext context, String category, String tip) {
    TextEditingController dateController = TextEditingController();
    List<String> timeSlotOptions = [
      '6am to 7am',
      '7am to 8am',
      '8am to 9am',
      '9am to 10am',
      '10am to 11am',
      '6pm to 7pm',
      '7pm to 8pm'
    ];
    String selectedTimeSlot = timeSlotOptions[0];
    int selectedSets = 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(),
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: StatefulBuilder(
                    builder: (BuildContext context, setState) {
                      return Stack(
                        children: [
                          // Cross Icon
                          Positioned(
                            top: 0,
                            left: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),

                          // Popup Content
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      tip,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),

                              // Date Picker
                              Text(
                                'Pick a Date',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 10),
                              GestureDetector(
                                onTap: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      dateController.text =
                                          DateFormat('dd/MM/yyyy')
                                              .format(pickedDate);
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.white54),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateController.text.isEmpty
                                            ? 'Select Date'
                                            : dateController.text,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(Icons.calendar_today,
                                          color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),

                              // Time Slot Dropdown
                              Text(
                                'Choose a Time Slot',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.white54),
                                ),
                                child: DropdownButton<String>(
                                  dropdownColor: Colors.white.withOpacity(0.8),
                                  value: selectedTimeSlot,
                                  isExpanded: true,
                                  underline: SizedBox(),
                                  items: timeSlotOptions.map((String slot) {
                                    return DropdownMenuItem<String>(
                                      value: slot,
                                      child: Text(
                                        slot,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedTimeSlot = newValue!;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 20),

                              // Sets Counter
                              Text(
                                'How Many Sets?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  FloatingActionButton(
                                    mini: true,
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    onPressed: () {
                                      setState(() {
                                        if (selectedSets > 1) selectedSets--;
                                      });
                                    },
                                    child: Icon(Icons.remove),
                                  ),
                                  Text(
                                    '$selectedSets',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  FloatingActionButton(
                                    mini: true,
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                    onPressed: () {
                                      setState(() {
                                        if (selectedSets < 100) selectedSets++;
                                      });
                                    },
                                    child: Icon(Icons.add),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Upload Button
                              Center(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 60),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    shadowColor: Colors.amberAccent,
                                    elevation: 15,
                                  ),
                                  onPressed: () async {
                                    final String? userId = await getUserId();
                                    if (userId != null) {
                                      await uploadToFirebase(
                                          userId,
                                          category,
                                          tip,
                                          selectedTimeSlot,
                                          selectedSets,
                                          dateController.text,
                                          instructionsData[category]
                                              ["instructions"],
                                          instructionsData[category]
                                              ["tipsForSuccess"]);
                                      Navigator.pop(context);
                                    } else {
                                      print(
                                          'User not logged in. Unable to upload data.');
                                    }
                                  },
                                  child: Text(
                                    'Add Practice',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  final Map<String, List<Map<String, dynamic>>> skillData = {
    'Drible': [
      {
        'name': 'Fechar controle',
        "image": "assets/1.webp",
        'data': {
          "title": "1. Drible: Controle Próximo",
          "subtitle": "Domine suas habilidades de controle próximo",
          "description":
              "O controle próximo é a capacidade de manter a bola perto dos pés enquanto se movimenta ao redor dos oponentes. É uma habilidade vital para jogadores atacantes em espaços apertados.",
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
        },
        "instructions": [
          "Coloque cones em uma linha reta.",
          "Drible a bola pelos cones usando toques pequenos e rápidos.",
          "Mantenha a bola próxima aos seus pés o tempo todo.",
          "Concentre-se em manter o controle enquanto aumenta gradualmente sua velocidade."
        ],
        "": {
          "Dribbling: Close Control": {
            "practice": "Dribles de Controle Próximo",
            "instructions": [
              "Coloque cones em uma linha reta.",
              "Drible a bola pelos cones usando toques pequenos e rápidos.",
              "Mantenha a bola próxima aos seus pés o tempo todo.",
              "Concentre-se em manter o controle enquanto aumenta gradualmente sua velocidade."
            ],
            "tipsForSuccess": [
              "Use os dois pés para manter o controle da bola.",
              "Mantenha a cabeça erguida enquanto dribla."
            ]
          },
        }
      },
      {
        'name': 'Drible sob pressão',
        "image": "assets/2.webp",
        'data': {
          "title": "2. Drible: Sob Pressão",
          "subtitle": "Desenvolva sua habilidade de driblar sob pressão",
          "description":
              "Driblar sob pressão é manter o controle da bola enquanto os oponentes se aproximam. É crucial para decisões rápidas e retenção da bola em situações apertadas.",
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
        "image": "assets/3.webp",
        'data': {
          "title": "3. Drible: Velocidade",
          "subtitle": "Aumente sua velocidade de drible",
          "description":
              "O drible em velocidade é a capacidade de mover a bola rapidamente enquanto mantém o controle, permitindo que os jogadores se afastem dos defensores ou explorem espaços abertos.",
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
        "image": "assets/4.webp",
        'data': {
          "title": "4. Drible: Controle em Espaços Apertados",
          "subtitle": "Domine o controle da bola em áreas confinadas",
          "description":
              "O controle da bola em espaços apertados refere-se a manter a posse em áreas congestionadas, onde movimentos rápidos e decisões são essenciais.",
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
        "image": "assets/5.webp",
        'data': {
          "title": "5. Drible: Protegendo a Bola",
          "subtitle": "Proteja a bola dos oponentes",
          "description":
              "Proteger a bola envolve usar o corpo para mantê-la longe dos oponentes, dando tempo para fazer um passe ou se movimentar.",
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
        "image": "assets/2.webp",
        'data': {
          "title": "6. Drible: Um Contra Um",
          "subtitle": "Supere os defensores em situações um contra um",
          "description":
              "O drible 1v1 é a habilidade de enfrentar e vencer um defensor em um duelo frente a frente, usando habilidades e decisões rápidas.",
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
  };

  Future<String?> getUserId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid; // This is the unique user ID
    }
    return null; // User not logged in
  }

  bool _validateTimeSlot() {
    // Return true if the time slot is valid, false otherwise
    return timeSlotValidator.hasMatch(selectedTimeSlot);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MainScreen()));
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(124, 12, 17, 1),
        title: Text(
          'Practice',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Row(
            children: [
              SizedBox(width: 15),
              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                selectedColor: Colors.white,
                fillColor: Colors.green,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Practice Data',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '     My Practice    ',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
                isSelected: [showPracticeData, !showPracticeData],
                onPressed: (int index) {
                  setState(() {
                    showPracticeData = index == 0;
                  });
                },
              ),
              SizedBox(width: 5),
              // ElevatedButton(
              //   onPressed: () {
              //     _selectDate(context);
              //   },
              //   child: Row(
              //     children: [
              //       Icon(Icons.calendar_today),
              //       SizedBox(width: 3),
              //       Text(
              //         '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              //         style: TextStyle(fontSize: 16),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 10),
          if (showPracticeData)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (selected) {
                        setState(() {
                          selectedCategory = selected ? category : 'All';
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          SizedBox(height: 15),
          showPracticeData
              ? Expanded(
                  child: ListView.builder(
                    itemCount: categoryData[selectedCategory]?.length ?? 0,
                    itemBuilder: (context, index) {
                      String tip = categoryData[selectedCategory]?[index] ?? '';

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 5,
                          child: ListTile(
                            title: Text(tip),
                            trailing: GestureDetector(
                                onTap: () {
                                  showPopup(context, tip, selectedCategory);
                                },
                                child: Icon(
                                  Icons.add,
                                  color: Colors.black,
                                )),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Expanded(
                  child: PracticeDetailsScreen(userId: userId.toString()),
                ),
        ],
      ),
    );
  }
}

class PracticeDetailsScreen extends StatefulWidget {
  final String userId;
  PracticeDetailsScreen({required this.userId});

  @override
  State<PracticeDetailsScreen> createState() => _PracticeDetailsScreenState();
}

class _PracticeDetailsScreenState extends State<PracticeDetailsScreen> {
  void updateTaskStatus(String category, bool skipped) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception("User not logged in");
      }

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Fetch the user's practice data
      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final practiceArray = userData['practice'] as List<dynamic>? ?? [];

        final practiceIndex = practiceArray.indexWhere(
          (element) => element['category'] == category,
        );

        if (practiceIndex != -1) {
          // Task exists, update the status (don't reset, just update)
          practiceArray[practiceIndex]['skipped'] = skipped;
        } else {
          // Task doesn't exist, add a new task entry
          practiceArray.add({
            'category': category,
            'completed': false, // Initially, it's marked as not done
            'skipped': skipped,
          });
        }

        // Update the Firestore record
        await userDoc.update({
          'practice': practiceArray,
        });

        setState(() {}); // Trigger UI update
      }
    } catch (e) {
      print("Error updating task status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Soft light grey background
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data found'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final practiceArray = userData['practice'] as List<dynamic>? ?? [];

          // Filter out completed tasks
          final uncompletedPractices = practiceArray
              .where((practice) =>
                  practice is Map<String, dynamic> &&
                  !(practice['completed'] ?? false))
              .toList();

          if (uncompletedPractices.isEmpty) {
            return Center(child: Text('No practice data available'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: uncompletedPractices.length,
            itemBuilder: (context, index) {
              final practice =
                  uncompletedPractices[index] as Map<String, dynamic>;

              return PracticeCard(
                practice: practice,
              );
            },
          );
        },
      ),
    );
  }
}

class PracticeCard extends StatefulWidget {
  final Map<String, dynamic> practice;

  const PracticeCard({Key? key, required this.practice}) : super(key: key);

  @override
  _PracticeCardState createState() => _PracticeCardState();
}

class _PracticeCardState extends State<PracticeCard> {
  bool skipClicked = false;

  @override
  void initState() {
    super.initState();
    _getSkipStatus();
  }

  Future<void> _getSkipStatus() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception("User not logged in");
      }

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final snapshot = await userDoc.get();

      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final practiceArray = userData['practice'] as List<dynamic>? ?? [];

        final practice = practiceArray.firstWhere(
          (element) {
            final elementTimestamp = element['timestamp'] as Timestamp?;
            return elementTimestamp != null &&
                elementTimestamp.toDate() ==
                    widget.practice['timestamp'].toDate();
          },
          orElse: () => null,
        );

        setState(() {
          skipClicked = practice != null ? practice['skipped'] ?? false : false;
        });
      }
    } catch (e) {
      print("Error fetching skip status: $e");
    }
  }

  Future<void> _markTaskAsSkipped(Timestamp timestamp) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception("User not logged in");
      }

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final snapshot = await userDoc.get();

      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final practiceArray = userData['practice'] as List<dynamic>? ?? [];

        final practiceIndex = practiceArray.indexWhere(
          (element) {
            final elementTimestamp = element['timestamp'] as Timestamp?;
            return elementTimestamp != null &&
                elementTimestamp.toDate() == timestamp.toDate();
          },
        );

        if (practiceIndex != -1) {
          practiceArray[practiceIndex]['skipped'] = true;
        } else {
          practiceArray.add({
            'timestamp': timestamp,
            'skipped': true,
          });
        }

        await userDoc.update({'practice': practiceArray});

        setState(() {
          skipClicked = true;
        });
      }
    } catch (e) {
      print("Error marking task as skipped: $e");
    }
  }

  void _handleSkipTask(Timestamp timestamp) {
    _markTaskAsSkipped(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final practice = widget.practice;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 204, 195, 195),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Practice Category and Tip
          Row(
            children: [
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      practice['category'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(124, 12, 17, 1),
                        letterSpacing: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.pink[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        practice['tip'] ?? 'No Tip',
                        style: TextStyle(
                          color: Color.fromRGBO(124, 12, 17, 1),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          // Time and Sets Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time,
                      color: Color.fromRGBO(124, 12, 17, 1), size: 20),
                  SizedBox(width: 8),
                  Text(
                    practice['time'] ?? 'Unknown',
                    style: TextStyle(
                      color: Color.fromRGBO(124, 12, 17, 1),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.add_box,
                      color: Color.fromRGBO(124, 12, 17, 1), size: 20),
                  SizedBox(width: 8),
                  Text(
                    '${practice['sets'] ?? 0} Sets',
                    style: TextStyle(
                      color: Color.fromRGBO(124, 12, 17, 1),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 15),
          // Date Row
          Row(
            children: [
              Icon(Icons.date_range, color: Colors.pink[300], size: 20),
              SizedBox(width: 8),
              Text(
                practice['date'] ?? 'No Date',
                style: TextStyle(
                  color: Color.fromRGBO(124, 12, 17, 1),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          SizedBox(height: 15),
          // Skip and Start Buttons
          skipClicked
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(124, 12, 17, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Task Skipped',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _handleSkipTask(widget.practice['timestamp']);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(124, 12, 17, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!skipClicked) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StartPracticeScreen(
                                title: practice['category'] ?? 'Unknown',
                                practice: practice['tip'] ?? 'No Tip',
                                timeSlot: practice["time"],
                                targetSets: practice["sets"],
                                instructions: practice["instructionsData"]?? [],
                                tipsForSuccess:practice["tipsForSuccess"]??[],
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(124, 12, 17, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Start Practice',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class StartPracticeScreen extends StatefulWidget {
  final int targetSets;
  final String timeSlot;
  final String title;
  final String practice;
  final List instructions;
  final List tipsForSuccess;

  StartPracticeScreen({
    required this.targetSets,
    required this.timeSlot,
    required this.title,
    required this.practice,
    required this.instructions, required this.tipsForSuccess
  });

  @override
  _StartPracticeScreenState createState() => _StartPracticeScreenState();
}

class _StartPracticeScreenState extends State<StartPracticeScreen> {
  int completedSets = 0;
  bool isPaused = false;
  int remainingSeconds = 3600; // Example: 1 hour in seconds

  @override
  void initState() {
    super.initState();
    _loadCompletedSets();
  }

  Future<void> _loadCompletedSets() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception("User not logged in");
      }

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final snapshot = await userDoc.get();
      final practices =
          List<Map<String, dynamic>>.from(snapshot.data()?['practice'] ?? []);

      // Find the specific practice by 'tip'
      final practiceIndex = practices
          .indexWhere((practice) => practice['category'] == widget.title);

      if (practiceIndex != -1) {
        setState(() {
          // Load completedSets for the specific practice
          completedSets = practices[practiceIndex]['completedSets'] ?? 0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading completed sets: $e')),
      );
    }
  }

  Future<void> _updateCompletedSets() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception("User not logged in");
      }

      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final snapshot = await userDoc.get();
      final practices =
          List<Map<String, dynamic>>.from(snapshot.data()?['practice'] ?? []);

      // Find the specific practice by 'tip'
      final practiceIndex = practices
          .indexWhere((practice) => practice['category'] == widget.title);

      if (practiceIndex != -1) {
        // Update only the completedSets for the specific practice
        practices[practiceIndex]['completedSets'] = completedSets;

        await userDoc.update({'practice': practices});
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating completed sets: $e')),
      );
    }
  }

  void _togglePauseResume() {
    setState(() {
      isPaused = !isPaused;
    });
  }

  Future<void> _showCompletionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Practice Completed'),
          content: const Text('You have completed this practice session.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    // Mark the task as completed in Firebase
    await _markTaskAsCompleted();
  }

  Future<void> _markTaskAsCompleted() async {
    try {
      // Fetch the current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        throw Exception("User not logged in");
      }

      // Reference to the user's document in the Firestore
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Fetch the user's practice array
      final snapshot = await userDoc.get();
      final practices =
          List<Map<String, dynamic>>.from(snapshot.data()?['practice'] ?? []);
      print(practices);
      print(widget.title);
      // Find the practice to update
      final practiceIndex = practices
          .indexWhere((practice) => practice['category'] == widget.title);

      if (practiceIndex != -1) {
        print("Asdfasdfasdfsdfasdf");
        print(practiceIndex);
        practices[practiceIndex]['completed'] = true;

        // Update the practice array in Firestore
        await userDoc.update({'practice': practices});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Practice marked as completed.')),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PractiseScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Practice not found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating practice: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(124, 12, 17, 1),
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
                      ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (widget.instructions?.length ?? 0),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '\u2022 ', // Bullet point
                        style: TextStyle(fontSize: 16),
                      ),
                      Expanded(
                        child: Text(
                          widget.instructions[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Tips for Success Section
          

                      Text(
                        widget.practice,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Target set: ${widget.targetSets}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Completed sets',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      color: Colors.red),
                                  onPressed: () async {
                                    if (completedSets > 0) {
                                      setState(() {
                                        completedSets--;
                                      });
                                      await _updateCompletedSets();
                                    }
                                  },
                                ),
                                Text(
                                  '$completedSets',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      color: Colors.green),
                                  onPressed: () async {
                                    if (completedSets < widget.targetSets) {
                                      setState(() {
                                        completedSets++;
                                      });
                                      await _updateCompletedSets();
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: completedSets >= widget.targetSets
                                  ? _showCompletionDialog
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Complete Practice',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                        const Text(
              'Tips for Success:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
                          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (widget.tipsForSuccess?.length ?? 0),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '\u2022 ', // Bullet point
                        style: TextStyle(fontSize: 16),
                      ),
                      Expanded(
                        child: Text(
                          widget.tipsForSuccess[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          
            
                    ]))));
  }

  String formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
