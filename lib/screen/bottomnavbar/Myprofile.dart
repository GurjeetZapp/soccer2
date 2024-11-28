import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:soccer/Auth/log_in.dart';
import 'package:soccer/Auth/provider.dart';
import 'package:soccer/appconstant.dart';
import 'package:soccer/apputils/appcolor.dart';
import 'package:soccer/provider/inapppurcahse.dart';
import 'package:soccer/provider/inappropriate.dart';
import 'package:soccer/screen/bottomnavbar/Homescreen.dart';
import 'package:uuid/uuid.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String? firebaseImageUrl;
  XFile? _image;
  final TextEditingController _captionController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  SignupProvider provider = SignupProvider();

  String? userId;
  // String profileImageUrl = '';
  bool isGuestUser = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Guest user logic
      setState(() {
        isGuestUser = true;
        // Clear any previously loaded user data
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        provider.uploadedFileUrl = '';
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('guestUserId') ?? Uuid().v4();
      prefs.setString('guestUserId', userId!);
      _loadGuestData();
    } else {
      // Logged-in user logic (email/password)
      setState(() {
        isGuestUser = false;
      });
      userId = user.uid;
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      if (userId != null) {
        // Load user data from Firestore if logged in
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          nameController.text = data?['name'] ??"";
          emailController.text = data?['email'] ?? '';
          phoneController.text = data?['phone_number'] ?? '';
          //provider.uploadedFileUrl = data?['profile_image'] ?? '';
          setState(() {
            firebaseImageUrl = data?['profile_image'] ?? '';
            print(firebaseImageUrl);
            print("asdf"); // Store the picked image
          });

          setState(() {}); // Refresh UI with data from Firestore
        }
      }
    } catch (e) {
      // print("Error loading user data: $e");
    }
  }

  Future<void> _loadGuestData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      nameController.text = prefs.getString('guestUsername') ?? '';
      emailController.text = prefs.getString('guestEmail') ?? '';
      phoneController.text = prefs.getString('guestPhoneNumber') ?? '';
      provider.uploadedFileUrl = prefs.getString('guestProfileImage') ?? '';
      setState(() {}); // Refresh UI with guest data
    } catch (e) {
     // print("Error loading guest data: $e");
    }
  }

