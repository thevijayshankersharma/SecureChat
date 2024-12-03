import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Message {
  final String content;
  final bool isEncrypted;
  final DateTime timestamp;

  Message({required this.content, required this.isEncrypted, required this.timestamp});
}

class MessageListScreen extends StatefulWidget {
  final List<Message> messages;

  MessageListScreen({Key? key, required this.messages}) : super(key: key);

  @override
  _MessageListScreenState createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  late List<Message> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(widget.messages);
  }

  void _deleteAllMessages() {
    setState(() {
      _messages.clear();
    });
  }

  void _deleteMessage(int index) {
    setState(() {
      _messages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message History'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete All Messages'),
                    content: Text('Are you sure you want to delete all messages?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Delete'),
                        onPressed: () {
                          _deleteAllMessages();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: _messages.isEmpty
          ? Center(
              child: Text(
                'No messages yet',
                style: GoogleFonts.roboto(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Dismissible(
                  key: Key(message.timestamp.toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteMessage(index);
                  },
                  child: ListTile(
                    title: Text(
                      message.content,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      '${message.isEncrypted ? "Encrypted" : "Decrypted"} • ${_formatDate(message.timestamp)}',
                      style: GoogleFonts.roboto(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
