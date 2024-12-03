import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Message {
  final String content;
  final bool isEncrypted;
  final DateTime timestamp;

  Message({required this.content, required this.isEncrypted, required this.timestamp});
}

class MessageListScreen extends StatelessWidget {
  final List<Message> messages;

  const MessageListScreen({Key? key, required this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message History'),
      ),
      body: messages.isEmpty
          ? Center(
              child: Text(
                'No messages yet',
                style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(
                      message.content,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500,
                        color: message.isEncrypted ? Colors.green : Colors.blue,
                      ),
                    ),
                    subtitle: Text(
                      '${message.isEncrypted ? "Encrypted" : "Decrypted"} - ${message.timestamp.toString().split('.')[0]}',
                      style: GoogleFonts.roboto(fontSize: 12),
                    ),
                    leading: Icon(
                      message.isEncrypted ? Icons.lock : Icons.lock_open,
                      color: message.isEncrypted ? Colors.green : Colors.blue,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
