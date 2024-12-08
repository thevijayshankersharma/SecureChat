import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message.dart';
import 'chat_screen.dart';

class ChatHistoryScreen extends StatelessWidget {
  final List<String> chatContacts;

  const ChatHistoryScreen({Key? key, required this.chatContacts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat History'),
        backgroundColor: Colors.teal,
      ),
      body: chatContacts.isEmpty
          ? Center(
              child: Text(
                'No chats yet',
                style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: chatContacts.length,
              itemBuilder: (context, index) {
                final contact = chatContacts[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(contact[0]),
                    backgroundColor: Colors.teal,
                  ),
                  title: Text(
                    contact,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(phoneNumber: contact),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

