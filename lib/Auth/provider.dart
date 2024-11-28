import 'dart:convert';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart'; // For extracting the file name
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:soccer/Auth/log_in.dart';
import 'package:soccer/appconstant.dart';
import 'package:soccer/screen/bottomnavbar/Homescreen.dart';

class SignupProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;
  User? _user;
  String? _name = '';
  String? _profileImageUrl;
  bool _isGuest = false;
  bool _isLoggedIn = false;
  bool _isCheckingLoginStatus = true;
  
  String? username;
  String? email;
  String? phoneNumber;

  User? get user => _user;
  String? get profileImageUrl => _profileImageUrl;
  String? get name => _name;
  bool get isLoggedIn => _user != null;
  bool get isGuest => _isGuest;
  bool get isCheckingLoginStatus => _isCheckingLoginStatus;
  
  Future<bool> checkIfUserExists(String userId) async {
  try {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.exists;
  } catch (e) {
    print("Error checking user existence: $e");
    return false;  // Return false if an error occurs
  }
}
Future<String?> getAwsImageLink(String imageLink, String bundleName) async {
  // Generate a unique file name using the provided image link
  String uniqueFileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}${extension(imageLink)}';

  // Prepare the payload for the signed URL request
  final Map<String, String> payload = {
    'fileName': uniqueFileName,
    'bundle': bundleName,
  };

  // The endpoint for generating the signed URL
  final String url = AppConstant.awsBaseUrlUpload;

  try {
    // Convert the payload to JSON and make the POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    // Check if the response is successful
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody.containsKey('data')) {
        String signedUrl = responseBody['data'];

        // Upload the file to the signed URL
        final File file = File(imageLink);
        if (await file.exists()) {
          final fileBytes = await file.readAsBytes();
          final uploadResponse = await http.put(
            Uri.parse(signedUrl),
            headers: {
              'Content-Type': 'application/octet-stream',
              'Content-Length': fileBytes.length.toString(),
            },
            body: fileBytes,
          );

          // If upload is successful, return the AWS image link
          if (uploadResponse.statusCode == 200) {
            String awsImageLink = AppConstant.awsBaseUrlUpload + '/' + bundleName + '/' + uniqueFileName;
            return awsImageLink;
          } else {
            debugPrint('Failed to upload file: ${uploadResponse.body}');
          }
        } else {
          debugPrint('File not found at the specified path: $imageLink');
        }
      }
    } else {
      debugPrint('Failed to generate signed URL: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
  return null; // Return null if the process fails
}

Future<bool> signupUser({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      // Ensure user is signed out before attempting to sign up
      if (_auth.currentUser != null) {
        await _auth.signOut();
      }

      // Create the Firebase user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        _showErrorDialog(context, "Signup Failed", "Could not create user.");
        return false;
      }

      // Save user data to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': DateTime.now(),
      });

      // Update local variables and navigate to the home screen
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
      // Catch specific errors for more user-friendly messages
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            _showErrorDialog(
                context, "Email In Use", "The email is already registered.");
            break;
          case 'invalid-email':
            _showErrorDialog(
                context, "Invalid Email", "The email address is not valid.");
            break;
          case 'weak-password':
            _showErrorDialog(
                context, "Weak Password", "Please choose a stronger password.");
            break;
          default:
            _showErrorDialog(
                context, "Signup Failed", "Please try to sign up again.");
            break;
        }
      } else {
        _showErrorDialog(
            context, "Signup Failed", "An unexpected error occurred.");
      }
      return false;
    }
  }

  // Login an existing user
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

        // Load user data after logging in
        await loadUserData();

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

  // Logout method
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    _user = null;
    _name = '';
    _isGuest = false; // Reset the guest status
    notifyListeners();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  // Auto login for persistent sessions
  Future<void> autoLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _isLoggedIn = sharedPreferences.getBool('isLoggedIn') ?? false;
    _isCheckingLoginStatus = false;
    notifyListeners();
  }
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


