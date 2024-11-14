import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebaseseries2/Screen/Auth/login_Page.dart';
// import 'package:firebaseseries2/Screen/bottomnav/HomePage.dart';
// import 'package:firebaseseries2/utils/app_routers.dart';

import 'package:flutter/material.dart';


import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:soccer/Auth/log_in.dart';
import 'package:soccer/screen/bottomnavbar/Homescreen.dart';

class SignupProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  String ?_name = '';
  
  String? _profileImageUrl;
    String? guestName;
  bool _isGuest = false;
    bool _isLoggedIn = false;
  User? get user => _user;
  String? get profileImageUrl => _profileImageUrl;
  String? get name => _name;



  bool get isLoggedIn => _user != null;
  bool get isGuest => _isGuest;
  void setName(String name) {
    _name = name;
  }
void saveUserData(String name, String email, String profileImageUrl) {
    _name = name;
   
    notifyListeners();  
  }

  Future<void> loginAsGuest() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _isLoggedIn = true;
  await prefs.setBool('isLoggedIn', true);
  _user = null;
  _name = '';
  _profileImageUrl = null;
  _isGuest = true;
  notifyListeners();
}
bool _isCheckingLoginStatus = true;

bool get isCheckingLoginStatus => _isCheckingLoginStatus;

// Future<void> autoLogin() async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   _isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;
//   _isCheckingLoginStatus = false;
//   notifyListeners();
// }
// void _skipLogin() async {
//   await clearUserData(); 
//   _profileImageUrl = 'path_to_default_image'; 
//   notifyListeners();
// }
//   void setProfileImageUrl(String url) {
//     _profileImageUrl = url;
//     notifyListeners();
//   }


// Future<void> clearUserData() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   await prefs.remove('userName');
//   await prefs.remove('userEmail');
//   await prefs.remove('profileImageUrl');
// }


  
 
//   Future<void> login(String email, String password) async {
  
//     _isLoggedIn = true;
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     await sharedPreferences.setBool('isLoggedIn', true);
//     notifyListeners();
//   }


  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isGuest) {
      guestName = prefs.getString('guestName');
    } else {
      _name
       = prefs.getString('userName');
    }
    notifyListeners();
  }


  void updateName(String newName) {
    _name = newName;
    notifyListeners(); 
  }

  void updateGuestName(String newGuestName) {
    guestName = newGuestName;
    notifyListeners();  
  }

  // Future<void> updateUserDetails(
  //     {required String name, required String email}) async {
  //   if (_user != null) {
  //     await _firestore.collection('users').doc(_user!.uid).update({
  //       'name': name,
  //       'email': email,
  //     });
  //     _name = name;
  //     notifyListeners();
  //   }
  // }

  Future<bool> signupUser({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
      });

      _user = userCredential.user;
      _name = name;
      _isGuest = false;
      notifyListeners();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );

      return true;
    } catch (e) {
      print("Signup error: $e");
      showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: Text("Signup Failed"),
      content: Text("Por favor, tente se inscrever novamente."),
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

      return false;
    }
  }

  // Future<void> loadUserData() async {
  //   final user = _auth.currentUser;
  //   if (user != null) {
  //     final userData = await _firestore.collection('users').doc(user.uid).get();
  //     _name = userData['name'];
  //     _isGuest = false;
  //     notifyListeners();
  //   }
  // }
//   Future<void> _uploadProfileImage(String userId) async {
//   final picker = ImagePicker();
//   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  
//   if (pickedFile != null) {
//     File file = File(pickedFile.path);
//     try {
    
//       Reference storageReference = FirebaseStorage.instance.ref().child('profile_images/$userId');
//       await storageReference.putFile(file);

//       String downloadUrl = await storageReference.getDownloadURL();

      
//       await FirebaseFirestore.instance.collection('users').doc(userId).update({
//         'profileImageUrl': downloadUrl,
//       });

