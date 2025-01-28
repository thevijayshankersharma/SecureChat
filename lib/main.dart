import 'package:flutter/foundation.dart'; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'utils/rc5_encryption.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await requestPermissions();
  testEncryption();
  runApp(SecureChatApp());
}

Future<void> requestPermissions() async {
  // Check if the platform is mobile (Android or iOS)
  if (!kIsWeb) {
    // Request SMS permission for mobile platforms (Android/iOS)
    if (await Permission.sms.isGranted) {
      print("SMS permission already granted");
    } else {
      await Permission.sms.request(); // Request permission
    }
  } else {
    print("SMS permission is not requested on web.");
  }
}


void testEncryption() {
  String originalMessage = "Hello, World!";
  String key = "MySecretKey";

  print("Original message: $originalMessage");

  String encrypted = RC5Encryption.encrypt(originalMessage, key);
  print("Encrypted: $encrypted");

  if (encrypted.startsWith('Error:')) {
    print("Encryption failed!");
    return;
  }

  String decrypted = RC5Encryption.decrypt(encrypted, key);
  print("Decrypted: $decrypted");

  if (originalMessage == decrypted) {
    print("Encryption test passed!");
  } else {
    print("Encryption test failed!");
  }
}

class SecureChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureChat',
      theme: ThemeData(
        primaryColor: Color(0xFF1E88E5),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF1E88E5),
          secondary: Color(0xFF00BCD4),
          surface: Colors.white,
          background: Color(0xFFF5F5F5),
          error: Color(0xFFD32F2F),
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textTheme: TextTheme(
          titleLarge: GoogleFonts.montserrat(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          labelStyle: GoogleFonts.roboto(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color(0xFF1E88E5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
