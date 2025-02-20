import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymkhana_app/home.dart';
import 'package:gymkhana_app/authpages/login.dart';
import 'package:gymkhana_app/constants/colours.dart';

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  String email = "";
  String domain = "iiti.ac.in";
  String password = "";
  var _isObsecured = true;

  Future<void> signUp(bool isAdmin) async {
  try {
    // Create user with email and password
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = credential.user;

    if (user != null) {
      // Extract username from email
      String username = _usernameController.text.trim().isEmpty
            ? email.split('@')[0]
            : _usernameController.text.trim();

      // Send email verification if not already sent
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email verification link sent'),
            backgroundColor: CustomColors.primaryColor,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Poll for email verification status
      int attempts = 0;
      const maxAttempts = 12; // Max attempts to check email verification status (12 = 1 minute)
      
      // Check email verification every 5 seconds until verified or max attempts reached
      UserCredential _credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
        User? _user = _credential.user;
      while (!_user!.emailVerified && attempts < maxAttempts) {
        _credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
        _user = _credential.user;
        await Future.delayed(Duration(seconds: 5)); // Wait 5 seconds before next check
        // await _user.reload(); // Reload user data
        attempts++;
        print(attempts);
      }
      // await user.reload();

      if (_user.emailVerified) {
        print("verified");
        // Once the email is verified, store user info in Firestore
        await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
          'username': username, // Store extracted username
          'email': email,
          'role': isAdmin ? 'admin' : 'user', // Default role
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      }    else {
        print("not verified");
        user.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email verification timed out or failed. Please try again.'),
            backgroundColor: CustomColors.primaryColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sign up failed: ${e.message}'),
        backgroundColor: CustomColors.primaryColor,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child:Form(
              key: _formKey,
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.08),
              Image.asset('assets/images/IITI.png', height: screenHeight * 0.22),
              SizedBox(height: screenHeight * 0.05),
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: TextFormField(
                  validator: (value) => value!.isEmpty ? "Enter a valid email" : null,
                  onChanged: (value) => setState(() => email = value),
                  style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.mail, size: screenWidth * 0.06),
                  hintText: "Email @iiti.ac.in",
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 146, 140, 140),
                    fontSize: screenWidth * 0.045,
                  ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: TextFormField(
                  controller: _usernameController,
                  validator: (value) => value!.isEmpty ? "Enter a valid username" : null,
                  style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, size: screenWidth * 0.06),
                  hintText: "Username",
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 146, 140, 140),
                    fontSize: screenWidth * 0.045,
                  ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: TextFormField(
                  validator: (value) =>
                      value!.length < 6 ? "Password must be at least 6 characters" : null,
                  onChanged: (value) => setState(() => password = value),
                  obscureText: _isObsecured,
                  style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.045),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, size: screenWidth * 0.06),
                  suffixIcon: IconButton(
                  onPressed: () {
                      setState(() {
                        _isObsecured = !_isObsecured;
                      });
                    },
                    icon: _isObsecured
                        ? Icon(Icons.visibility_off)
                        : Icon(Icons.visibility),
                  ),
                  hintText: "Password",
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 146, 140, 140),
                    fontSize: screenWidth * 0.045,
                  ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.secondaryColor,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.25,
                    ),
                  ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (!email.endsWith(domain)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Enter a valid Email",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          backgroundColor: CustomColors.primaryColor,
                        ),
                      );
                    } else {
                      signUp(false);
                    }
                  }
                },
                child: Text("SignUp", style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),),
              ),
              SizedBox(height: screenHeight * 0.02),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.secondaryColor,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.25,
                    ),
                  ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (!email.endsWith(domain)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Enter a valid Email",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          backgroundColor: CustomColors.primaryColor,
                        ),
                      );
                    } else {
                      signUp(true);
                    }
                  }
                },
                child: Text("Signup as Admin", style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),),
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(color: Colors.white)),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    ),
                    child: Text("Login", style: TextStyle(color: CustomColors.secondaryColor)),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
      )
    )
    );
  }
}
