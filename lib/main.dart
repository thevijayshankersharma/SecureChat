import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'utils/rc5_encryption.dart';

void main() {
  testEncryption();
  runApp(SecureChatApp());
}

void testEncryption() {
  String originalMessage = "Hello, World!";
  String key = "MySecretKey";

  print("Original message: $originalMessage");

  String encrypted = RC5Encryption.encrypt(originalMessage, key);
  print("Encrypted: $encrypted");

  String decrypted = RC5Encryption.decrypt(encrypted, key);
  print("Decrypted: $decrypted");

  assert(originalMessage == decrypted, "Decryption failed!");
  print("Encryption test passed!");
}

class SecureChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureChat',
      theme: ThemeData(
        primaryColor: Color(0xFF6200EE),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF6200EE),
          secondary: Color(0xFF03DAC6),
          surface: Colors.white,
          background: Colors.grey[50]!,
          error: Color(0xFFB00020),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF6200EE),
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: GoogleFonts.roboto(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          bodyLarge: GoogleFonts.roboto(
            color: Colors.black54,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF6200EE), width: 2),
          ),
          labelStyle: GoogleFonts.roboto(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF6200EE),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

