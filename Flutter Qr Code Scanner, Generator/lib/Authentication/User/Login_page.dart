//import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../AuthService.dart';
import 'Registeration_page.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'),
      actions: [
          IconButton(
            icon: SvgPicture.asset(
              'svg/white.svg',
              height: 24.0, 
            ),
            onPressed: () { 
              Navigator.pushReplacementNamed(context, '/Welcome');
              (
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );}
      )]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               SvgPicture.asset(
                'svg/login.svg',
                height: 200.0,
              ),              
              // Username input
              SizedBox(height: 16.0),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 16.0),
              // Password input
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  final username = _usernameController.text.trim();
                  final password = _passwordController.text.trim();

                  final authService =
                      Provider.of<AuthService>(context, listen: false);

                  final adminToken =
                      await authService.adminLogin(context, username, password);
                  if (adminToken != null) {
                    Navigator.pushReplacementNamed(context, '/AdminPage');
                  } else {
                    final userToken =
                        await authService.login(context, username, password);
                    if (userToken != null) {
                      Navigator.pushReplacementNamed(context, '/MainQR');
                    } else {
                     setState(() {
                        // Set error message based on the response from AuthService
                        _errorMessage = 'Login failed. Invalid username or password.';
                      });
                    }
                  }
                },
                child: Text('Login'),
              ),

              SizedBox(height: 16.0),
              // Link to the registration page
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text('Don\'t have an account? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
