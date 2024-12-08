import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message.dart';

// Define the Message model with status and encryption
class Message {
  final String content;
  final bool isEncrypted;
  final DateTime timestamp;
  final MessageDeliveryStatus deliveryStatus;

  Message({
    required this.content,
    required this.isEncrypted,
    required this.timestamp,
    this.deliveryStatus = MessageDeliveryStatus.sent,
  });
}

enum MessageDeliveryStatus {
  sent,
  delivered,
  failed,
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MessageListScreen(
        messages: [
          Message(
            content: 'Hello, how are you?',
            isEncrypted: true,
            timestamp: DateTime.now().subtract(Duration(hours: 1)),
            deliveryStatus: MessageDeliveryStatus.sent,
          ),
          Message(
            content: 'I am fine, thank you!',
            isEncrypted: false,
            timestamp: DateTime.now().subtract(Duration(hours: 2)),
            deliveryStatus: MessageDeliveryStatus.delivered,
          ),
          Message(
            content: 'Let\'s meet tomorrow.',
            isEncrypted: true,
            timestamp: DateTime.now().subtract(Duration(hours: 3)),
            deliveryStatus: MessageDeliveryStatus.failed,
          ),
        ],
      ),
    );
  }
}

class MessageListScreen extends StatefulWidget {
  final List<Message> messages;

  const MessageListScreen({Key? key, required this.messages}) : super(key: key);

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

  String _getDeliveryStatusText(MessageDeliveryStatus status) {
    switch (status) {
      case MessageDeliveryStatus.sent:
        return 'Sent';
      case MessageDeliveryStatus.delivered:
        return 'Delivered';
      case MessageDeliveryStatus.failed:
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  IconData _getDeliveryStatusIcon(MessageDeliveryStatus status) {
    switch (status) {
      case MessageDeliveryStatus.sent:
        return Icons.check;
      case MessageDeliveryStatus.delivered:
        return Icons.done_all;
      case MessageDeliveryStatus.failed:
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
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
                      '${message.isEncrypted ? "Encrypted" : "Decrypted"} • ${_formatDate(message.timestamp)} • ${_getDeliveryStatusText(message.deliveryStatus)}',
                      style: GoogleFonts.roboto(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    leading: Icon(
                      message.isEncrypted ? Icons.lock : Icons.lock_open,
                      color: message.isEncrypted ? Colors.green : Colors.blue,
                    ),
                    trailing: Icon(_getDeliveryStatusIcon(message.deliveryStatus)),
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