Future<void> _saveUserData(SignupProvider signupProvider) async {
  try {
    if (userId != null) {
      const isStory = false;

      // Only get a new image if one is provided
      if (_image != null) {
        await signupProvider.getimage(context, _image!, isGuestUser, isStory);

        if (signupProvider.uploadedFileUrl == null || signupProvider.uploadedFileUrl.isEmpty) {
          throw Exception("Image upload failed.");
        }
      }

      // Firestore reference
      final userCollection = FirebaseFirestore.instance.collection('users');

      // Update fields dynamically based on user input
      final Map<String, dynamic> updatedData = {
        'name': nameController.text,
        'email': emailController.text,
        'phone_number': phoneController.text,
      };

      // Add the image only if a new one is uploaded
      if (_image != null) {
        updatedData['profile_image'] = signupProvider.uploadedFileUrl;
      }

      // Update the document
      await userCollection.doc(userId!).set(updatedData);

      // Update SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('name', nameController.text);
      prefs.setString('email', emailController.text);
      prefs.setString('phone_number', phoneController.text);

      // Update profile image in SharedPreferences only if changed
      if (_image != null) {
        prefs.setString('profile_image', signupProvider.uploadedFileUrl!);
      }
    setState(() {
      {}
    });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Updated successfully!")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error saving user data: $e")),
    );
  }
}

  // Future<void> _pickImage() async {
  //   final ImagePicker _picker = ImagePicker();
  //   final XFile? pickedFile =
  //       await _picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //     });
  //   }
  // }
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image; // Store the picked image
    });
  }

  Future<void> _logout() async {
    // Show a confirmation dialog
    bool shouldLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Dismiss dialog and return false
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Dismiss dialog and return true
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    // If the user confirmed, proceed with logout
    if (shouldLogout) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (isGuestUser) {
        // Clear guest data from SharedPreferences
        prefs.remove('guestUsername');
        prefs.remove('guestEmail');
        prefs.remove('guestPhoneNumber');
        prefs.remove('guestProfileImage');
      }

      // Sign out the user (if logged in)
      await FirebaseAuth.instance.signOut();

      // Navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<String?> fetchProfileImage() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    return userDoc['profile_image'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    bool isStory = false;
    final signupProvider = Provider.of<SignupProvider>(context);
    final PurchaseProvider purchaseProvider =
        Provider.of<PurchaseProvider>(context);

    return FutureBuilder(
        future: fetchProfileImage(),
        builder: (context, snapshot) {
          return Consumer<SignupProvider>(builder: (context, notifier, child) {
            return Scaffold(
              backgroundColor: Color(0xFF121212),
              appBar: AppBar(
                backgroundColor: Color(0xFF121212),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MainScreen())),
                ),
                title: Text('Profile', style: TextStyle(color: Colors.white)),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    // Guest user view
                    if (isGuestUser)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 50),
                          CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                      '${AppConstant.awsBaseUrl}/389/icons img/499f8320580c7ae3e569ed0c371bf600.png')
                                  as ImageProvider),
                          SizedBox(height: 10),
                          Text(
                            'Guest',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              'Please log in to update your information',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                            child: Text('Login'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(250, 49),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      // Logged-in user view
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    
                                    border: Border.all(color: Colors.red,width: 4),
                                    
                                  ),
                                  child: CircleAvatar(
                                      radius: 50,
                                      child: ClipOval(
                                        
                                        child: _image != null
                                            ? Image.file(
                                                File(_image!.path),
                                                width: 100.0,
                                                height: 100.0,
                                                fit: BoxFit.cover,
                                              )
                                            : firebaseImageUrl != null &&
                                                    firebaseImageUrl!.isNotEmpty
                                                ? Image.network(
                                                    '${AppConstant.awsBaseUrlUpload}$firebaseImageUrl',
                                                    // firebaseImageUrl!,
                                                    width: 100.0,
                                                    height: 100.0,
                                                    loadingBuilder: (context,
                                                        child, loadingProgress) {
                                                      if (loadingProgress == null)
                                                        return child;
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    },
                                                    errorBuilder: (context, error,
                                                        stackTrace) {
                                                      return Image.network(
                                                        '${AppConstant.awsBaseUrl}/389/icons img/499f8320580c7ae3e569ed0c371bf600.png', // Local placeholder image
                                                        width: 100.0,
                                                        height: 100.0,
                                                        fit: BoxFit.cover,
                                                      );
                                                    },
                                                  )
                                                : Image.network(
                                                        '${AppConstant.awsBaseUrl}/389/icons img/499f8320580c7ae3e569ed0c371bf600.png', // Local placeholder for no image
                                                    width: 100.0,
                                                    height: 100.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                      )),
                                ),
                                Positioned(
                                  bottom: -12,
                                  right: -10,
                                  child: IconButton(
                                    icon: Icon(Icons.camera_alt,
                                        color: Colors.orange,size: 30,),
                                    onPressed: () async {
                                      _pickImage();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              nameController.text.isNotEmpty
                                  ? nameController.text
                                  : 'Guest',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            _buildTextField(
                                "Name", nameController, Icons.person_outline),
                            SizedBox(height: 20),
                            _buildTextField(
                                "Email", emailController, Icons.email_outlined),
                            SizedBox(height: 20),
                            _buildTextField("Phone Number", phoneController,
                                Icons.phone_outlined,
                                keyboardType: TextInputType.phone),
                            SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _saveUserData(signupProvider);
                                },
                                child: Text('Save'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(250, 49),
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  backgroundColor: Color(0xFF121212),
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    width: 2.0, // Border width
                                    color: Colors.orange, // Border color
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _logout,
                              child: Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(250, 49),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: Color(0xFF121212),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    width: 2.0, // Border width
                                    color: Colors.orange, // Border color
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    // These buttons should appear for both guest and logged-in users
                    ProfileOutlinedButton(
                      image: "/389/icons img/mdi_tag-remove-outline.png",
                      text: 'Remove ads',
                      onPressed: () async {
                        if (purchaseProvider.products.isNotEmpty) {
                          await purchaseProvider
                              .buyProduct(purchaseProvider.products[0]);
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InAppPurchasePage()),
                        );
                      },
                    ),
                    ProfileOutlinedButton(
                      image: "/389/icons img/ic_baseline-restore.png",
                      text: 'Restore Purchase',
                      onPressed: () async {
                        if (purchaseProvider.products.isNotEmpty) {
                          await purchaseProvider.restoreItem();
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MainScreen()));
                      },
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }
}

class ProfileOutlinedButton extends StatelessWidget {
  final String image;
  final String text;
  final VoidCallback onPressed;

  const ProfileOutlinedButton({
    super.key,
    required this.image,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          side: const BorderSide(color: Colors.orange),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        ),
        icon: Image.network(
          "${AppConstant.awsBaseUrl}$image",
          color: color5,
        ),
        label: Text(
          text,
          style: const TextStyle(fontSize: 18, color: color5),
        ),
      ),
    );
  }
}

Widget _buildTextField(
    String label, TextEditingController controller, IconData icon,
    {TextInputType keyboardType = TextInputType.text}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white),
      inputFormatters: label == "Phone Number"
          ? [
              LengthLimitingTextInputFormatter(10), // Limit input to 10 digits
              FilteringTextInputFormatter.digitsOnly, // Allow digits only
            ]
          : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.orange, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return '$label cannot be empty';
        }
        if (label == "Phone Number" && value.length != 10) {
          return 'Phone number must be 10 digits';
        }
        return null;
      },
    ),
  );
}