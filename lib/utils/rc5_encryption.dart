import 'dart:typed_data';
import 'dart:convert';

class RC5Encryption {
  static const int w = 32; // word size in bits
  static const int r = 12; // number of rounds
  static const int t = 26; // size of table S = 2(r+1) words

  static List<int> _expandKey(String key) {
    List<int> L = [];
    List<int> S = List<int>.filled(t, 0);
    
    List<int> K = utf8.encode(key).toList();

    while (K.length % 4 != 0) {
      K.add(0);
    }

    for (int i = 0; i < K.length; i += 4) {
      L.add(((K[i] & 0xFF) << 24) |
            ((K[i + 1] & 0xFF) << 16) |
            ((K[i + 2] & 0xFF) << 8) |
            (K[i + 3] & 0xFF));
    }

    S[0] = 0xB7E15163;
    for (int i = 1; i < t; i++) {
      S[i] = (S[i - 1] + 0x9E3779B9) & 0xFFFFFFFF;
    }

    int i = 0, j = 0;
    int A = 0, B = 0;
    int c = L.length;
    for (int k = 0; k < 3 * t; k++) {
      A = S[i] = _rotateLeft((S[i] + A + B) & 0xFFFFFFFF, 3);
      B = L[j] = _rotateLeft((L[j] + A + B) & 0xFFFFFFFF, (A + B) & 0x1F);
      i = (i + 1) % t;
      j = (j + 1) % c;
    }

    return S;
  }

  static int _rotateLeft(int x, int y) {
    return ((x << y) | (x >> (32 - y))) & 0xFFFFFFFF;
  }

  static int _rotateRight(int x, int y) {
    return ((x >> y) | (x << (32 - y))) & 0xFFFFFFFF;
  }

  static String encrypt(String plaintext, String key) {
    try {
      List<int> S = _expandKey(key);
      List<int> bytes = utf8.encode(plaintext).toList();
      
      while (bytes.length % 8 != 0) {
        bytes.add(0);
      }

      List<int> encrypted = [];
      for (int i = 0; i < bytes.length; i += 8) {
        int A = ((bytes[i] & 0xFF) << 24) |
                ((bytes[i + 1] & 0xFF) << 16) |
                ((bytes[i + 2] & 0xFF) << 8) |
                (bytes[i + 3] & 0xFF);
        int B = ((bytes[i + 4] & 0xFF) << 24) |
                ((bytes[i + 5] & 0xFF) << 16) |
                ((bytes[i + 6] & 0xFF) << 8) |
                (bytes[i + 7] & 0xFF);

        A = (A + S[0]) & 0xFFFFFFFF;
        B = (B + S[1]) & 0xFFFFFFFF;

        for (int j = 1; j <= r; j++) {
          A = (_rotateLeft(A ^ B, B & 0x1F) + S[2 * j]) & 0xFFFFFFFF;
          B = (_rotateLeft(B ^ A, A & 0x1F) + S[2 * j + 1]) & 0xFFFFFFFF;
        }

        encrypted.addAll([
          (A >> 24) & 0xFF, (A >> 16) & 0xFF, (A >> 8) & 0xFF, A & 0xFF,
          (B >> 24) & 0xFF, (B >> 16) & 0xFF, (B >> 8) & 0xFF, B & 0xFF
        ]);
      }

      return base64.encode(encrypted);
    } catch (e) {
      print('Encryption error: $e');
      return 'Error: Unable to encrypt message';
    }
  }

  static String decrypt(String ciphertext, String key) {
    try {
      if (ciphertext.startsWith('Error:')) {
        throw FormatException('Invalid ciphertext');
      }
      
      List<int> S = _expandKey(key);
      List<int> bytes = base64.decode(ciphertext);

      if (bytes.length % 8 != 0) {
        throw FormatException('Ciphertext length must be a multiple of 8 bytes');
      }

      List<int> decrypted = [];
      for (int i = 0; i < bytes.length; i += 8) {
        int A = ((bytes[i] & 0xFF) << 24) |
                ((bytes[i + 1] & 0xFF) << 16) |
                ((bytes[i + 2] & 0xFF) << 8) |
                (bytes[i + 3] & 0xFF);
        int B = ((bytes[i + 4] & 0xFF) << 24) |
                ((bytes[i + 5] & 0xFF) << 16) |
                ((bytes[i + 6] & 0xFF) << 8) |
                (bytes[i + 7] & 0xFF);

        for (int j = r; j >= 1; j--) {
          B = _rotateRight((B - S[2 * j + 1]) & 0xFFFFFFFF, A & 0x1F) ^ A;
          A = _rotateRight((A - S[2 * j]) & 0xFFFFFFFF, B & 0x1F) ^ B;
        }

        B = (B - S[1]) & 0xFFFFFFFF;
        A = (A - S[0]) & 0xFFFFFFFF;

        decrypted.addAll([
          (A >> 24) & 0xFF, (A >> 16) & 0xFF, (A >> 8) & 0xFF, A & 0xFF,
          (B >> 24) & 0xFF, (B >> 16) & 0xFF, (B >> 8) & 0xFF, B & 0xFF
        ]);
      }

      while (decrypted.isNotEmpty && decrypted.last == 0) {
        decrypted.removeLast();
      }

      return utf8.decode(decrypted);
    } catch (e) {
      print('Decryption error: $e');
      return 'Error: Unable to decrypt message';
    }
  }
}