
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soccer/Auth/Sign_up.dart';
import 'package:soccer/Auth/provider.dart';
import 'package:soccer/apputils/appcolor.dart';
import 'package:soccer/screen/bottomnavbar/Homescreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
    final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false; // Track password visibility
    @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'O e-mail não pode ficar vazio';
    }
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(email)) {
      return 'Insira um e-mail válido';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'A senha não pode estar vazia';
    }
    if (password.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
      final authProvider = Provider.of<SignupProvider>(context, listen: false);
    return Scaffold(
    
     
      body: Stack(
        

       
          fit: StackFit.expand,

         children: [
           Image.asset(
            'assets/image.png',  
            fit: BoxFit.cover,
          ),
         
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
           Positioned(
              top: 50,
              left: 40,
              child: Container(
                width: 350,
                height: 600,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3), 
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                ),

          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                     Text(
                       'Conecte-se',
                       style: TextStyle(
                         fontSize: 22,
                         fontWeight: FontWeight.bold,
                         color: Colors.white,
                       ),
                     ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Insira o ID do e-mail',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                 TextFormField(
  controller: _emailController,
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    prefixIcon: const Icon(Icons.email, ),
    hintText: 'Insira o ID do e-mail',
    hintStyle: const TextStyle(color: Colors.grey),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.white),
    ),
  ),
  validator: (value) => _validateEmail(value ?? ''),
  style: const TextStyle(color: Colors.black),
),

                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Digite a senha',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible, // Toggle password visibility
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock,),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      hintText: 'Digite a senha',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                      
                              validator: (value) => _validatePassword(value ?? ''),
                    style: const TextStyle(color: Colors.black),
                   
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              FocusScope.of(context).unfocus();  
                  
                              bool success = await authProvider.loginUser(
                                email: _emailController.text,
                                password: _passwordController.text,
                                context: context,
                              );
                  
                              if (success) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => MainScreen()),
                                );
                              } else {
                                showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Falha no login"),
                  content: const Text("Falha no FLogin. Tente novamente"),
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
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Conecte-se',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        minimumSize: Size(double.infinity, 50),
                        side: BorderSide(color: Colors.white, width: 2),
                      ),
                      onPressed: () {
                        Navigator .push(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));
                      },
                      
                      child: Text(
                        "Inscrever-se",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                   ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        minimumSize: Size(double.infinity, 50),
                        side: BorderSide(color: Colors.white, width: 2),
                      ),
                      onPressed: () async {
  bool success = await authProvider.signInAsGuest(context);
  if (success) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Falha no login"),
          content: Text("Falha no login. Por favor, tente novamente."),
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
                      child: Text(
                        "Continuar como convidado",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(height: 1, color: Colors.white, width: 110),
                        SizedBox(width: 10),
                        Text("ou", style: TextStyle(color: Colors.white)),
                        SizedBox(width: 10),
                        Container(height: 1, color: Colors.white, width: 110),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
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
                        icon: Icon(
                          Icons.apple,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          )
        ],
      ),
    );
  }
}

