import 'package:chat/core/core.dart';
import 'package:chat/core/services/auth/auth_mock_service.dart';
import 'package:chat/core/services/notification/chat_notification_service.dart';
import 'package:chat/pages/loading_page.dart';
import 'package:chat/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

class AuthOrAppPage extends StatelessWidget {
  const AuthOrAppPage({Key? key}) : super(key: key);
  //metodo utilizado para inicializar o app Firebase
  Future<void> init(BuildContext context) async {
    print('O INIT foi executado...');
    //Initializes a new [FirebaseApp] instance
    //by [name] and [options] and returns the created app. This method should be
    //called before any usage of FlutterFire plugins.
    //The default app instance cannot be initialized here and should be created
    //using the platform Firebase integration.
    await Firebase.initializeApp();
    //print('Este é o nome do app : ${Firebase.app()}');
    print('O Firebase.initialize foi executado...');
    //Uso o estado desse future para contruir telas. Se estiver modo waiting eu carreto LoadingPage
    //Do contrário eu chamo o streamBuilder<ChatUser>
    await Provider.of<ChatNotificationService>(
      context,
      listen: false,
    ).init(); //Lá dentro do ChatNotificationService tem um metodo init()...é esse método
    //que essa função está chamando
  }

  @override
  Widget build(BuildContext context) {
    //* Foi retirado o Scaffold daqui pois as outras paginas estão utilizando
    //* o scaffold já.
    return FutureBuilder(
        //Aqui o futureBuilder foi criado para criar widgets de acordo com o Future vindo do Firebase.
        future: init(context),
        builder: (ctx, snapshot) {
          print(
              'O connecState do FutureBuilder é: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingPage();
          } else {
            if (snapshot.connectionState == ConnectionState.done) {
              print('Done for Firebase.initializeApp();');
            }
            //Aqui está usando o streamBuilder pois estamos contruindo widgets baseado em uma
            //stream de dados do tipo ChatUser pois essa stream de dados só existirá se houver
            //user autenticado, caso contrario vai build a pg de autenticação
            return StreamBuilder<ChatUser?>(
              //! Aqui está-se usando AuthService() mas na verdade é uma ilusão pois
              //! na verdade está se usando AuthMockService() devido a este ser um
              //! contrutor Factory
              stream: AuthService().userChanges,
              builder: (ctx, snapshot) {
                print(
                    'O connecState do StreamBuilder é: ${snapshot.connectionState}');
                print('o snapshot.data me fornece: ${snapshot.data}');
                if (snapshot.hasError) {
                  print('um erro foi encontrado em Firebase.initializeApp();');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return LoadingPage();
                } else {
                  return snapshot.hasData ? ChatPage() : AuthPage();
                }
              },
            );
          }
        });
  }
}
