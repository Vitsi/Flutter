import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'Authentication/Admin/AdminService.dart';
import 'Authentication/Admin/Admin_page.dart';
import 'Authentication/AuthNotifier.dart';
import 'Authentication/AuthService.dart';
import 'Authentication/User/Login_page.dart';
import 'Authentication/User/Registeration_page.dart';
import 'Authentication/WelcomeScreen.dart';
//import 'Qr/QrCodeService.dart';
import 'Qr/QrCodeService.dart';
import 'Qr/drawer/ProfileService.dart';
import 'Qr/main_qr.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        Provider(create: (_) => AuthService('http://localhost:5158')),
        Provider(create: (_) => AdminService('http://localhost:5158')),
        Provider(create: (_) => QrCodeService('http://localhost:5189')),
        Provider(create: (_) => ProfileService('http://localhost:5158')),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QR Code Studio',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          appBarTheme: AppBarTheme(
            // backgroundColor: const Color.fromARGB(222, 207, 187, 253),
            backgroundColor: Color.fromARGB(222, 37, 10, 105),
            titleTextStyle: TextStyle(
              color: Colors.white, // Set text color to white
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
        ),
        home: HomeScreen(),
        routes: {
          '/Welcome': (context) => HomeScreen(),
          '/Login': (context) => LoginScreen(),
          '/Register': (context) => RegisterScreen(),
          '/MainQR': (context) => MainQRPage(),
          '/AdminPage': (context) => Builder(
                builder: (BuildContext context) => AdminPage(),
              ),
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthNotifier>().isLoggedIn;

    if (isLoggedIn) {
      return LoggedInScreen();
    } else {
      return WelcomeScreen();
    }
  }
}

class LoggedInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logged In'),
        leading: IconButton(
          icon: SvgPicture.asset(
            'svg/black.svg',
            height: 24.0, 
          ),
          onPressed: () {
             Navigator.pushReplacementNamed(context, '/MainQR');
          },
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<AuthNotifier>().logout();
          },
          child: Text('Logout'),
        ),
      ),
    );
  }
}
 