import 'package:flutter/material.dart';
import '../models/message_model.dart';

class MessageTile extends StatelessWidget {
  final Message message;

  const MessageTile({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(message.sender),
      subtitle: Text(message.content),
      trailing: Text(
        '${message.timestamp.hour}:${message.timestamp.minute}',
      ),
    );
  }
}

