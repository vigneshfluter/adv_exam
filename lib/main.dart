import 'package:af_exam/firebase_options.dart';
import 'package:af_exam/screens/pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "splash",
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      routes: {
        '/': (_) => const HomePage(),
        'splash': (_) => const Splash(),
      },
    );
    // return GetMaterialApp(
    //   getPages: [
    //     GetPage(name: "/", page: () => const HomePage()),
    //   ],
    // );
  }
}