//       print('Profile image updated successfully');
//     } catch (e) {
//       print('Error uploading image: $e');
//     }
//   } else {
//     print('No image selected.');
//   }
// }

 Future<bool> loginUser({
  required String email,
  required String password,
  required BuildContext context,
}) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      _user = userCredential.user;
      _isGuest = false;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>?;

        _name = userData?['name'] ?? '';
        _profileImageUrl = userData?['profileImageUrl'] ?? null;
      } else {
        _name = '';
        _profileImageUrl = null;
      }

      notifyListeners();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
      return true;
    } else {
      return false;
    }
  } catch (e) {
    print("Login error: $e");  


    return false;
  }
}


  // // Method to upload image to Firebase Storage
  // Future<String> uploadImageToFirebase(File imageFile) async {
  //   try {
  //     // Define a unique file name
  //     String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
  //     Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');

  //     // Upload the file to Firebase Storage
  //     UploadTask uploadTask = storageRef.putFile(imageFile);
  //     await uploadTask;

  //     // Get the download URL
  //     String downloadUrl = await storageRef.getDownloadURL();
  //     print("Uploaded Image URL: $downloadUrl"); // Debug print
  //     return downloadUrl;
  //   } catch (e) {
  //     print("Error uploading image: $e");
  //     throw e; // Handle error as needed
  //   }
  // }

  // // Method to upload profile image and update the URL
  // Future<void> uploadProfileImage(File imageFile) async {
  //   // Call the uploadImageToFirebase method
  //   String url = await uploadImageToFirebase(imageFile);
  //   _profileImageUrl = url; // Set the URL here
  //   notifyListeners(); // Notify listeners about the change
  // }


  Future<bool> signInWithApple(BuildContext context) async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential appleCredential =
          OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(appleCredential);

      _user = userCredential.user;
      await _firestore.collection("users").doc(_user!.uid).set({
        "email": _user!.email,
        "createdAt": DateTime.now(),
      });

      notifyListeners();

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    } catch (e) {
      print("Error during Apple sign in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Apple Sign-In Failed: $e")),
      );
    }
    return false;
  }

  Future<bool> signInAnonymously(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;

      if (user != null) {
        _user = user;
        _name = "Guest";
        _isGuest = true;
        _profileImageUrl = "profileImageUrl"; // Set a default profile image URL

        notifyListeners();
      }

      return true;
    } catch (e) {
      print("Error during anonymous login: $e");
      return false;
    }
  }


  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      notifyListeners();
    } catch (e) {
      throw Exception('Error sending reset email: $e');
    }
  }

  

Future<void> _logout(BuildContext context) async {
  try {
  
    await _auth.signOut();

   
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('profileImageUrl');

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  } catch (e) {
   
    print('Error signing out: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error signing out: $e')),
    );
  }
}

Future<void> signOut(BuildContext context) async {
  await _auth.signOut();

  _user = null;
  _name='';
  
  notifyListeners();

  
}
Future<void> deleteAccount(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Excluir conta"),
        content: Text("Tem certeza de que deseja excluir sua conta? Esta ação não pode ser desfeita."),
        actions: <Widget>[
          TextButton(
            child: Text("Cancelar"),
            onPressed: () {
              Navigator.of(context).pop();  
            },
          ),
          TextButton(
            child: Text("Excluir"),
            onPressed: () async {
              Navigator.of(context).pop();  
              
              User? user = _auth.currentUser;

              if (user != null) {
                try {
                  
                  await user.delete();
                
                  await signOut(context); 

                
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Conta excluída com sucesso."),
                  ));

                 
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen())); 

                } catch (e) {
                  print(e);
                  String message;

                
                  if (e is FirebaseAuthException && e.code == 'requires-recent-login') {
                    message = "Você precisa fazer login novamente antes de excluir sua conta.";
                  } else {
                    message = "Erro ao excluir conta. Por favor, tente novamente.";
                  }

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(message),
                  ));
                }
              } else {
                showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Atenção"),
        content: Text("Usuário não autenticado."),
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
          ),
        ],
      );
    },
  );
}







//   Future<void> updateGuestUserNameAndEmail(
//       {required String name, required String email}) async {
//     if (_user != null && _user!.isAnonymous) {
//       _name = name;

//       await _firestore.collection('users').doc(_user!.uid).set({
//         'name': name,
//         'email': email,
//       });

//       notifyListeners();
//     }
//   }
// }
}