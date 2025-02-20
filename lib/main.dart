import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:gymkhana_app/home.dart';
import 'firebase_options.dart';
import 'package:gymkhana_app/authpages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await supabase.Supabase.initialize(
    url: 'https://rvozhfdjrwksoutqwcub.supabase.co', // Replace with your Supabase API URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ2b3poZmRqcndrc291dHF3Y3ViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzM1NTQ2NTksImV4cCI6MjA0OTEzMDY1OX0.e1Q6iBcTjkssfx9AtUpzJ6e5Aa-B7tLt9ZO2oMbeRIQ', // Replace with your Supabase anonymous API key
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  firebase_auth.User? user = firebase_auth.FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:user==null ? LoginPage() : HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

