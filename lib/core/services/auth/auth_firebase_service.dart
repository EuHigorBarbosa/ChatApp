import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:chat/core/core.dart';
import 'package:chat/core/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuthFirebaseService implements AuthService {
  static ChatUser? _currentUser;

  ///* Aqui estou fazendo com que a cada vez que o stream<User?> do
  ///* firebase alterar eu também vou alterar o meu stream do ChatUser.
  ///* Eu faço isso convertendo o User em ChatUser por meio do for in authChanges
  ///* É como se eu aproveitasse um fluxo de dados User que já existe, e a cada
  ///* dado<User?> nesse fluxo eu converto para dado<ChatUser>
  static final _userStream = Stream<ChatUser?>.multi((controller) async {
    print('XXXXXXXX chega na parte de criar a stream do firebaseAuth');
    FirebaseAuth auth = FirebaseAuth.instance;
    final authChanges = auth.authStateChanges();
    print(
        'A strema do firebaseAuth é broadcast? -> ${authChanges.isBroadcast}');

    print(
        'YYYYYYYY passou pela criação do stream a instancia do firebaseAuth.instance.authStateChanges');

    //fazer um for para cada um dos elementos que eventualmente possam
    //chegar aqui ..para cada usuario eu consigo percorrer um for
    await for (final user in authChanges) {
      print('Este é o user do for in que percorre authChanges: $user');
      _currentUser = user == null ? null : _toChatUser(user);
      print('Este é o _currentUser que será add na stream: $_currentUser');
      controller.add(_currentUser);
    }
  });

  @override
  ChatUser? get currentUser {
    return _currentUser;
  }

  ///* Usado para gerar uma stream de dados sempre que o usuario moficar
  ///* seu estado. Sempre que o usuario fizer algo que altere seu estado
  ///* vai haver o lançamento de dados por meio de uma stream. O usario se
  ///* deslogou? Envio o dado, usuario mudou algo, envio o dado...
  @override
  Stream<ChatUser?> get userChanges {
    return _userStream;
  }

  ///* É preciso passar nome, email, senha e imagem da pessoa
  @override
  Future<void> signup(
      String name, String email, String password, File? image) async {
    final auth = FirebaseAuth.instance;
    UserCredential credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user == null) return;
    //? 1. Atualizar a imagem do usuario
    //É necessário criar um nome para a imagem de perfil do usuario
    final imageName = '${credential.user!.uid}-imagetype';
    //Depois que o usuario existir eu vou fazer o upload da foto do usuario
    //eu preciso desse await pois se não eu vou receber uma future e quero receber uma string
    final imageURL = await _uploadUserImage(image, imageName);

    //? 2. Atualizar os atributos do usuario
    await credential.user?.updateDisplayName(name);
    await credential.user?.updatePhotoURL(imageURL);
    //? 3. salvar os usuarios no banco de dados
    _currentUser = _toChatUser(credential.user!, imageURL, name);
    await _saveChatUser(_currentUser!);
    print('Esse é o valor do imageUrl do novo usuario cadastrado: $imageURL');
  }

  ///* É preciso passar email e senha
  @override
  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //não preciso passar nenhum parametro
  @override
  Future<void> logout() async {
    FirebaseAuth.instance.signOut();
    //parece que há um método especifico pra isso no Firebase
  }

  //Função principal ==>  retornar o url da imagem que eu acabei de fazer o upload pra o firebaseStorage
  //Recebe como argumento o arquivo e o nome da imagem.
  //Se a imagem for nula eu retorno nulo(não tenho a url gerada)
  //Caso a imagem seja válida eu pego a instancia do Firebase e
  //gero a referencia do bucket que vou utilizar para armazenar. Como vou utilizar o bucket padrão eu
  //não preciso passar nenhum path dentro de ref().
  //Quando utilizo o ref().child("nome_da_pasta_vou_criar_no_FirebaseStorage").child("nome_da_imagem")
  //Essa referencia será utilizada para fazer o upload da imagem nesse caminho e executará
  //aquela void quando a future se completar.
  //Depois do upload da imagem vamos retornar a url de download
  Future<String?> _uploadUserImage(File? image, String imageName) async {
    if (image == null) return null;
    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('user_images').child(imageName);
    //a partir dessa referencia que eu faço o upload do arquivo
    await imageRef.putFile(image).whenComplete(() {});
    return await imageRef.getDownloadURL();
  }

  static ChatUser _toChatUser(User user, [String? imageURL, String? name]) {
    print('Esse é o valor do imageUrl do novo usuario cadastrado: $imageURL');
    print(
        'Esse é o valor do user.photoURL do novo usuario cadastrado: ${user.photoURL}');

    return ChatUser(
      id: user.uid,
      name: name ?? user.displayName ?? user.email!.split('@')[0],
      email: user.email!,
      imageURL: imageURL ?? user.photoURL ?? 'lib/assets/images/avatar.png',
    );
  }

  //Vou salvar o usuario no FireStore...por isso criei essa instancia
  //A função store.collection cria uma coleção com seus documentos...
  //Então aqui criou-se a coleção user com o documento user.id
  //Primeiro se cria o caminho no qual o dado vai ser guardado
  Future<void> _saveChatUser(ChatUser user) async {
    final storeInstance = FirebaseFirestore.instance;
    final docRef = storeInstance.collection('users').doc(user.id);
    //A partir da referencia criada eu vou usar o .set para criar o map que
    //será armazenado na coleção que criei
    return docRef.set(
      {
        'name': user.name,
        'email': user.email,
        'imageURL': user.imageURL,
      },
    );
  }
}
