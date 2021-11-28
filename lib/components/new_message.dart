import 'package:chat/core/core.dart';
import 'package:chat/core/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({Key? key}) : super(key: key);

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  String _enteredMessage = '';
  final _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    //Como o save precisa saber qual o usuario está logado então vamos
    //utilizar o serviço do Auth.
    final user = AuthService().currentUser;

    if (user != null) {
      final msg = await ChatService().save(_enteredMessage, user);
      print(
          '================================O valor da mensagem a ser salva é : ${msg!.id}');
      _messageController.clear();
    }
  }

  ///* Textfiled para salvar as mensagens. Ao digitar a pessoa vai clicar no botão enviar e
  ///* essa mensagem vai ser salva por meio do serviço ChatService().save
  ///* a cada toque de tecla o onChange vai carregar na variavel _enteredMessage o valor que estiver presente
  ///* no textfield a cada teclada
  ///* Ele utiliza o _messageController só pra dar o clear depois que salvar os dados
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: _messageController,
            onChanged: (msg) => setState(() => _enteredMessage = msg),
            onSubmitted: (_) {
              if (_enteredMessage.trim().isNotEmpty) {
                _sendMessage();
              }
            },
            decoration: InputDecoration(labelText: 'Enviar mensagem...'),
          )),
          IconButton(
            onPressed: _enteredMessage.trim().isEmpty ? null : _sendMessage,
            icon: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
