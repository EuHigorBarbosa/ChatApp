import 'package:chat/components/message_bubble.dart';
import 'package:chat/core/models/chat_message.dart';
import 'package:chat/core/services/auth/auth_service.dart';
import 'package:chat/core/services/chat/chat_firebase_service.dart';
import 'package:chat/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class Messages extends StatelessWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    return StreamBuilder<List<ChatMessage>>(
        stream: ChatService().messageStream(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Sem mensagens! Vamos conversar?'));
          } else {
            final msgs = snapshot.data!;
            //posso tratar como certeza que vai haver dados pois eu já verifiquei antes
            //o caso de não haver dados. Se chegar aqui é certo que terá mensagens
            for (var i in msgs) {
              print('Esta é a lista de msg:${i.userName} - ${i.text}');
            }
            return ListView.builder(
                reverse: true,
                itemCount: msgs.length,
                itemBuilder: (ctx, i) {
                  // for (final x in ChatFirebaseService.msgsBackup) {
                  //   print('A lista Backup é: ${x.text}');
                  // }
                  print(
                      'Mensagem dentro do listBuilder - ${msgs[i].userName} LB  ${msgs[i].userImageURL}');
                  print(
                      'O belongToCurrent user é ${(msgs[i].userId == currentUser!.id)} pois ${msgs[i].userId} ~ ${currentUser!.id}');
                  return MessageBubble(
                    key: ValueKey(msgs[i].id),
                    message: msgs[i],
                    belongsToCurrentUser: (msgs[i].userId == currentUser!.id),
                  );
                });
          }
        });
  }
}
