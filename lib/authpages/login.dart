import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:gymkhana_app/authpages/forgetpass.dart';
import 'package:gymkhana_app/authpages/signup.dart';
import 'package:gymkhana_app/constants/colours.dart';
import 'package:gymkhana_app/home.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = "";
  String password = "";
  var _isObsecured = true;

  Future<void> login() async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;
      if (user!.emailVerified) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomePage();
        }));
      } else {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Email verification link sent",
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: CustomColors.primaryColor,
            duration: Duration(seconds: 2),
          ),
        );
        await user.reload();
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed: ${e.message}'),
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
            // Email field
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Enter a valid Email';
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
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
                    borderSide: BorderSide(
                      color: TextColors.SecondaryTextColor,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            // Password field
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Enter a password of at least 6 characters";
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
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
                  hintText: "Enter your password",
                  hintStyle: TextStyle(
                    color: const Color.fromARGB(255, 146, 140, 140),
                    fontSize: screenWidth * 0.045,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: const Color.fromARGB(255, 146, 140, 140),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: screenHeight * 0.02,
                right: screenWidth * 0.07,
              ),
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Forgetpass()),
                  );
                },
                child: Text(
                  'Forgot password?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Spacer(),
            // Login Button
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.secondaryColor,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.25,
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      login();
                    }
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),
                  ),
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      print("login");
                      login();
                    }
                  },
                  child: Text(
                    'Login as Admin',
                    style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // Sign Up prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );
                      },
                      child: Text(
                        "SignUp",
                        style: TextStyle(color: CustomColors.secondaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
      )
      )
      )
    );
  }
}
