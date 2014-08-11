library ormicida.bytes.base64;

import 'dart:convert';
import 'dart:typed_data';
import 'package:ormicida/bytes/buffer.dart';
import 'package:ormicida/bytes/char.dart';

/// [Base64] provides methods to handle Base64 encoded data.
class Base64 {
  
  /// Encode bytes to Base64.
  static List<int> encode(List<int> bytes) {
    globalBuffer.clear();
    globalBuffer.addBase64(bytes);
    return globalBuffer.bytes;
  }
  
  /// Encode bytes to Base64 String.
  static String encodeToString(List<int> bytes) {
    return UTF8.decode(encode(bytes));
  }
  
  /// Decode a Base64 string to bytes.
  static List<int> decodeString(String base64) {
    final length = base64.length;
    if (length == 0) return new List(0);
    
    if (length % 4 != 0) {
      throw new FormatException('Size of Base 64 length must be a multiple of 4.');
    }
    
    int padLength = 0;
    if (base64.codeUnitAt(length - 1) == Char.EQUAL) {
      if (base64.codeUnitAt(length - 2) == Char.EQUAL) {
        padLength = 2;
      } else {
        padLength = 1;
      }
    }
    int outputLength = ((length * 6) >> 3) - padLength;
    List<int> result = new Uint8List(outputLength);
    
    final normalLength = padLength == 0 ? outputLength : outputLength - 3;
    int baseIndex = 0;
    int resultIndex = 0;
    
    int readBase64Code() {
      final code = base64.codeUnitAt(baseIndex);
      final result = _base64Table[code];
      if (result < 0)
        throw new FormatException('Invalid character: $code');
      baseIndex ++;
      return result;
    }
    
    while (resultIndex < normalLength) {
      int value = (readBase64Code() << 18)
                | (readBase64Code() << 12)
                | (readBase64Code() << 6)
                | readBase64Code();
      
      result[resultIndex++] = value >> 16;
      result[resultIndex++] = (value >> 8) & 0xFF;
      result[resultIndex++] = value & 0xFF;
    }
    
    if (padLength == 1) {
      int value = (readBase64Code() << 10)
                | (readBase64Code() << 4)
                | (readBase64Code() >> 2);
      result[resultIndex++] = value >> 8;
      result[resultIndex++] = (value) & 0xFF;
    } else if (padLength == 2) {
      result[resultIndex++] = (readBase64Code() << 2) | (readBase64Code() >> 4);
    }
    
    return result;
  }
  
  static const List<int> _base64Table =
      const [ -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -2, -2, -1, -2, -2,
              -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
              -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, 62, -2, 63,
              52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2,  0, -2, -2,
              -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
              15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, 63,
              -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
              41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
              -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
              -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
              -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
              -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
              -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
              -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
              -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
              -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2 ];
}