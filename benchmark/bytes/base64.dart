library bench.serialization;

import 'dart:convert';
import 'dart:typed_data';
import 'package:ormicida/benchmark.dart';
import 'package:ormicida/bytes/base64.dart';

void main() {
  final little = _createBytes(10);
  final medium = _createBytes(100);
  final big = _createBytes(2048);
  
  final little64 = Base64.encodeToString(little);
  final medium64 = Base64.encodeToString(medium);
  final big64 = Base64.encodeToString(big);
  
  _benchEncode('little ', little);
  _benchEncode('medium ', medium);
  _benchEncode('big    ', big);
  
  _benchDecode('little ', little64);
  _benchDecode('medium ', medium64);
  _benchDecode('big    ', big64);
}

void _benchEncode(String name, Uint8List bytes) {
  new BenchmarkSet('Encode $name')
    ..add(new _OrmBase64EncodeBench(bytes))
    ..add(new _OtherBase64EncodeBench(bytes))
    ..report();
}

class _OrmBase64EncodeBench extends Benchmark {
  final Uint8List bytes;
  List<int>       result;
  _OrmBase64EncodeBench(this.bytes): super('Orm');
  void run() {
    result = Base64.encode(bytes);
  }
}

class _OtherBase64EncodeBench extends Benchmark {
  final Uint8List bytes;
  List<int>       result;
  _OtherBase64EncodeBench(this.bytes): super('Other');
  void run() {
    result = UTF8.encode(bytesToBase64String(bytes));
  }
}

void _benchDecode(String name, String base64) {
  new BenchmarkSet('Decode $name')
    ..add(new _OrmBase64DecodeBench(base64))
    ..add(new _OtherBase64DecodeBench(base64))
    ..report();
}

class _OrmBase64DecodeBench extends Benchmark {
  final String  base64;
  List<int>     result;
  _OrmBase64DecodeBench(this.base64): super('Orm');
  void run() {
    result = Base64.decodeString(base64);
  }
}

class _OtherBase64DecodeBench extends Benchmark {
  final String  base64;
  List<int>     result;
  _OtherBase64DecodeBench(this.base64): super('Other');
  void run() {
    result = base64StringToBytes(base64);
  }
}

Uint8List _createBytes(int length) {
  final Uint8List result = new Uint8List(length);
  
  int value = 0;
  for(int index = 0; index < length; index++) {
    result[index] = value;
    
    value ++;
    if (index >= 0xFF) value = 0;
  }
  return result;
}

const int _EQUAL = 61;

const List<int> _base64Table =
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

const String _encodeTable =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

String bytesToBase64String(List<int> bytes) {
  int len = bytes.length;
  if (len == 0) return "";
  final String lookup = _encodeTable;
  // Size of 24 bit chunks.
  final int remainderLength = len.remainder(3);
  final int chunkLength = len - remainderLength;
  // Size of base output.
  int outputLen = ((len ~/ 3) * 4) + ((remainderLength > 0) ? 4 : 0);
  List<int> out = new List<int>(outputLen);

  // Encode 24 bit chunks.
  int j = 0, i = 0, c = 0;
  while (i < chunkLength) {
    int x = ((bytes[i++] << 16) & 0xFFFFFF) |
            ((bytes[i++] << 8) & 0xFFFFFF) |
              bytes[i++];
    out[j++] = lookup.codeUnitAt(x >> 18);
    out[j++] = lookup.codeUnitAt((x >> 12) & 0x3F);
    out[j++] = lookup.codeUnitAt((x >> 6)  & 0x3F);
    out[j++] = lookup.codeUnitAt(x & 0x3f);
  }
  
  if (remainderLength == 1) {
    int x = bytes[i];
    out[j++] = lookup.codeUnitAt(x >> 2);
    out[j++] = lookup.codeUnitAt((x << 4) & 0x3F);
    out[j++] = _EQUAL;
    out[j++] = _EQUAL;
  } else if (remainderLength == 2) {
    int x = bytes[i];
    int y = bytes[i + 1];
    out[j++] = lookup.codeUnitAt(x >> 2);
    out[j++] = lookup.codeUnitAt(((x << 4) | (y >> 4)) & 0x3F);
    out[j++] = lookup.codeUnitAt((y << 2) & 0x3F);
    out[j++] = _EQUAL;
  }

  return new String.fromCharCodes(out);
}

List<int> base64StringToBytes(String input) {
  int len = input.length;
  if (len == 0) {
    return new List<int>(0);
  }

  // Count '\r', '\n' and illegal characters, For illegal characters,
  // throw an exception.
  int extrasLen = 0;
  for (int i = 0; i < len; i++) {
    int c = _base64Table[input.codeUnitAt(i)];
    if (c < 0) {
      extrasLen++;
      if(c == -2) {
        throw new FormatException('Invalid character: ${input[i]}');
      }
    }
  }

  if ((len - extrasLen) % 4 != 0) {
    throw new FormatException('''Size of Base 64 characters in Input
        must be a multiple of 4. Input: $input''');
  }

  // Count pad characters.
  int padLength = 0;
  for (int i = len - 1; i >= 0; i--) {
    int currentCodeUnit = input.codeUnitAt(i);
    if (_base64Table[currentCodeUnit] > 0) break;
    if (currentCodeUnit == _EQUAL) padLength++;
  }
  int outputLen = (((len - extrasLen) * 6) >> 3) - padLength;
  List<int> out = new List<int>(outputLen);

  for (int i = 0, o = 0; o < outputLen;) {
    // Accumulate 4 valid 6 bit Base 64 characters into an int.
    int x = 0;
    for (int j = 4; j > 0;) {
      int c = _base64Table[input.codeUnitAt(i++)];
      if (c >= 0) {
        x = ((x << 6) & 0xFFFFFF) | c;
        j--;
      }
    }
    out[o++] = x >> 16;
    if (o < outputLen) {
      out[o++] = (x >> 8) & 0xFF;
      if (o < outputLen) out[o++] = x & 0xFF;
    }
  }
  return out;
}
