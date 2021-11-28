import 'dart:math';

import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/models/chat_user.dart';
import 'package:chat/core/services/chat/chat_service.dart';
import 'dart:async';

class ChatMockService implements ChatService {
//Vamos fazer umas mensagens padrão:

  static final List<ChatMessage> _msgs = [
    // ChatMessage(
    //   id: '1',
    //   text: 'Bom dia teste',
    //   createdAt: DateTime.now(),
    //   userId: '123',
    //   userName: 'Bia',
    //   userImageUrl: 'lib/assets/images/avatar.png',
    // ),
    // ChatMessage(
    //   id: '2',
    //   text: 'Boa tarde teste',
    //   createdAt: DateTime.now(),
    //   userId: '456',
    //   userName: 'Ana',
    //   userImageUrl: 'lib/assets/images/avatar.png',
    // ),
    // ChatMessage(
    //   id: '3',
    //   text: 'Boa noite teste',
    //   createdAt: DateTime.now(),
    //   userId: '789',
    //   userName: 'Barbosa Teste',
    //   userImageUrl: 'lib/assets/images/avatar.png',
    // )
  ];

  static MultiStreamController<List<ChatMessage>>? _controller;
  static final _msgsStream = Stream<List<ChatMessage>>.multi((controller) {
    _controller = controller;
    print('Este é o tamanahho da lista carregada do List: ${_msgs.length}');
    for (var i in _msgs) {
      print('msg carregada da lista :${i.userName} cl> ${i.text}');
    }
    _controller!.add(_msgs.reversed.toList());
  });

  //sempre que chegar uma nova mensagem vc vai receber o valor async
  @override
  Stream<List<ChatMessage>> messageStream() {
    return _msgsStream;
  }

  //Método para salvar o chatmessage dentro da lista de mensagens _msgs
  @override
  Future<ChatMessage> save(String text, ChatUser user) async {
    final newMessage = ChatMessage(
      id: Random().nextDouble().toString(),
      text: text,
      createdAt: DateTime.now(),
      userId: user.id,
      userName: user.name,
      userImageURL: user.imageURL,
    );
    _msgs.add(newMessage);
    for (var i in _msgs) {
      print('Esta é a __msgs dentro ${i.userName} * ${i.text}');
    }
    _controller?.add(_msgs.reversed.toList());
    return newMessage;
  }
}
