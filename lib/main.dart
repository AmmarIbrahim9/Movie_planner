import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movie_planner/screens/sign_in.dart';
import 'package:movie_planner/services/authentication_services.dart';
import 'firebase_options.dart';

import 'screens/home_screen.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            if (authService.isAuthenticated) {
              return HomeScreen();
            } else {
              return SignInScreen();
            }
          },
        ),
      ),
    );
  }
}
