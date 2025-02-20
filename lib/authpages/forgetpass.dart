import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gymkhana_app/authpages/signup.dart';
import 'package:gymkhana_app/constants/colours.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Forgetpass extends StatefulWidget{
  @override
  State<Forgetpass> createState() => _ForgetpassState();
}

class _ForgetpassState extends State<Forgetpass> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = "";
  Future<void>passrecovery()async{
    await _auth.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Password reset link send"),
      backgroundColor: CustomColors.backgroundColor,
      duration: Duration(seconds: 2),
    ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Container(
            //padding:EdgeInsets.only(top: 50,left: 120,right: 120),
            alignment: Alignment.bottomCenter,
            height: 100,
            // color: CustomColors.primaryColor,
            child: Text("Password Recovery",style: TextStyle(color:Colors.white,fontSize: screenWidth*0.07),),
          ),
          Container(
            height: 100,
            alignment: Alignment.center,
            //  color: Colors.blueAccent,
            child: Text("Enter your Registered mail",style: TextStyle(color:Colors.white,fontSize: screenWidth*0.05),),
          ),
          Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: TextFormField(
                  //   controller: mailcontroller,
                  style:(TextStyle(color: Colors.white,fontSize: 18)),
                  validator: (value){
                    if(value==null||value.isEmpty){
                      return "please enter the Email";
                    }
                    return null;
                  },
                  onChanged: (value){
                    setState(() {
                      email=value;
                    });
                  },
                  decoration: InputDecoration(
                  prefixIcon: Icon(Icons.mail, size: screenWidth * 0.06),
                  hintText: "Enter your email",
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
          // Container(
          //     margin: EdgeInsets.only(top: 30,left: 30,right: 30),
          //     height: 50,
          //     width: 380,
          Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColors.secondaryColor,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.25,
                    ),
                  ),
                onPressed: (){
                  passrecovery();
                  // if(_formkey.currentState!.validate()){
                  //   setState(() {
                  //    email=mailcontroller.text;
                  //  });
                  //   resetpass();
                  //  }
                },
                child: Text("Signup", style: TextStyle(fontSize: screenWidth * 0.05, color: Colors.white),),
              ),
          Container(
              margin: EdgeInsets.only(top: 30),
              alignment: Alignment.topCenter,
              height: 100,
              //color: Colors.blueAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account ? ",style: TextStyle(color: TextColors.SecondaryTextColor,fontSize: 18),),
                  InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>SignupPage()));
                      },child: Text("SignUP",style: TextStyle(color: Colors.blueAccent,fontSize: 20),))
                ],
              )
          )
        ],
      ),
    );
  }
}