import 'dart:io';

import 'package:chat/components/components.dart';
import 'package:chat/core/core.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(AuthFormData) onSubmit;
  const AuthForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _formData = AuthFormData();
  File? _imagePicked;

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Theme.of(context).errorColor,
    ));
  }

  void _submit() {
    //os campos validate dos TextFields retornam null se estiverem
    // válidos. Por isso, caso esteja tdo certo a variavel isValid
    final isValid = _formKey.currentState?.validate() ?? false;
    //null ?? false = false; true ?? false = true;
    if (!isValid) return;

    if (_formData.image == null && _formData.isSignup) {
      return _showError('imagem não selecionada');
    }

    widget.onSubmit(_formData);
    //Essa é uma maneira indireta de se passar dados para um componente filho, não é uma tela
    //em que há navegation...é uma passagem de dados de modo reverso, do filho pro pai utilizando uma
    //callback
  }

  void handleImagePick(File image) {
    _formData.image = image;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_formData.isSignup)
                  UserImagePicker(
                    onImagePick: handleImagePick,
                  ),
                if (_formData.isSignup)
                  TextFormField(
                    key: ValueKey('name'),
                    initialValue: _formData.name,
                    onChanged: (name) => _formData.name = name,
                    decoration: InputDecoration(labelText: 'Nome'),
                    validator: (_name) {
                      final name = _name ?? '';
                      if (name.trim().length < 5) {
                        return 'Nome deve ter no mínimo 5 caracteres';
                      }
                      return null;
                    },
                  ),
                TextFormField(
                  key: ValueKey('email'),
                  initialValue: _formData.email,
                  onChanged: (email) => _formData.email = email,
                  decoration: InputDecoration(labelText: 'e-mail'),
                  validator: (_email) {
                    final email = _email ?? '';
                    if (!email.contains('@')) {
                      return 'Digite um e-mail válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  key: ValueKey('password'),
                  initialValue: _formData.password,
                  onChanged: (password) => _formData.password = password,
                  decoration: InputDecoration(labelText: 'Senha'),
                  validator: (_password) {
                    final password = _password ?? '';
                    if (password.length < 6) {
                      return 'Senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_formData.isLogin ? 'Entrar' : 'Cadastrar'),
                ),
                TextButton(
                  child: Text(
                    _formData.isLogin
                        ? 'Criar uma nova conta?'
                        : 'Já possui conta?',
                  ),
                  onPressed: () {
                    setState(() => _formData.toggleAuthMode());
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
