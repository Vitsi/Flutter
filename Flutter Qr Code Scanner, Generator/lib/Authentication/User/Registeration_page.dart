//import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../AuthService.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register'), actions: [
        IconButton(
            icon: SvgPicture.asset(
              'svg/white.svg',
              height: 24.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/Login');
              (
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            })
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'svg/register.svg',
                  height: 200.0,
                ),
                // Username input
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                SizedBox(height: 16.0),
                // Email input
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => _validateEmail(value!),
                ),
                SizedBox(height: 16.0),
                // Password input
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: 'Password'),
                  validator: (value) => _validatePassword(value!),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final emailAdress = _emailController.text.trim();
                      final username = _usernameController.text.trim();
                      final password = _passwordController.text.trim();

                      final authService =
                          Provider.of<AuthService>(context, listen: false);

                      if (username.startsWith("admin_")) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "admin_ is a keyword reserved for admin, choose another username"),
                          backgroundColor: Colors.red,
                        ));
                      } else {
                        final registrationResult = await authService.register(
                          username,
                          emailAdress,
                          password,
                        );

                        if (registrationResult) {
                          Navigator.pushReplacementNamed(context, '/Login');
                        } else {
                          // Registration failed (user already exists .. maybe other issues )
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "User already exists or registration failed."),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                    }
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