Future<void> deleteAccount(BuildContext parentContext) async {
  showDialog(
    context: parentContext,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete account"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text("Delete"),
            onPressed: () async {
              Navigator.of(context).pop();
              User? user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                try {
                  // Prompt for password and reauthenticate
                  await reauthenticateUser(parentContext, user);

                  // Delete user
                  await user.delete();
                  print("Account deleted successfully.");

                  // Show success message
                  ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(
                    content: Text("Account deleted successfully."),
                  ));

                  // Navigate to Login screen
                  Navigator.pushReplacement(
                    parentContext,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                } catch (e) {
                  print("Error deleting account: $e");
                  _showErrorDialog(parentContext, "Error", "Failed to delete account: $e");
                }
              } else {
                _showErrorDialog(parentContext, "Attention", "Unauthenticated user.");
              }
            },
          ),
        ],
      );
    },
  );
}

Future<String?> _promptForPassword(BuildContext context) async {
  String? password;
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Enter Password"),
        content: TextField(
          obscureText: true,
          decoration: const InputDecoration(hintText: "Password"),
          onChanged: (value) {
            password = value;
          },
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          TextButton(
            child: const Text("Submit"),
            onPressed: () {
              Navigator.of(context).pop(password);
            },
          ),
        ],
      );
    },
  );
}
Future<void> reauthenticateUser(BuildContext context, User user) async {
  String? password = await _promptForPassword(context);
  if (password == null || password.isEmpty) {
    throw Exception("Password is required for reauthentication.");
  }

  try {
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    print("User reauthenticated successfully.");
  } catch (e) {
    print("Reauthentication failed: $e");
    throw Exception("Reauthentication failed: $e");
  }
}



Future<bool> signInAsGuest(BuildContext context) async {
  try {
    // Sign in anonymously
    UserCredential userCredential = await _auth.signInAnonymously();
    _user = userCredential.user;

    if (_user != null) {
      // Set guest flag and update Firestore with guest data
      _isGuest = true;
      await _firestore.collection('users').doc(_user!.uid).set({
        'username': 'Guest',
        'email': 'guest@example.com',
        'phone_number': '',
        'profile_image': '',
      });

      // Notify listeners that the user is now signed in as a guest
      notifyListeners();

      // Optionally navigate to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  MainScreen()),
      );

      print("Guest user signed in with ID: ${_user!.uid}");
      return true;
    } else {
      print("Anonymous sign-in failed");
      return false;
    }
  } catch (e) {
    print("Error signing in as guest: $e");
    return false;
  }
}


  Future<void> loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid; // Get the user ID from FirebaseAuth

        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final data = userDoc.data();
          print("User Data: $data"); // Log retrieved user data
          _name = data?['name'] ?? 'Guest'; // Default to Guest
          email = data?['email'] ?? '';
          phoneNumber = data?['phone_number'] ?? '';
          uploadedFileUrl = data?['profile_image'] ?? '';
          notifyListeners();
        } else {
          print("User document does not exist, creating a new one.");
          // Optionally create a new document for the guest user if it doesn't exist
          await _firestore.collection('users').doc(userId).set({
            'username': 'Guest',
            'email': 'guest@example.com',
            'phone_number': '',
            'profile_image': '',
          });
        }
        notifyListeners(); // Notify listeners after loading user data
      } else {
        print("No user is currently signed in.");
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  // Utility method for showing error dialog
  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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
  


  // Delete Account Function
Future<bool> deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      bool confirmDelete = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmDelete) {
        try {
          // Delete user data from Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .delete();

          // Delete the user from Firebase Auth
          await user.delete();

          // Navigate to the login screen after deletion
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted successfully')),
          );
          return true;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Please sign in again to delete your account.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.message}')),
            );
          }
          return false;
        }
      } else {
        // User canceled the deletion
        return false;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not logged in')),
      );
      return false;
    }
  }
}

  // Handle account deletion error
