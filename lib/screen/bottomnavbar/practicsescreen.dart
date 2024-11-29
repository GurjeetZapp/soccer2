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

  String selectedCategory = 'Dribles';

  String selectedTip = '';
  DateTime selectedDate = DateTime.now();
  TextEditingController timeSlotController = TextEditingController();
  int selectedSets = 1; // Initial value for sets
  String selectedTimeSlot = '';

  // Updated regex to allow valid time formats (e.g., "6am to 7am")
  final RegExp timeSlotValidator =
      RegExp(r'^[0-9]{1,2}[a|p]m\s*to\s*[0-9]{1,2}[a|p]m$');

 final List<String> categories = [
   
    
   


'Dribles',
'Passes',
'Defesa',
'Passando',
'Goleiro',
'conjunto de peças'
];


 final Map instructionsData = {
  'Fechar controle':{
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
  'Sob pressão':{ "instructions": [
      "Configure uma pequena área com cones para simular espaços apertados.",
      "Peça a um parceiro ou treinador para aplicar leve pressão enquanto você dribla.",
      "Concentre-se em tomar decisões rápidas e manter a posse sob pressão.",
      "Use ambos os pés para manter a bola imprevisível."
    ],
    "tipsForSuccess": [
      "Permaneça calmo e composto quando os defensores se aproximarem.",
      "Mantenha a cabeça erguida para identificar aberturas e passes."
    ]},
    'Drible de velocidade':{"instructions": [
      "Coloque cones em linha reta com lacunas maiores entre eles.",
      "Drible a bola em alta velocidade, usando toques grandes em espaços abertos.",
      "Diminua a velocidade e dê toques menores ao se aproximar de áreas mais estreitas.",
      "Concentre-se na transição entre velocidade e controle."
    ],
    "tipsForSuccess": [
      "Empurre a bola com a parte superior do pé para melhor controle de velocidade.",
      "Sempre olhe para cima para monitorar seus arredores."
    ]},
    'Manuseio de bola em espaços apertados':{"instructions": [
      "Use uma grade pequena marcada com cones para criar uma área apertada.",
      "Pratique movimentar a bola rapidamente usando toques pequenos e frequentes.",
      "Incorpore fintas corporais e giros para evitar defensores imaginários.",
      "Concentre-se em permanecer equilibrado e controlado durante todo o tempo."
    ],
    "tipsForSuccess": [
      "Use seu corpo para proteger a bola em áreas apertadas.",
      "Mantenha seus movimentos imprevisíveis com mudanças repentinas de direção."
    ]},
    'Protegendo a bola':{ "instructions": [
      "Pratique proteger a bola com as costas para um defensor.",
      "Concentre-se em usar seu corpo para bloquear o defensor de alcançar a bola.",
      "Dobre levemente os joelhos para manter um centro de gravidade baixo.",
      "Use os braços (sem cometer faltas) para manter distância do defensor."
    ],
    "tipsForSuccess": [
      "Mantenha seu corpo entre o defensor e a bola.",
      "Permaneça equilibrado e evite depender excessivamente de seus braços."
    ]},
    'Dribles um contra um':{"instructions": [
      "Configure uma pequena área e revezem-se sendo o atacante e o defensor.",
      "Pratique usar fintas e mudanças rápidas de direção para superar seu oponente.",
      "Concentre-se em cronometrar seus movimentos para explorar erros defensivos.",
      "Acelere rapidamente após superar seu oponente."
    ],
    "tipsForSuccess": [
      "Use uma variedade de movimentos para permanecer imprevisível.",
      "Seja confiante e comprometa-se com suas decisões."
    ]},

     'Chutes Poderosos':{"instructions": [
      "Configure uma área de prática com cones como alvos à distância.",
      "Use a parte superior do pé (cadarços) para chutar a bola com força.",
      "Posicione o pé de apoio firmemente ao lado da bola para estabilidade.",
      "Concentre-se em seguir o movimento após o chute para gerar mais força."
    ],
    "tipsForSuccess": [
      "Evite inclinar-se muito para trás para não enviar a bola acima do gol.",
      "Pratique acertar o centro ou a parte inferior da bola para potência máxima."
    ]}  ,
    'Chutes Colocados':{ "instructions": [
      "Configure cones nos cantos do gol para praticar a precisão.",
      "Use o lado interno do pé para adicionar curva ao chute.",
      "Concentre-se em mirar nos cantos do gol, longe do goleiro.",
      "Siga a curva do chute com o movimento do corpo para maior precisão."
    ],
    "tipsForSuccess": [
      "Mantenha o equilíbrio durante o chute para melhor controle.",
      "Pratique encontrar o equilíbrio entre curva e força no chute."
    ]},
    'Chutes de Cavadinha':{ "instructions": [
      "Pratique chutar a bola com um toque leve na parte inferior para levantá-la.",
      "Use a ponta do pé ou a parte de dentro do pé para controle.",
      "Concentre-se em levantar a bola sobre um goleiro imaginário.",
      "Avalie a posição do goleiro antes de decidir pela cavadinha."
    ],
    "tipsForSuccess": [
      "Use um toque suave para evitar enviar a bola muito longe.",
      "Certifique-se de levantar a bola o suficiente para superar o goleiro."
    ]},
    'Chutes de Voleio':{ "instructions": [
      "Configure uma área de prática com um parceiro cruzando a bola para você.",
      "Concentre-se em cronometrar o chute para acertar a bola no ar.",
      "Use os cadarços ou o lado interno do pé para controlar o chute.",
      "Mantenha o equilíbrio, inclinando-se levemente para frente durante o chute."
    ],
    "tipsForSuccess": [
      "Foque na bola enquanto ela cai para acertar no momento certo.",
      "Evite inclinar-se muito para trás para manter o chute direcionado ao gol."
    ]},
    'Chutes de Longa Distância':{ "instructions": [
      "Configure cones no gol para praticar a precisão de longa distância.",
      "Use os cadarços para gerar potência nos chutes de fora da área.",
      "Concentre-se em mirar nos cantos inferiores para dificultar a defesa do goleiro.",
      "Complete o movimento do chute para maximizar a precisão e a distância."
    ],
    "tipsForSuccess": [
      "Pratique ler a posição do goleiro antes de chutar.",
      "Evite chutar sem seguir o movimento para garantir potência e precisão."
    ]},
    'Cobranças de Falta':{ "instructions": [
      "Configure uma barreira com cones ou manequins para simular adversários.",
      "Use o lado interno ou os cadarços para chutar, dependendo da técnica desejada.",
      "Pratique adicionar curva ao chute para superar a barreira.",
      "Concentre-se em mirar nos cantos superiores ou inferiores do gol."
    ],
    "tipsForSuccess": [
      "Evite apressar o chute; tome seu tempo para alinhar e focar.",
      "Certifique-se de seguir o movimento para concluir o chute com força ou curva."
    ]},
    'Técnicas de Desarme':{"instructions": [
      "Pratique desarmes em um treino 1v1 com um parceiro.",
      "Foque no tempo e na precisão para ganhar a bola sem cometer faltas.",
      "Experimente desarmes em pé e carrinhos em situações simuladas.",
      "Evite comprometer-se cedo; mantenha o equilíbrio e espere o momento certo."
    ],
    "tipsForSuccess": [
      "Cronometre seu desarme para acertar a bola primeiro.",
      "Evite se comprometer demais e se expor ao ataque."
    ]},
    '"Marcação com Contenção':{ "instructions": [
      "Posicione-se entre o atacante e o gol para limitar as opções do adversário.",
      "Mantenha o centro de gravidade baixo para reagir rapidamente.",
      "Use movimentos laterais rápidos para acompanhar o atacante.",
      "Evite comprometer-se; mantenha a paciência e espere pelo erro do atacante."
    ],
    "tipsForSuccess": [
      "Concentre-se em direcionar o atacante para áreas menos perigosas.",
      "Não mergulhe no desarme cedo demais; mantenha sua posição."
    ]},
    'Marcação e Posicionamento':{ "instructions": [
      "Pratique ficar próximo ao jogador adversário que você está marcando.",
      "Posicione-se entre o adversário e o gol para bloquear o caminho.",
      "Leia o jogo e ajuste sua posição para interceptar passes ou bloquear chutes.",
      "Mantenha os olhos no adversário e na bola ao mesmo tempo."
    ],
    "tipsForSuccess": [
      "Evite assistir apenas à bola; mantenha o adversário em sua visão.",
      "Fique em posição de reação para acompanhar os movimentos rápidos."
    ]},
    'Intercepções':{ "instructions": [
      "Pratique posicionar-se nas linhas de passe para interceptar a bola.",
      "Leia os movimentos do adversário para antecipar passes.",
      "Concentre-se em reagir rapidamente quando a bola for passada.",
      "Use jogos em pequenos espaços para simular situações de interceptação."
    ],
    "tipsForSuccess": [
      "Não se apresse para interceptar; espere a oportunidade certa.",
      "Sempre esteja ciente de onde estão os adversários e seus companheiros."
    ]},
    'Bloqueio de Chutes':{"instructions": [
      "Posicione-se no caminho do chute para bloquear a bola.",
      "Mantenha o equilíbrio e esteja pronto para mover-se rapidamente.",
      "Use o corpo para bloquear o chute sem expor as mãos ou braços.",
      "Comprometa-se totalmente ao bloqueio para impedir que a bola passe."
    ],
    "tipsForSuccess": [
      "Nunca vire as costas para a bola ao tentar bloquear.",
      "Evite hesitar; comprometa-se completamente ao bloqueio."
    ]},
    'Defesa 1v1':{ "instructions": [
      "Posicione-se de forma lateral ao atacante para mostrar o lado menos perigoso.",
      "Espere o momento certo para atacar a bola; não se precipite.",
      "Mantenha o equilíbrio e esteja pronto para mudar de direção rapidamente.",
      "Pratique enfrentar atacantes em espaços apertados, focando em tempo e posicionamento."
    ],
    "tipsForSuccess": [
      "Force o atacante a cometer um erro antes de atacar a bola.",
      "Não dê muito espaço para o atacante ganhar velocidade."
    ]},
    'Passes Curtos':{"instructions": [
      "Use a parte interna do pé para passes curtos e precisos.",
      "Pratique passes rápidos com um parceiro, focando na precisão.",
      "Mantenha a bola no chão para facilitar o controle do companheiro.",
      "Acompanhe o passe com o movimento do corpo para estabilidade."
    ],
    "tipsForSuccess": [
      "Evite bater na bola com muita força; mantenha o passe controlado.",
      "Sempre olhe para o movimento do seu companheiro antes de passar."
    ]},
    'Passes Longos':{ "instructions": [
      "Use o peito do pé para realizar passes longos com força e precisão.",
      "Pratique levantar a bola para alcançar companheiros em áreas distantes.",
      "Ajuste a força do passe para evitar que ele seja muito curto ou longo.",
      "Mire no alvo e siga com o movimento para garantir a precisão."
    ],
    "tipsForSuccess": [
      "Certifique-se de levantar a bola o suficiente para evitar defensores.",
      "Foque na precisão ao invés de apenas força."
    ]},
    'Passes em Profundidade':{ "instructions": [
      "Sincronize o passe com a corrida do seu companheiro de equipe.",
      "Pratique encontrar espaços entre os defensores para passar a bola.",
      "Use o peso correto no passe para que seu companheiro possa alcançá-lo.",
      "Acompanhe o movimento da defesa para identificar lacunas."
    ],
    "tipsForSuccess": [
      "Evite passar a bola cedo ou tarde demais; o tempo é crucial.",
      "Certifique-se de que o passe seja direto e preciso."
    ]},
    'Cruzamento d':{"instructions": [
      "Levante a cabeça antes de cruzar para localizar seus companheiros.",
      "Use o interior do pé para adicionar curva ao cruzamento.",
      "Mire no poste traseiro para dar tempo aos atacantes de se posicionarem.",
      "Pratique cruzamentos em diferentes ângulos para melhorar a precisão."
    ],
    "tipsForSuccess": [
      "Evite cruzar sem verificar o posicionamento dos companheiros.",
      "Certifique-se de dar força suficiente para que o cruzamento supere os defensores."
    ]
  },
    'Passes de Primeira':{ "instructions": [
      "Antecipe onde a bola vai antes de recebê-la para um passe rápido.",
      "Use o interior do pé para melhor controle e precisão.",
      "Pratique passes de primeira em um jogo pequeno para melhorar sua velocidade.",
      "Foque em manter o equilíbrio durante o passe para maior estabilidade."
    ],
    "tipsForSuccess": [
      "Trabalhe no seu primeiro toque para preparar passes rápidos.",
      "Evite hesitar; tome decisões rápidas para manter o jogo fluido."
    ]},
    'Mudança de Jogo':{"instructions": [
      "Levante a bola por cima dos defensores para mudar de lado.",
      "Pratique passes longos para alcançar companheiros em áreas abertas.",
      "Leia o campo antes de receber a bola para planejar a troca de jogo.",
      "Use o pé externo para passes curvados em distâncias curtas."
    ],
    "tipsForSuccess": [
      "Sempre verifique suas opções antes de mudar o jogo.",
      "Evite subestimar a força necessária para alcançar o outro lado."
    ]},
     'Defesa de Chutes':{ "instructions": [
      "Mantenha uma posição central no gol para cobrir ambos os lados.",
      "Pratique reflexos rápidos para reagir a chutes de diferentes ângulos.",
      "Decida se vai segurar ou desviar a bola, dependendo da força do chute.",
      "Use as mãos e o corpo para bloquear chutes com segurança."
    ],
    "tipsForSuccess": [
      "Não se comprometa cedo demais ao mergulhar; espere para reagir.",
      "Mantenha as mãos prontas e na posição correta para defender chutes."
    ]},
    'Posicionamento':{ "instructions": [
      "Mantenha-se centralizado em relação à bola e ao gol.",
      "Ajuste sua posição com base na localização da bola no campo.",
      "Avance ligeiramente para reduzir o ângulo de chute do atacante.",
      "Fique atento a mudanças rápidas na direção da jogada."
    ],
    "tipsForSuccess": [
      "Evite ficar muito próximo da linha do gol; avance quando necessário.",
      "Esteja sempre em movimento para ajustar seu posicionamento."
    ]},
    'Defesa de Cruzamentos':{ "instructions": [
      "Cronometre seu salto para alcançar a bola no ponto mais alto.",
      "Segure a bola com as duas mãos para maior controle.",
      "Comunique-se claramente com os defensores antes de sair para interceptar.",
      "Pratique posicionar-se corretamente em relação ao cruzamento."
    ],
    "tipsForSuccess": [
      "Evite pular cedo ou tarde demais; cronometre o salto com precisão.",
      "Certifique-se de comunicar suas intenções para evitar confusões."
    ]},
    
    'Distribuição da Bola':{"instructions": [
      "Use arremessos curtos para passes precisos a companheiros próximos.",
      "Pratique chutes longos para alcançar jogadores avançados.",
      "Analise o campo antes de distribuir a bola para evitar perdas.",
      "Ajuste sua técnica para chutes e lançamentos em diferentes distâncias."
    ],
    "tipsForSuccess": [
      "Não se apresse; avalie a melhor opção antes de distribuir a bola.",
      "Foque na precisão em vez da força ao lançar ou chutar."
    ]},
    'Defesa de Pênaltis':{"instructions": [
      "Observe a linguagem corporal e a posição dos pés do cobrador.",
      "Mantenha-se centralizado no gol antes do chute ser executado.",
      "Reaja rapidamente na direção do chute assim que ele for feito.",
      "Pratique simulações de pênaltis para melhorar sua tomada de decisão."
    ],
    "tipsForSuccess": [
      "Evite adivinhar cedo demais; mantenha-se equilibrado até o chute.",
      "Fique um pouco à frente da linha do gol para reduzir o ângulo do cobrador."
    ]},
    'Técnica de Mergulho':{"instructions": [
      "Dê um passo rápido na direção do chute antes de mergulhar.",
      "Estenda totalmente o corpo para cobrir o máximo de área possível.",
      "Pratique mergulhos baixos para defender chutes nos cantos inferiores.",
      "Mantenha o foco na bola para sincronizar corretamente o mergulho."
    ],
    "tipsForSuccess": [
      "Sempre dê um passo na direção da bola antes de mergulhar.",
      "Certifique-se de estender completamente o corpo ao mergulhar."
    ]},

  
    'Cantos Ofensivos':{ "instructions": [
      "Use o pé interno para cruzar a bola com velocidade e efeito.",
      "Apontar para áreas-chave, como o primeiro poste, segundo poste ou o ponto de penalidade.",
      "Treine a sincronia de corridas para encontrar a bola no ponto mais alto.",
      "Comunique-se com os atacantes para coordenar melhor as jogadas."
    ],
    "tipsForSuccess": [
      "Certifique-se de cruzar a bola com precisão e força suficientes.",
      "Comunique-se claramente para evitar confusões entre os jogadores."
    ]},
    'Cobranças Diretas de Falta':{ "instructions": [
      "Marque os oponentes de perto para evitar cabeceios perigosos.",
      "Seja rápido para limpar a bola na primeira oportunidade.",
      "Esteja alerta para reagir a segundas bolas após o cruzamento inicial.",
      "Organize a defesa para cobrir áreas perigosas dentro da área."
    ],
    "tipsForSuccess": [
      "Evite assistir à bola; mantenha o foco em seu oponente.",
      "Comunique-se com outros defensores para organizar a linha defensiva."
    ]},
    'Cobranças Indiretas de Falta':{ "instructions": [
      "Posicione a bola no local ideal para um chute limpo.",
      "Use o pé interno para efeito ou os cadarços para chutes potentes.",
      "Aponte para os cantos superiores ou inferiores, onde o goleiro tem menos alcance.",
      "Pratique diferentes técnicas de chute dependendo da distância da meta."
    ],
    "tipsForSuccess": [
      "Evite acertar a barreira; concentre-se em levantar a bola com precisão.",
      "Treine regularmente para melhorar sua precisão e força."
    ]},

    'Reposições com as Mãos':{"instructions": [
      "Planeje um passe curto para um companheiro antes do chute.",
      "Disfarce suas intenções para confundir a defesa.",
      "Trabalhe em conjunto com os companheiros para executar jogadas ensaiadas.",
      "Posicione a bola para facilitar um passe preciso e eficaz."
    ],
    "tipsForSuccess": [
      "Certifique-se de que todos os jogadores conheçam suas funções na jogada ensaiada.",
      "Execute a cobrança rapidamente para pegar a defesa desprevenida."
    ]},

    'Cobrança de Pênaltis':{ "instructions": [
      "Use ambas as mãos para lançar a bola acima da cabeça.",
      "Mantenha ambos os pés no chão durante a reposição.",
      "Procure companheiros de equipe em espaços abertos para uma reposição eficaz.",
      "Evite lançar a bola em áreas congestionadas sem um plano claro."
    ],
    "tipsForSuccess": [
      "Fique atento ao movimento dos companheiros para escolher a melhor opção.",
      "Pratique reposições longas para aumentar o alcance de suas jogadas."
    ]
  },
  'Defesa de Cantos':{
      "instructions": [
      "Marque os oponentes de perto para evitar cabeceios perigosos.",
      "Seja rápido para limpar a bola na primeira oportunidade.",
      "Esteja alerta para reagir a segundas bolas após o cruzamento inicial.",
      "Organize a defesa para cobrir áreas perigosas dentro da área."
    ],
    "tipsForSuccess": [
      "Evite assistir à bola; mantenha o foco em seu oponente.",
      "Comunique-se com outros defensores para organizar a linha defensiva."
    ]
  }
 
  
    

};

final Map<String, List<String>> categoryData = {
 
  'Dribles': [
    'Dribles um contra um'
    'Protegendo a bola',
    'Manuseamento de bola em espaços apertados',
    'Drible de velocidade',
    'sob pressão',
    'Fechar controle',
  ],
  "Dicas de tiro":[
    'Chutes Poderosos',
    'Chutes Colocados',
    'Chutes por Cavadinha',
    'Chutes de Voleio',
    'Chutes de Longa Distância',
    'Cobranças de Falta',
  ],
  
  'Defesa': [
    'Técnicas de Desarme',
    'Marcação com Contenção',
    'Marcação e Posicionamento',
    'Intercepções',
    'Bloqueio de Chutes',
    'Defesa 1v1'
  ],
  'Passes': [
    'Passes Curtos',
    'Passes Longos',
    'Passes em Profundidade',
    'Cruzamento d',
    'Passes de Primeira',
    'Mudança de Jogo'
  ],
  'Goleiro': [
    'Defesa de Chutes',
    'Posicionamento',
    'Defesa de Cruzamentos',
    
    'Distribuição da Bola',
    'Defesa de Pênaltis',
    'Técnica de Mergulho',
  ],
  'conjunto de peças': [
    'Cantos Ofensivos',
    'Cobranças Diretas de Falta',
    'Cobranças Indiretas de Falta',
    'Reposições com as Mãos',
    'Cobrança de Pênaltis',
    'Defesa de Cantos',
    
  ],

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
                                'Escolha uma data',
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
                                'Escolha um horário',
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
                                'Quantos conjuntos?',
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
    final instructions = instructionsData[category]?["instructions"];
    final tipsForSuccess = instructionsData[category]?["tipsForSuccess"];

    if (instructions == null || tipsForSuccess == null) {
      print('Error: Missing data for category: $category');
      return;
    }

    await uploadToFirebase(
      userId,
      category,
      tip,
      selectedTimeSlot,
      selectedSets,
      dateController.text,
      instructions,
      tipsForSuccess,
    );
    Navigator.pop(context);
  } else {
    print('User not logged in. Unable to upload data.');
  }
},

                                  child: Text(
                                    'Adicionar prática',
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
          'Prática',
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
                      'Dados práticos',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Minha prática  ',
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
                          selectedCategory = selected ? category : 'Drible';
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

  
      final snapshot = await userDoc.get();
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final practiceArray = userData['practice'] as List<dynamic>? ?? [];

        final practiceIndex = practiceArray.indexWhere(
          (element) => element['category'] == category,
        );

        if (practiceIndex != -1) {
         
          practiceArray[practiceIndex]['skipped'] = skipped;
        } else {
         
          practiceArray.add({
            'category': category,
            'completed': false,
            'skipped': skipped,
          });
        }

     
        await userDoc.update({
          'practice': practiceArray,
        });

        setState(() {}); 
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
         
          skipClicked
              ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(124, 12, 17, 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Tarefa ignorada',
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
                          'Pular',
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
                          'Comece a praticar',
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
          title: const Text('Prática concluída'),
          content: const Text('Você concluiu esta sessão de prática.'),
          actions: [
            TextButton(
              onPressed: () {
               Navigator.push(context,MaterialPageRoute(builder: (context)=>MainScreen()));
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

   
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
    backgroundColor: Colors.grey[100], // Soft background for a clean look
    appBar: AppBar(
      elevation: 0,
      backgroundColor: const Color.fromRGBO(124, 12, 17, 1),
      centerTitle: true,
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Row(
              children: [
                const Icon(Icons.menu_book_rounded, color: Colors.black54),
                const SizedBox(width: 8),
                const Text(
                  'Instruções',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 1.5,
              color: Colors.black26,
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.instructions?.length ?? 0,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '\u2022',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
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
            const SizedBox(height: 24),

            // Practice Section
            Row(
              children: [
              
                const SizedBox(width: 8),
                Text(
                  widget.practice,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    children: [
      // Target Set Section
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.blueAccent, size: 30),
                const SizedBox(width: 12),
                const Text(
                  "Conjunto de metas",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Text(
              '${widget.targetSets}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Dribbling Section
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
             
                const SizedBox(width: 12),
                 Text(
                 widget.practice ,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            LinearProgressIndicator(
              value: completedSets / widget.targetSets,
              backgroundColor: Colors.grey[300],
              color: Colors.orangeAccent,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              'Progress: $completedSets / ${widget.targetSets}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

            // Completed Sets Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Conjuntos concluídos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (completedSets > 0) {
                            setState(() => completedSets--);
                            await _updateCompletedSets();
                          }
                        },
                        child: const Icon(Icons.remove_circle,
                            size: 30, color: Colors.redAccent),
                      ),
                      const SizedBox(width: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          '$completedSets',
                          key: ValueKey<int>(completedSets),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () async {
                          if (completedSets < widget.targetSets) {
                            setState(() => completedSets++);
                            await _updateCompletedSets();
                          }
                        },
                        child: const Icon(Icons.add_circle,
                            size: 30, color: Colors.greenAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: completedSets >= widget.targetSets
                        ? _showCompletionDialog
                        : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: completedSets >= widget.targetSets
                          ? Colors.teal
                          : Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Prática Completa',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tips for Success Section
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.black54),
                const SizedBox(width: 8),
                const Text(
                  'Dicas para o sucesso',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 1.5,
              color: Colors.black26,
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.tipsForSuccess?.length ?? 0,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '\u2022',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
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
          ],
        ),
      ),
    ),
  );
}

  String formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
