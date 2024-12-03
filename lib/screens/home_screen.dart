import 'package:flutter/material.dart';
import 'package:securechat/utils/rc5_encryption.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'message_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _outputMessage = '';
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _encryptMessage() {
    String message = _messageController.text;
    String key = _keyController.text;

    if (message.isEmpty || key.isEmpty) {
      _showSnackBar('Please enter both message and key!');
      return;
    }

    String encryptedMessage = RC5Encryption.encrypt(message, key);
    setState(() {
      _outputMessage = encryptedMessage;
      _messages.add(Message(content: encryptedMessage, isEncrypted: true, timestamp: DateTime.now()));
    });
    _animateOutput();
  }

  void _decryptMessage() {
    String encryptedMessage = _messageController.text;
    String key = _keyController.text;

    if (encryptedMessage.isEmpty || key.isEmpty) {
      _showSnackBar('Please enter both encrypted message and key!');
      return;
    }

    String decryptedMessage = RC5Encryption.decrypt(encryptedMessage, key);
    setState(() {
      _outputMessage = decryptedMessage;
      _messages.add(Message(content: decryptedMessage, isEncrypted: false, timestamp: DateTime.now()));
    });
    _animateOutput();
  }

  void _sendSMS() {
    String encryptedMessage = _outputMessage;
    String phoneNumber = _phoneController.text;

    if (encryptedMessage.isEmpty || phoneNumber.isEmpty) {
      _showSnackBar('Please provide a phone number and encrypt a message!');
      return;
    }

    // Here you would integrate SMS sending logic
    _showSnackBar('SMS sent to $phoneNumber');
  }

  void _clearFields() {
    _messageController.clear();
    _keyController.clear();
    _phoneController.clear();
    setState(() {
      _outputMessage = '';
    });
    _animationController.reverse();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _animateOutput() {
    _animationController.forward(from: 0.0);
  }

  void _navigateToMessageList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageListScreen(messages: _messages),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SecureChat'),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/lock_icon.svg',
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: _navigateToMessageList,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputField(_messageController, 'Message', Icons.message),
                SizedBox(height: 16),
                _buildInputField(_keyController, 'Encryption Key', Icons.vpn_key),
                SizedBox(height: 16),
                _buildInputField(_phoneController, 'Recipient Phone Number', Icons.phone, keyboardType: TextInputType.phone),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton('Encrypt', Icons.lock, _encryptMessage),
                    _buildActionButton('Decrypt', Icons.lock_open, _decryptMessage),
                  ],
                ),
                SizedBox(height: 24),
                _buildActionButton('Send SMS', Icons.send, _sendSMS, fullWidth: true),
                SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Output',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _outputMessage.isEmpty ? 'No output yet' : _outputMessage,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _clearFields,
                  icon: Icon(Icons.clear),
                  label: Text('Clear All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed, {bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

