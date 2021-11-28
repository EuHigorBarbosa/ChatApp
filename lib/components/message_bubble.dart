import 'dart:io';

import 'package:chat/core/models/chat_message.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool belongsToCurrentUser;
  static const _defautImage = 'lib/assets/images/avatar.png';

  const MessageBubble({
    Key? key,
    required this.message,
    required this.belongsToCurrentUser,
  }) : super(key: key);

  Widget _showUserImage(String imageURL) {
    ImageProvider? provider;
    final uri = Uri.parse(imageURL);
    //Tenho que testar alguns cénarios pois é perigoso receber
    //Posso receber uma imagem por
    //'file://...
    //'http://...
    //'https://...
    print('Imagem Imagem Imagem Imagem $imageURL');
    if (imageURL.contains('assets/images')) {
      provider = AssetImage(_defautImage);
      return CircleAvatar(
          child: ClipRRect(
        child: Image.asset(_defautImage),
        borderRadius: BorderRadius.circular(20.0),
        //20 é o defaut para borderRadius não especificado no circleAvatar
      ));
    } else if (uri.scheme.contains('http')) {
      provider = NetworkImage(uri.toString());
    } else {
      provider = FileImage(File(uri.toString()));
    }
    return CircleAvatar(
      backgroundImage: provider,
    );
  }

  @override
  Widget build(BuildContext context) {
    print(message.userImageURL);
    return Stack(children: [
      Row(
        mainAxisAlignment: belongsToCurrentUser //
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          belongsToCurrentUser //
              ? Expanded(flex: 30, child: Container())
              : SizedBox(),
          Expanded(
            flex: 70,
            child: Container(
              key: ValueKey('ContainerMessage'),
              decoration: BoxDecoration(
                color: belongsToCurrentUser
                    ? Colors.blue
                    : Colors.grey.shade400, //
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: belongsToCurrentUser //
                      ? Radius.circular(12)
                      : Radius.circular(0),
                  bottomRight: belongsToCurrentUser //
                      ? Radius.circular(0)
                      : Radius.circular(12),
                ),
              ),
              width: 180,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 8,
              ),
              child: Column(
                crossAxisAlignment: belongsToCurrentUser //
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Text(
                    message.userName,
                    style: TextStyle(
                        color: belongsToCurrentUser
                            ? Colors.white
                            : Colors.black, //
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    message.text,
                    textAlign: belongsToCurrentUser
                        ? TextAlign.left
                        : TextAlign.right, //
                    style: TextStyle(
                        color: belongsToCurrentUser
                            ? Colors.white
                            : Colors.black), //
                  ),
                ],
              ),
            ),
          ),
          belongsToCurrentUser //
              ? SizedBox()
              : Expanded(flex: 40, child: Container()),
        ],
      ),
      belongsToCurrentUser //
          ? Row(children: [
              Expanded(flex: 30, child: Container()),
              Expanded(flex: 50, child: _showUserImage(message.userImageURL)),
              Expanded(flex: 100, child: Container()),
            ])
          : Row(children: [
              Expanded(flex: 70, child: Container()),
              Expanded(flex: 50, child: _showUserImage(message.userImageURL)),
              Expanded(flex: 30, child: Container()),
            ]),
    ]);
  }
}
