import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:securechat/utils/rc5_encryption.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../services/sms_service.dart';

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
  bool _isSending = false;
  final SmsService _smsService = SmsService();

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
    await Permission.sms.request();
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
      _outputMessage = 'Output: $encryptedMessage';
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
      _outputMessage = 'Output: $decryptedMessage';
    });

    _animateOutput();
  }

  void _sendSMS() async {
    String encryptedMessage = _outputMessage.startsWith('Output: ')
        ? _outputMessage.substring(8)
        : _outputMessage;
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
      Map<String, dynamic> result = await _smsService.sendSMS(phoneNumber, encryptedMessage);
      if (result['success']) {
        _showSnackBar(result['message']);
      } else {
        _showSnackBar('Failed to send SMS: ${result['error']}');
      }
    } catch (error) {
      _showSnackBar('Failed to send SMS: $error');
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
              phoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
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
    if (number.length != 13) return false;
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
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _animateOutput() {
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SecureChat', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/images/lock_icon.svg',
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(_messageController, 'Message', Icons.message),
              SizedBox(height: 16),
              _buildInputField(_keyController, 'Key', Icons.vpn_key),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(_phoneController, 'Recipient Phone Number', Icons.phone, keyboardType: TextInputType.phone),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.contacts, color: Colors.teal),
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
                  return Opacity(
                    opacity: _animation.value,
                    child: child,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _outputMessage,
                    style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.teal),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.teal, width: 2),
        ),
      ),
      keyboardType: keyboardType,
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback? onPressed, {bool fullWidth = false}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: _isSending && text == 'Send SMS'
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        minimumSize: fullWidth ? Size(double.infinity, 48) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}