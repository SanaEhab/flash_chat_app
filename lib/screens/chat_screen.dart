
import 'package:flutter/material.dart';
import 'package:flash_chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {

  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;

  late String messageText;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() async{
    try{
      final user = _auth.currentUser;
      if(user != null){
        loggedInUser = user;
      }
    }catch(e){
      print(e);
    }
  }

  // void getMessages() async{
  //   final messages = await _firestore.collection('messages').get();
  //   for(var message in  messages.docs){
  //     print(message.data());
  //   }
  // }

  void meassgesStream() async{
    await for (var snapshot in _firestore.collection('messages').snapshots()){
      for(var message in  snapshot.docs){
            print(message.data());
          }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                meassgesStream();
                // _auth.signOut();
                // Navigator.pop(context);
              }),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('messages').snapshots(),
                builder: (context,snapshot) {
                  if(!snapshot.hasData){
                    return const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    );
                  }
                    final messages = snapshot.data;
                    List<Text> messageWidgets = [];
                    for(var message in messages!.docs){
                      final messageText = message.data();
                      final messageSender = message.data();

                      final messageWidget = Text('$messageText from $messageSender');
                      messageWidgets.add(messageWidget);
                    }
                    return Column(
                      children: messageWidgets,
                    );
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //messageText + loggedInUser.email
                      _firestore.collection('messages').add({
                        'text':messageText,
                        'sender':loggedInUser.email
                      });
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}