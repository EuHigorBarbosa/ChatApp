import 'dart:io';

import 'package:chat/core/core.dart';
import 'package:chat/core/services/auth/auth_firebase_service.dart';

///* como essa classe é abstrata, teremos que
abstract class AuthService {
  ///* aqui implemento a possibilidade de obter o usuario corrente
  ChatUser? get currentUser;

  ///* Usado para gerar uma stream de dados sempre que o usuario moficar
  ///* seu estado. Sempre que o usuario fizer algo que altere seu estado
  ///* vai haver o lançamento de dados por meio de uma stream. O usario se
  ///* deslogou? Envio o dado, usuario mudou algo, envio o dado...
  Stream<ChatUser?> get userChanges;

  ///* É preciso passar nome, email, senha e imagem da pessoa
  Future<void> signup(
    String nome,
    String email,
    String password,
    File? image,
  );

  ///* É preciso passar email e senha
  Future<void> login(
    String email,
    String password,
  );
  //não preciso passar nenhum parametro
  Future<void> logout();

  factory AuthService() {
    ///Ver a aula 384 para saber sobre factories
    //return AuthMockService();
    return AuthFirebaseService();
  }
}