void _handleAccountDeletionError(dynamic error, BuildContext context) {
  if (error.toString().contains("requires-recent-login")) {
    _showErrorDialog(context, "Error", 
      "You need to reauthenticate before deleting your account.");
  } else {
    _showErrorDialog(context, "Error", error.toString());
  }
}


  final ImagePicker _picker = ImagePicker();
  String _fileName = '';
  File? file;
  String bundleName = "403";
  String _uploadedFileUrl = '';

String get uploadedFileUrl => _uploadedFileUrl;

set uploadedFileUrl(String value) {
  _uploadedFileUrl = value;
  // notifyListeners();
}



  /// photos/folder1/photo.png
  /// Function to pick image from gallery
  Future<void> getimage(BuildContext context,  XFile image,bool isGuestUser,bool isStory) async {

    if (image != null) {
      file = File(image.path);

      // Generate a unique file name using current date and time
      String uniqueFileName = 'IMG_Profile_${DateTime.now().millisecondsSinceEpoch}${extension(image.path)}';

      // Update the file name
      debugPrint("Original File Name: ${basename(image.path)}");
      debugPrint("Unique File Name: $uniqueFileName");

      // setState(() {
        _fileName = uniqueFileName;
      // });
       print('_fileName  ====> $_fileName');

      if (_fileName.isNotEmpty) {
        String? url = await getSignedUrl(_fileName, bundleName);
        if (url != null && url.isNotEmpty && file != null) {
          uploadFileToS3(url, file!.path, context, isGuestUser,isStory);
        }
      }
    }
  }

  Future<String?> getSignedUrl(String fileName, String bundle) async {
    // The URL for the CloudFront endpoint
    final String url = AppConstant.awsBaseUrlUpload;
    uploadedFileUrl= '/'+bundle+'/'+fileName;
              notifyListeners();

    print('uploadedFileUrl -> ${url+ uploadedFileUrl}');
    // The JSON payload that will be sent in the request body
    final Map<String, String> payload = {
      'fileName': fileName, // image.png
      'bundle': bundle,
    };

    // Convert the payload to JSON
    final String jsonPayload = json.encode(payload);

    try {
      // Make the PUT request
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonPayload,
      );

      // Check the response status
      if (response.statusCode == 200) {
        debugPrint('getSignedUrl Request successful: ${response.body}');
        Map map = json.decode(response.body);
        if (map.containsKey("data")) {
          String signedUrl = map['data'];
          return signedUrl;
        }
      } else {
        debugPrint(
            'getSignedUrl Failed request: ${response.statusCode} : ${response.body}');
      }
    } catch (e) {
      debugPrint('getSignedUrl Error: $e');
    }
    return null;
  }

  Future<void> uploadFileToS3(String signedUrl, String filePath, BuildContext context, bool isGuestUser,bool isStory) async {
    try {
      // Create a File object from the provided file path
      final file = File(filePath);

      // Make sure the file exists
      if (await file.exists()) {
        // Read the file as bytes
        final fileBytes = await file.readAsBytes();

        // Send a PUT request with the file bytes as the body
        final response = await http.put(
          Uri.parse(signedUrl), // The signed URL provided
          headers: {
            'Content-Type':
            'application/octet-stream', // Ensure the correct content type
            'Content-Length': fileBytes.length.toString(),
          },
          body: fileBytes, // Send the file content as the body
        );
        debugPrint("File uploaded string [${(await response).toString()}]");
        // Check if the upload was successful
        if (response.statusCode == 200) {
          debugPrint("File uploaded body [${response.body}]");
          // Map map = json.decode(response.body);
          // await currentUserReference!
          //     .update(createUsersRecordData(
          //   photoUrl: uploadedFileUrl != ''
          //       ? uploadedFileUrl
          //       : currentUserPhoto,
          // ));(
          if(!isStory){
 await  saveUserData(context, isGuestUser);
          }
          else{
            await _saveUserDataStory(context, isGuestUser);
          }
         
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture uploaded successfully!'),
                backgroundColor: Colors.green,
              ),);
          debugPrint('File uploaded successfully!');
        } else {
          debugPrint(
              'File uploaded Failed to upload file: ${response.statusCode} : ${response.body}');
          debugPrint(response.body);
        }
      } else {
        debugPrint(
            'File uploaded File not found at the specified path: $filePath');
      }
    } catch (e) {
      debugPrint('File uploaded Error uploading file: $e');
    }
  }
 

 
 
  Future<void> saveUserData(BuildContext context, bool isGuestUser ) async {
  

    try {
      if (userId != null) {
        // Create a reference to Firestore
        final userCollection = FirebaseFirestore.instance.collection('users');

        if (!isGuestUser) {
          // Save logged-in user data to Firestore
          await userCollection.doc(userId!).update({
            // 'name': name,
            // 'email': email,
            // 'phone_number': phoneNumber,
            'profile_image': uploadedFileUrl ?? "",
          });
        } else {
          // Save guest user data to Firestore
          await userCollection.doc(userId!).update({
            // 'name': name,
            // 'email': email,
            // 'phone_number': phoneNumber,
            'profile_image':  uploadedFileUrl,
            'isGuest': true, // Add a flag to indicate guest user
          });
        }

        // Save user data to SharedPreferences (both guest and logged-in users)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString('name', nameController.text);
        // prefs.setString('email', emailController.text);
        // prefs.setString('phone_number', phoneController.text);
        prefs.setString('profile_image',  uploadedFileUrl);

        // setState(() {
          uploadedFileUrl =  uploadedFileUrl;
            loadUserData();
          notifyListeners();
        // });
      
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Updated successfully!")),
        );
      }


    } catch (e) {
      print("Error saving user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving user data: $e")),
      );
    }
  }
  Future<void> _saveUserDataStory(BuildContext context, bool isGuestUser ) async {
  

    try {
      if (userId != null) {
        // Create a reference to Firestore
        final userCollection = FirebaseFirestore.instance.collection('users');

        if (!isGuestUser) {
          // Save logged-in user data to Firestore
          await userCollection.doc(userId!).update({
            // 'name': nameController.text,
            // 'email': emailController.text,
            // 'phone_number': phoneController.text,
            'Story': uploadedFileUrl ?? "",
          });
        } else {
          // Save guest user data to Firestore
          await userCollection.doc(userId!).update({
            // 'name': nameController.text,
            // 'email': emailController.text,
            // 'phone_number': phoneController.text,
            'Story':  uploadedFileUrl,
            'isGuest': true, // Add a flag to indicate guest user
          });
        }

        // Save user data to SharedPreferences (both guest and logged-in users)
        SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString('name', nameController.text);
        // prefs.setString('email', emailController.text);
        // prefs.setString('phone_number', phoneController.text);
        prefs.setString('profile_image',  uploadedFileUrl);

        // setState(() {
          uploadedFileUrl =  uploadedFileUrl;
          notifyListeners();
        // });
        loadUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Updated successfully!")),
        );
      }


    } catch (e) {
      print("Error saving user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving user data: $e")),
      );
    }
  }

  //  Future<void> _loadUserData() async {
  //   try {
  //     if (userId != null) {
  //       // Load user data from Firestore if logged in
  //       final userDoc = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(userId)
  //           .get();

  //       if (userDoc.exists) {
  //         final data = userDoc.data();
  //         nameController.text = data?['name'] ?? '';
  //         emailController.text = data?['email'] ?? '';
  //         phoneController.text = data?['phone_number'] ?? '';
  //         provider.uploadedFileUrl = data?['profile_image'] ?? '';
  //         setState(() {}); // Refresh UI with data from Firestore
  //       }
  //     }
  //   } catch (e) {
  //     print("Error loading user data: $e");
  //   }
  // }

}