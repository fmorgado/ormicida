library ormicida.bytes.hex;

import 'dart:convert';
import 'dart:typed_data';
import 'package:ormicida/bytes/buffer.dart';
import 'package:ormicida/bytes/char.dart';

/// A Utility class to handle base16 (Hexadecimal) data.
class Base16 {
  
  /// Encode the given [bytes] to Base16 bytes.
  static List<int> encode(List<int> bytes) {
    globalBuffer.clear();
    globalBuffer.addBase16(bytes);
    return globalBuffer.bytes;
  }
  
  /// Encode the given [bytes] to a Base16 string.
  static String encodeToString(List<int> bytes) {
    return UTF8.decode(encode(bytes));
  }
  
  /// Decode the given Base16 string to bytes.
  static List<int> decodeString(String hexString) {
    final length = hexString.length;
    int bytesLength = length ~/ 2;
    bool isOdd = false;
    
    if (hexString.length.remainder(2) > 0) {
      isOdd = true;
      bytesLength ++;
    }
    
    final result = new Uint8List(bytesLength);
    int position = 0;
    int index = 0;
    
    if (isOdd) {
      result[position++] = Char.fromHex(hexString.codeUnitAt(index++));
    }
    
    for (; position < bytesLength; position ++) {
      result[position] = 
          (Char.fromHex(hexString.codeUnitAt(index++)) << 4)
          | Char.fromHex(hexString.codeUnitAt(index++));
    }
    
    return result;
  }
}