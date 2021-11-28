import 'dart:io';

import 'package:chat/components/components.dart';
import 'package:chat/core/core.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = false;

  Future<void> _handleSubmit(AuthFormData formData) async {
    // for this.mounted -> https://github.com/flutter/flutter/issues/73000
    if (this.mounted) setState(() => _isLoading = true);
    try {
      if (formData.isLogin) {
        //Login
        //! Aqui está-se usando AuthService() mas na verdade é uma ilusão pois
        //! na verdade está se usando AuthMockService() devido a este ser um
        //! contrutor Factory
        await AuthService().login(
          formData.email,
          formData.password,
        );
      } else {
        //Signup
        //! Aqui está-se usando AuthService() mas na verdade é uma ilusão pois
        //! na verdade está se usando AuthMockService() devido a este ser um
        //! contrutor Factory
        await AuthService().signup(
          formData.name,
          formData.email,
          formData.password,
          formData.image!,
        );
      }
    } catch (error) {
      //Todo - tratar erro
    } finally {
      if (this.mounted) setState(() => _isLoading = false);
    }
    print('AuthPage...');
    print(formData.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(children: [
        Center(
          child: SingleChildScrollView(
            child: AuthForm(onSubmit: _handleSubmit),
          ),
        ),
        if (_isLoading)
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.5),
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
      ]),
    );
  }
}
