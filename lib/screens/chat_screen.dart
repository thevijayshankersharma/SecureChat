import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message.dart';
import '../utils/rc5_encryption.dart';

class ChatScreen extends StatefulWidget {
  final String phoneNumber;

  const ChatScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  bool _isEncrypted = true;
  final String _encryptionKey = "defaultKey"; // In a real app, this should be securely stored

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add(Message(
          content: _isEncrypted
              ? RC5Encryption.encrypt(_messageController.text, _encryptionKey)
              : _messageController.text,
          isEncrypted: _isEncrypted,
          timestamp: DateTime.now(),
          deliveryStatus: MessageDeliveryStatus.sent,
        ));
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.phoneNumber),
        backgroundColor: Colors.teal,
        actions: [
          Switch(
            value: _isEncrypted,
            onChanged: (value) {
              setState(() {
                _isEncrypted = value;
              });
            },
            activeColor: Colors.white,
            activeTrackColor: Colors.tealAccent,
          ),
          IconButton(
            icon: Icon(_isEncrypted ? Icons.lock : Icons.lock_open),
            onPressed: () {
              setState(() {
                _isEncrypted = !_isEncrypted;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.tealAccent.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.isEncrypted
                  ? RC5Encryption.decrypt(message.content, _encryptionKey)
                  : message.content,
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            SizedBox(height: 4),
            Text(
              '${_formatTime(message.timestamp)} • ${message.isEncrypted ? "Encrypted" : "Decrypted"}',
              style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

