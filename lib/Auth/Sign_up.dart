
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer/Auth/log_in.dart';
import 'package:soccer/Auth/provider.dart';
import 'package:soccer/apputils/appcolor.dart';
import 'package:soccer/screen/bottomnavbar/Homescreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showAgreementDialog(BuildContext context) {
    showDialog(
      
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End User License Agreement,',style: TextStyle(color: color5),),
          backgroundColor: color6,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
           _buildSectionTitle('1. License Grant'),
              const Text(
                'We grant you a limited, non-exclusive, non-transferable license to use the Casino Pro Guide App for personal, non-commercial purposes. You are not permitted to modify, distribute, or reverse-engineer the app or any part of its content.',
                style: TextStyle(fontSize: 14,color: color5),
              ),

              _buildSectionTitle('2. User Obligations'),
              const Text('You agree to:', style: TextStyle(fontSize: 14,color: color5),),
              _buildBullet(' Use the app lawfully and comply with all applicable laws and regulations.'),
              _buildBullet(' Keep your account secure and not share your login credentials with others.'),
              _buildBullet('Follow the community guidelines and avoid posting offensive, defamatory, or harmful content (see Section 4).'),

              _buildSectionTitle('3. User-Generated Content (News Section)'),
              const Text('The app allows you to post news, reviews, and other content related to casinos and games. By posting, you agree that:', style: TextStyle(fontSize: 14,color: color5),),
              _buildBullet(' You will not post content that is abusive, offensive, pornographic, harassing, defamatory, discriminatory, or otherwise inappropriate.'),
              _buildBullet(' The Company reserves the right to review, remove, or block any content that violates this EULA or is reported as objectionable by other users.'),
              _buildBullet(' Your account may be suspended or terminated if you violate these terms or repeatedly post objectionable content.'),

              _buildSectionTitle('4. Restrictions'),
              const Text('You agree not to:', style: TextStyle(fontSize: 14,color: color5),),
              _buildBullet(' Copy, distribute, or modify the app or its content.'),
              _buildBullet(' Reverse-engineer, decompile, or attempt to extract the app’s source code.'),
              _buildBullet(' Rent, lease, sell, or sublicense the app to third parties.'),
              _buildBullet(' Use the app for commercial purposes without explicit permission from the Company.'),
              _buildBullet(' Post or distribute content that infringes on the intellectual property or privacy rights of others.'),

              _buildSectionTitle('5. Ownership'),
              const Text(' The app, its content, and all related intellectual property belong to Melih Ataman (Individual). This EULA does not grant you ownership of the app or any of its components, including ratings, casino data, or game-related information.', style: TextStyle(fontSize: 14,color: color5),),

              _buildSectionTitle('6. Objectionable Content and Reporting'),
              _buildBullet('Users can report any content they find inappropriate or offensive.'),
              _buildBullet(' The Company will review reported content and may remove it and take action against the offending user.'),
              _buildBullet(' Users who repeatedly post objectionable content will be permanently banned from the platform.'),

              _buildSectionTitle('7. Termination'),
              const Text(' We may terminate your access to the app at any time for any reason, including but not limited to violations of this EULA or the community guidelines. Upon termination, you must cease using the app and delete it from your device.', style: TextStyle(fontSize: 14,color: color5),),

              _buildSectionTitle('8. Limitation of Liability'),
              const Text(' The app is provided "as is" without warranties of any kind. We are not responsible for any losses or damages arising from the use of the app, including but not limited to data loss, service interruptions, or inaccurate information about casinos or games.', style: TextStyle(fontSize: 14,color: color5),),

              _buildSectionTitle('9. Updates and Changes'),
              const Text(' We may update the app or this EULA periodically. Your continued use of the app after updates constitutes acceptance of the modified terms. If you do not agree with the new terms, please discontinue use of the app.', style: TextStyle(fontSize: 14,color: color5),),

              _buildSectionTitle('10. Payment Information and Transactions'),
              const Text(' The app provides guides on payment methods in online casinos but does not process financial transactions. The Company is not responsible for issues or losses resulting from interactions with third-party payment providers.', style: TextStyle(fontSize: 14,color: color5),),

              _buildSectionTitle('11. Contact Information'),
              const Text('If you have any questions about this EULA or need to report a violation, please contact us at:', style: TextStyle(fontSize: 14,color: color5),),
              _buildBullet('App Name: xyz'),
              _buildBullet('Company Name: xyz'),
              _buildBullet(' Email: xyz'),
              ],
            ),
          ),
          actions: <Widget>[
           Row(
             children: [
               SizedBox(
                 width: 120, // Set width
                 height: 41, // Set height
                 child: TextButton(
                   style: TextButton.styleFrom(
                     foregroundColor: Colors.black, backgroundColor: Colors.white, // Button background color
                   ),
                   onPressed: () {
                     Navigator.of(context).pop(); // Close the dialog
                   },
                   child: const Text('Fechar'),
                 ),
               ),
             
           
        const SizedBox(width: 15,),

            SizedBox(
               width: 120, // Set width
  height: 41, 
              child: TextButton(
                 style: TextButton.styleFrom(
      foregroundColor: Colors.white, backgroundColor: const Color(0XffF32B4F), // Button background color
    ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    SignupProvider signupProvider = Provider.of<SignupProvider>(context, listen: false);
                    bool success = await signupProvider.signupUser(
                      name: _name.text,
                      email: _email.text,
                      password: _password.text,
                      context: context,
                    );
              
                    if (success) {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen()), // Replace with your next screen
                      );
                    } else {
                      Navigator.of(context).pop(); // Close the dialog
                      // Show an error dialog if signup fails
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Falha na inscrição"),
                            content: const Text("Tente se inscrever novamente."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    // Show a message if form is not valid
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Formulário incompleto"),
                          content: const Text("Por favor, preencha todos os campos obrigatórios."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Aceitar'),
              ),
            ),
             ]
           )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
      final authProvider = Provider.of<SignupProvider>(context, listen: false);
    return Scaffold(
      backgroundColor:color4,
      appBar: AppBar(
        backgroundColor: color4,
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Navigate back
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          'Crie sua conta',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nome',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                hintText: 'Digite seu nome',
                icon: Icons.person,
                obscureText: false, 
                controller: _name,
              ),
              const SizedBox(height: 16),
              const Text(
                'E-mail',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                hintText: 'Insira o ID do e-mail',
                icon: Icons.email,
                obscureText: false, 
                controller: _email,
              ),
              const SizedBox(height: 16),
              const Text(
                'Senha',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                hintText: 'Digite a senha',
                icon: Icons.lock,
                obscureText: !_isPasswordVisible,
                toggleVisibility: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                isPasswordField: true,
                isVisible: _isPasswordVisible, 
                controller: _password,
              ),
              const SizedBox(height: 16),
              const Text(
                'Confirme sua senha',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                hintText: 'Confirme sua senha',
                icon: Icons.lock,
                obscureText: !_isConfirmPasswordVisible,
                toggleVisibility: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
                isPasswordField: true,
                isVisible: _isConfirmPasswordVisible, 
                controller: _password,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Show the EULA dialog
                    _showAgreementDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Criar uma conta',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Ao criar uma conta, você concorda com nossos ',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                    children: [
                      TextSpan(
                        text: 'Contrato de licença de usuário final',
                        style: const TextStyle(color: Colors.blue, fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _showAgreementDialog(context);
                          },
                      ),
                      const TextSpan(
                        text: ' e',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      TextSpan(
                        text: 'política de Privacidade',
                        style: const TextStyle(color: Colors.blue, fontSize: 16),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            _showAgreementDialog(context); // Implement separate privacy policy if needed
                          },
                      ),
                      const TextSpan(
                        text: '.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tem uma conta?',
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                      },
                      child: const Text(
                        '  Entrar',
                        style: TextStyle(
                          color: Colors.redAccent,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async{
                      bool success = await authProvider.signInWithApple(context);
                          if (success) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
                          } else {
                            showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text("Falha no login"),
      content: Text("Falha no FLogin. Tente novamente"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("OK"),
        ),
      ],
    );
  },
);

                          }
                      
                    },
                  icon: const Icon(Icons.apple, color: Colors.white),
                  label: const Text('Faça login com a Apple', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: color5),
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0), // Spacing between bullets
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Icon(Icons.circle, size: 7,color: color5,),
          ), // Increased bullet size
          const SizedBox(width: 8), // Spacing between bullet and text
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14,color: color5),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required bool obscureText,
    required TextEditingController controller,
    Function()? toggleVisibility,
    bool isPasswordField = false,
    bool isVisible = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor insira um valor';
        }
        if (isPasswordField && value.length < 6) {
          return 'A senha deve ter pelo menos 6 caracteres';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: isPasswordField
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: toggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
