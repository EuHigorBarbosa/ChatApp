import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/models/chat_user.dart';
import 'package:chat/core/services/chat/chat_firebase_service.dart';

import 'chat_mock_service.dart';

abstract class ChatService {
//sempre que chegar uma nova mensagem vc vai receber o valor async
  Stream<List<ChatMessage>> messageStream();
  //Método para salvar o chat
  Future<ChatMessage?> save(String text, ChatUser user);

  factory ChatService() {
    //return ChatMockService();
    return ChatFirebaseService();
  }
}
