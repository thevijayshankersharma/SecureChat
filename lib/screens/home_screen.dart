import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securechat/utils/rc5_encryption.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'message_list_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController(text: '+91');
  String _outputMessage = '';
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<Message> _messages = [];
  bool _isSending = false;

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
    _checkInitialPermissions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    _keyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialPermissions() async {
    await Permission.contacts.request();
  }

  void _encryptMessage() {
    String message = _messageController.text;
    String key = _keyController.text;

    if (message.isEmpty || key.isEmpty) {
      _showSnackBar('Please enter both message and key!');
      return;
    }

    String encryptedMessage = RC5Encryption.encrypt(message, key);
    print('Debug - Encrypted message: $encryptedMessage');
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

    print('Debug - Attempting to decrypt: $encryptedMessage');
    String decryptedMessage = RC5Encryption.decrypt(encryptedMessage, key);
    print('Debug - Decryption result: $decryptedMessage');
    setState(() {
      _outputMessage = decryptedMessage;
      _messages.add(Message(content: decryptedMessage, isEncrypted: false, timestamp: DateTime.now()));
    });
    _animateOutput();
  }

  void _sendSMS() async {
    String encryptedMessage = _outputMessage;
    String phoneNumber = _phoneController.text;

    if (encryptedMessage.isEmpty) {
      _showSnackBar('Please encrypt a message first!');
      return;
    }

    if (!_isValidPhoneNumber(phoneNumber)) {
      _showSnackBar('Please enter a valid 10-digit phone number after +91');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final Uri smsLaunchUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: <String, String>{
          'body': encryptedMessage,
        },
      );

      if (await canLaunchUrl(smsLaunchUri)) {
        await launchUrl(smsLaunchUri, mode: LaunchMode.externalApplication);
        _showSnackBar('SMS app opened with the encrypted message');
        _messages.add(Message(content: encryptedMessage, isEncrypted: true, timestamp: DateTime.now()));
      } else {
        _showSnackBar('Could not open SMS app');
      }
    } catch (error) {
      _showSnackBar('Failed to open SMS app: $error');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _selectContact() async {
    try {
      if (await Permission.contacts.request().isGranted) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        if (contacts.isNotEmpty) {
          // Show a dialog to select contact
          final contact = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Select Contact'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      title: Text(contact.displayName),
                      onTap: () => Navigator.of(context).pop(contact),
                    );
                  },
                ),
              ),
            ),
          );

          if (contact != null) {
            final phones = contact.phones;
            if (phones.isNotEmpty) {
              String phoneNumber = phones.first.number;
              // Remove any non-digit characters
              phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
              // Ensure the number starts with +91 and has 10 digits after
              if (phoneNumber.length > 10) {
                phoneNumber = '+91' + phoneNumber.substring(phoneNumber.length - 10);
              } else {
                phoneNumber = '+91' + phoneNumber;
              }
              setState(() {
                _phoneController.text = phoneNumber;
              });
            }
          }
        } else {
          _showSnackBar('No contacts found');
        }
      } else {
        _showPermissionDialog('Contacts');
      }
    } catch (e) {
      _showSnackBar('Error selecting contact: $e');
    }
  }

  void _showPermissionDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permissionType Permission Required'),
          content: Text('$permissionType permission is required. Please enable it in app settings.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isValidPhoneNumber(String number) {
    if (number.length != 13) return false; // +91 + 10 digits
    if (!number.startsWith('+91')) return false;
    return RegExp(r'^\+91[0-9]{10}$').hasMatch(number);
  }

  void _clearFields() {
    _messageController.clear();
    _keyController.clear();
    _phoneController.text = '+91';
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
            'assets/images/lock_icon.svg',
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(_phoneController, 'Recipient Phone Number', Icons.phone, keyboardType: TextInputType.phone),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.contacts),
                      onPressed: _selectContact,
                      tooltip: 'Select Contact',
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton('Encrypt', Icons.lock, _encryptMessage),
                    _buildActionButton('Decrypt', Icons.lock_open, _decryptMessage),
                  ],
                ),
                SizedBox(height: 24),
                _buildActionButton('Send SMS', Icons.send, _isSending ? null : _sendSMS, fullWidth: true),
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
      inputFormatters: label == 'Recipient Phone Number'
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'^\+91[0-9]{0,10}$')),
              LengthLimitingTextInputFormatter(13),
            ]
          : null,
      onChanged: label == 'Recipient Phone Number'
          ? (value) {
              if (value.length < 3) {
                controller.text = '+91';
                controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
              }
            }
          : null,
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback? onPressed, {bool fullWidth = false}) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: _isSending && label == 'Send SMS'
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Icon(icon),
        label: Text(label),
      ),
    );
  }
}