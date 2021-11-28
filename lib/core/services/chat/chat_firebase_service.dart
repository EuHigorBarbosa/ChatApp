import 'dart:math';

import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/models/chat_user.dart';
import 'package:chat/core/services/chat/chat_service.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatFirebaseService implements ChatService {
  //sempre que chegar uma nova mensagem vc vai receber o valor async
  static final List<ChatMessage> msgsBackup = [];
  @override
  Stream<List<ChatMessage>> messageStream() {
    final store = FirebaseFirestore.instance;
    // snapshotsTakedByMe é uma stream de dados enviados a medida que a
    // collection de mensagens do database for sendo alterada. Esta stream é de um tipo de dado
    // <QuerySnapshot<ChatMessage>> e eu não quero trabalhar com esse tipo pois trabalhar com
    // QuerySnapshot é o mesmo que vender a alma para o Firebase, sempre ficará dependente dessa
    // API. Por isso temos que fazer a conversão e para isso vou
    // fazer um retorno do tipo Stream<List<ChatMessage>>.multi((controller)
    final snapshotsTypeFirebase = store
        .collection('chat')
        .withConverter(
          fromFirestore: _fromFirestore,
          toFirestore: _toFirestore,
        )
        .orderBy('createdAt', descending: true)
        .snapshots();

    //só pra ver os dados printados e ter certeza se tava funcionando na hora
    // return Stream<List<ChatMessage>>.multi((controller) {
    //   snapshotsTypeFirebase.listen((query) {

    //     for (final doc in query.docs) {
    //       print(doc.data().text);
    //     }
    //   });
    // });

    //! essas duas abordagens de return são a mesma coisa. Ainda não
    //! as entendi.
    return snapshotsTypeFirebase.map((snapshot) {
      return snapshot.docs.map((doc) {
        print('print direto do stream - ${doc.data().text}');
        return doc.data();
      }).toList();
    });
    ///////////
    // return Stream<List<ChatMessage>>.multi((controller) {
    //   snapshotsTypeFirebase.listen((dadoRecemChegadosDaStreamFirebase) {
    //     List<ChatMessage> lista =
    //         dadoRecemChegadosDaStreamFirebase.docs.map((doc) {
    //       return doc.data();
    //     }).toList();
    //     controller.add(lista);
    //   });
    // });
  }

  //Método para salvar o texto de digitado de um usuario no firebase
  // Antes havia uma conversão de dados argumentos => Map e depois de Map => ChatMessage
  // Agora, usa-se o .withConverter para que seja add no firebase os dados do ChatMessage
  @override
  Future<ChatMessage?> save(String text, ChatUser user) async {
    //1º coisa: criar uma referencia (como se fosse um endereço lá no firebase)
    final store = FirebaseFirestore.instance;
    final Ref = store.collection('chat');

    /// o add espera um dado do tipo ChatMessage. Por isso eu gerei esse chatMessage aqui.
    /// Esse dado tipo ChatMessage poderia ter sido passado diretamente no construtor, mas
    /// o professor resolveu passar texto e user pra fazer a implementação mock do inicio da aula
    final msg = ChatMessage(
      id: '',
      text: text,
      createdAt: DateTime.now(),
      userId: user.id,
      userName: user.name,
      userImageURL: user.imageURL,
    );

    final docRef = await Ref.withConverter(
      fromFirestore: _fromFirestore,
      toFirestore: _toFirestore,
    ).add(msg);

    /// A partir do <docReference> retornado pelo .add eu consigo tirar um
    /// snapshot usando o .get.
    /// O data desse snapshot já é do tipo ChatMessage, por isso posso retorná-lo
    final snapshotDocument = await docRef.get();
    return snapshotDocument.data()!;
  }

  ChatMessage _fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    SnapshotOptions? options,
  ) {
    return ChatMessage(
      id: doc.id,
      text: doc['text'],
      createdAt: DateTime.parse(doc['createdAt']),
      userId: doc['userId'],
      userName: doc['userName'],
      userImageURL: doc['userImageURL'],
    );
  }

  Map<String, dynamic> _toFirestore(
    ChatMessage msg,
    SetOptions? options,
  ) {
    return {
      'text': msg.text,
      'createdAt': msg.createdAt.toIso8601String(),
      'userId': msg.userId,
      'userName': msg.userName,
      'userImageURL': msg.userImageURL,
    };
  }

// ================= Versão Original - sem o converter ==============abstract@override
  //Método para salvar o texto de digitado de um usuario no firebase
  // 1º - Texto digitado + ChatUser em Map<String, dynamic> para ser salvo no firebase
  // 2º - Converte o Map em =====> ChatMessage
  // @override
  // Future<ChatMessage?> save(String text, ChatUser user) async {
  //   //Deve-se inicialmente criar uma referencia (como se fosse um endereço lá no firebase)

  //   final store = FirebaseFirestore.instance;
  //   final Ref = store.collection('chat');

  //   /// Agora eu quero salvar uma mensagem no firebase. Eu só consigo salvar no
  //   /// firebase se eu transformar o tipo de dado ChatMessage em um Map<String, Dynamic>.
  //   final docRef = await Ref.add({
  //     'text': text,
  //     'createdAt': DateTime.now().toIso8601String(),
  //     'userId': user.id,
  //     'userName': user.name,
  //     'userImageURL': user.imageURL,
  //   });

  //   /// A partir do <docReference> retornado pelo .add eu consigo tirar um
  //   /// snapshot usando o .get
  //   final snapshotDocument = await docRef.get();
  //   final data = snapshotDocument.data()!;
  //   msgsBackup.add(ChatMessage(
  //     id: snapshotDocument.id,
  //     text: data['text'],
  //     createdAt: DateTime.parse(data['createdAt']),
  //     userId: data['userId'],
  //     userName: data['userName'],
  //     userImageURL: data['userImageURL'],
  //   ));
  //   return ChatMessage(
  //     id: snapshotDocument.id,
  //     text: data['text'],
  //     createdAt: DateTime.parse(data['createdAt']),
  //     userId: data['userId'],
  //     userName: data['userName'],
  //     userImageURL: data['userImageURL'],
  //   );
  // }
} //
