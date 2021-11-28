import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:chat/core/core.dart';
import 'package:chat/core/services/auth/auth_service.dart';

class AuthMockService implements AuthService {
  static final _defaultUser = ChatUser(
    email: 'ana@gmail.com',
    id: '456',
    name: 'Ana',
    imageURL: 'lib/assets/avatar.png',
  );
  static Map<String, ChatUser> _users = {};
  static ChatUser? _currentUser;

  ///* Esse controler do tipo multiController foi criado para ser utilizado
  ///* na criação de stream.multi
  static MultiStreamController<ChatUser?>? _controller;

  ///* Esse stream.multi
  static final _userStream = Stream<ChatUser?>.multi((controller) {
    _controller = controller;
    //agora ficou disponivel fora desse escopo o controller da stream
    //Estou gerando inicialmente um evento usuario defaut para o programa
    //interpretar esse evento e ir direto para a tela de autenticação;
    _updateUser(_defaultUser);
    //inicio o programa com _defautUser no usuario corrente, por
    //já ter um usuario pre-cadastrado ele vai para a tela de chat
  });

  @override
  ChatUser? get currentUser {
    return _currentUser;
  }

  ///* Usado para gerar uma stream de dados sempre que o usuario moficar
  ///* seu estado. Sempre que o usuario fizer algo que altere seu estado
  ///* eu uso o _controller?.add para adicionar um evento na stream
  ///* e todos vão escutar e se comportar conforme o estado do snapshot da strem
  ///* O usario se deslogou? Add o dado na stream, usuario mudou algo, add o dado...e assim vai
  @override
  Stream<ChatUser?> get userChanges {
    return _userStream;
  }

  ///* É preciso passar nome, email, senha e imagem da pessoa
  @override
  Future<void> signup(
      String name, String email, String password, File? image) async {
    print('Este é o caminho do image.path${image?.path}');

    ///* Crio um novo user a ser cadastrado
    final newUser = ChatUser(
        email: email,
        id: Random().nextDouble().toString(),
        name: name,
        imageURL: image?.path ?? 'lib/assets/avatar.png');

    ///* faço a lista crescer adicionando mais um item no Map _users
    _users.putIfAbsent(email, () => newUser);
    print('Esta é alista atual $_users');

    ///* Uma vez qu eeu adicionei o novo usuario na minha lista eu já
    ///* posso fazer o login, então eu chamo o _utpdate(User) para fazer isso
    _updateUser(newUser);
  }

  ///* É preciso passar email e senha
  @override
  Future<void> login(String email, String password) async {
    ///faz com que o user da key email passado no formulario seja o current user
    _updateUser(_users[email]);

    /// retorna uma instancia de chatUser por meio da chave e-mail.
    /// A função _updateUser vai fazer o current user ser colocado na
    /// stream para informar aos listeners que o usuario é válido.
    /// Se um e-mail for colocado e não retornar user nenhum, então continua null.
  }

  //não preciso passar nenhum parametro
  @override
  Future<void> logout() async {
    //finalizo como iniciarei... com null no usuario corrente
    ///* Tanto no inicio como ao final o usario é null
    _updateUser(null);
  }

  ///* Essa função atualiza o status do user e, na segunda linha,
  ///* atualiza o status na stream de dados
  static void _updateUser(ChatUser? user) {
    _currentUser = user;

    _controller?.add(_currentUser);
  }
}
