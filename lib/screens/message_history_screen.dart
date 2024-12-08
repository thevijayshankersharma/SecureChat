import 'package:flutter/material.dart';
import 'package:securechat/models/message.dart';

class MessageHistoryScreen extends StatelessWidget {
  final List<Message> messages;

  const MessageHistoryScreen({Key? key, required this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message History'),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
          return ListTile(
            title: Text(message.content),
            subtitle: Text('To: ${message.recipient}'),
            trailing: Text(message.timestamp.toString()),
          );
        },
      ),
    );
  }
}

