library ormicida.bytes.buffer;

import 'dart:typed_data';
import 'package:ormicida/bytes/char.dart';

/// A global instance of [Buffer].
final Buffer globalBuffer = new Buffer();

// An appendable buffer.
class Buffer {
  Uint8List   _buffer;
  ByteData    _data;
  int         _capacity = 0;
  int         _position = 0;
  int         _length = 0;
  Endianness  _endianness = Endianness.LITTLE_ENDIAN;
  
  /// Creates an empty buffer, optionally specifying its initial limit.
  Buffer([int initialSize = 1024]) {
    _setBuffer(new Uint8List(initialSize));
  }
  
  /// Creates a buffer filled with the given bytes.
  Buffer.fromBytes(List<int> bytes) {
    _setBuffer(bytes is Uint8List ? bytes : new Uint8List.fromList(bytes));
    _length = bytes.length;
  }
  
  /// The length of the buffer.
  int       get length    => _length;
  /// The total capacity of the buffer.
  int       get capacity  => _capacity;
  /// Get the buffer content as bytes.
  List<int> get bytes     => _buffer.sublist(0, _length);
  /// Get the internal buffer.
  Uint8List get buffer => _buffer;
  
  /// Set the buffer little endian.
  void setLittleEndian() {
    _endianness = Endianness.LITTLE_ENDIAN;
  }
  
  /// Set the buffer big endian.
  void setBigEndian() {
    _endianness = Endianness.BIG_ENDIAN;
  }
  
  /// Get or set the cursor position.
  /// The position is only updated by get* methods.
  int get position => _position;
  set position(int value) {
    if (value < 0 || value > _length)
      throw new RangeError.range(value, 0, _length - 1);
    _position = value;
  }
  
  /// Clear the buffer.
  void clear() {
    _position = 0;
    _length = 0;
  }
  
  void _setBuffer(Uint8List value) {
    _buffer = value;
    _capacity = value.lengthInBytes;
    _data = new ByteData.view(value.buffer, 0, _capacity);
  }
  
  /// Ensure the the buffer's capacity.
  void _ensureSpace(int length) {
    final newCapacity = _length + length;
    if (newCapacity > _capacity) {
      final newSize = _pow2roundup(newCapacity);
      final newBuffer = new Uint8List(newSize);
      newBuffer.setRange(0, _length, _buffer);
      _setBuffer(newBuffer);
    }
  }
  
  int _pow2roundup(int x) {
    --x;
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;
    return (x + 1) * 2;
  }
  
  void _checkBounds(int index, int length) {
    if (index < 0 || index + length > _length)
      throw new RangeError('Index out of bounds');
  }
  
  /// Append arbitrary space.
  /// [length] specifies the length of the reserved space.
  /// Returns the position of the reserved bytes.
  int addSpace(int length) {
    _ensureSpace(length);
    final result = _length;
    _length += length;
    return result;
  }
  
  /// Append a byte to the buffer.
  void addByte(int byte) {
    _ensureSpace(1);
    _buffer[_length++] = byte;
  }
  
  /// Append bytes to the buffer.
  void addBytes(List<int> bytes) {
    final bytesLength = bytes.length;
    _ensureSpace(bytesLength);
    if (bytes is Uint8List && bytesLength > 64) {
      _buffer.setRange(_length, _length + bytesLength, bytes);
      _length += bytesLength;
    } else {
      for (int i = 0; i < bytesLength; i++) {
        _buffer[_length++] = bytes[i];
      }
    }
  }
  
  /// Appends a Unicode character to the buffer.
  void _addCharCode(final int code) {
    if (code < 0) {
      throw new ArgumentError('Invalid character code:  $code');
    } else if (code <= _UTF8_ONE_BYTE_LIMIT) {
      _buffer[_length++] = code;
    } else if (_isLeadSurrogate(code)) {
      throw new UnimplementedError('Surrogates are not supported:  $code');
    } else if (code <= _UTF8_TWO_BYTE_LIMIT) {
      _buffer[_length++] = 0xC0 | (code >> 6);
      _buffer[_length++] = 0x80 | (code & 0x3f);
    } else if (code <= _UTF8_THREE_BYTE_LIMIT) {
      _buffer[_length++] = 0xE0 | (code >> 12);
      _buffer[_length++] = 0x80 | ((code >> 6) & 0x3f);
      _buffer[_length++] = 0x80 | (code & 0x3f);
    } else {
      throw new ArgumentError('Invalid character code:  $code');
    }
  }
  
  /// Append a Unicode character.
  void addCharCode(final int code) {
    _ensureSpace(3);
    _addCharCode(code);
  }
  
  /// Append an ASCII string.
  void addAscii(final String value) {
    final length = value.length;
    _ensureSpace(length);
    for (var index = 0; index < length; index++)
      _buffer[_length++] = value.codeUnitAt(index);
  }
  
  /// Append a string.
  void addString(final String value) {
    final length = value.length;
    if (length <= _STRING_CAPACITY_LIMIT) {
      _ensureSpace(length * 3);
      for (var index = 0; index < length; index++)
        _addCharCode(value.codeUnitAt(index));
    } else {
      for (var index = 0; index < length; index++)
        addCharCode(value.codeUnitAt(index));
    }
  }
  
  static const List<int> _base64Table = const [
    65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82,
    83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104,
    105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118,
    119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47
  ];
  
  /// Append bytes encoded to Base64.
  void addBase64(List<int> bytes) {
    int bytesLength = bytes.length;
    if (bytesLength == 0) return;
    
    // Size of 24 bit chunks.
    final int remainderLength = bytesLength.remainder(3);
    final int chunkLength = bytesLength - remainderLength;
    
    // Size of base output.
    _ensureSpace(((bytesLength ~/ 3) * 4) + ((remainderLength > 0) ? 4 : 0));
    final buffer = _buffer;
    int length = _length;
    
    // Encode 24 bit chunks.
    int i = 0;
    while (i < chunkLength) {
      int x = ((bytes[i++] << 16) & 0xFFFFFF) |
              ((bytes[i++] << 8) & 0xFFFFFF) |
                bytes[i++];
      buffer[length++] = _base64Table[x >> 18];
      buffer[length++] = _base64Table[(x >> 12) & 0x3F];
      buffer[length++] = _base64Table[(x >> 6)  & 0x3F];
      buffer[length++] = _base64Table[x & 0x3f];
    }
    
    // If input length if not a multiple of 3, encode remaining bytes and add padding.
    if (remainderLength == 1) {
      int x = bytes[i];
      buffer[length++] = _base64Table[x >> 2];
      buffer[length++] = _base64Table[(x << 4) & 0x3F];
      buffer[length++] = Char.EQUAL;
      buffer[length++] = Char.EQUAL;
    } else if (remainderLength == 2) {
      int x = bytes[i];
      int y = bytes[i + 1];
      buffer[length++] = _base64Table[x >> 2];
      buffer[length++] = _base64Table[((x << 4) | (y >> 4)) & 0x3F];
      buffer[length++] = _base64Table[(y << 2) & 0x3F];
      buffer[length++] = Char.EQUAL;
    }
    
    _length = length;
  }
  
  /// Append bytes encoded Base16 (Hexadecimal).
  void addBase16(List<int> bytes) {
    final bytesLength = bytes.length;
    _ensureSpace(bytesLength * 2);
    
    final buffer = _buffer;
    int length = _length;
    
    for (int index = 0; index < bytesLength; index ++) {
      final int byte = bytes[index];
      buffer[length++] = Char.toHex((byte >> 4) & 0xF);
      buffer[length++] = Char.toHex(byte & 0xF);
    }
    
    _length = length;
  }
  
  /// Add a 32-bits signed integer.
  void addInt32(int value) {
    _ensureSpace(4);
    _data.setInt32(_length, value, _endianness);
    _length += 4;
  }
  
  /// Add a 32-bits unsigned integer.
  void addUint32(int value) {
    _ensureSpace(4);
    _data.setUint32(_length, value, _endianness);
    _length += 4;
  }
  
  /// Add a 64-bits signed integer.
  void addInt64(int value) {
    _ensureSpace(8);
    _data.setInt64(_length, value, _endianness);
    _length += 8;
  }
  
  /// Add a 64-bits unsigned integer.
  void addUint64(int value) {
    _ensureSpace(8);
    _data.setUint64(_length, value, _endianness);
    _length += 8;
  }
  
  /// Add a 32-bits floating-point number.
  void addFloat32(double value) {
    _ensureSpace(4);
    _data.setFloat32(_length, value, _endianness);
    _length += 4;
  }
  
  /// Add a 64-bits floating-point number.
  void addFloat64(double value) {
    _ensureSpace(8);
    _data.setFloat64(_length, value, _endianness);
    _length += 8;
  }
  
  /// Get the number of available bytes.
  int get availableBytes => _length - _position;
  
  void _ensureAvailable(int length) {
    if (length > availableBytes)
      throw new FormatException('Unexpected end of data');
  }
  
  /// Get a byte.
  int getByte() {
    _ensureAvailable(1);
    return _buffer[_position++];
  }
  
  /// Get bytes of the given [length].
  List<int> getBytes(int length) {
    _ensureAvailable(length);
    final result = new Uint8List(length);
    result.setRange(0, length, _buffer.getRange(_position, _position + length));
    _position += length;
    return result;
  }
  
  /// Skip the specified amount of bytes.
  void skip(int length) {
    _ensureAvailable(length);
    _position += length;
  }
  
  /// Get a Unicode character.
  int getCharCode() {
    int value = getByte();
    
    if (value <= _UTF8_ONE_BYTE_LIMIT) {
      return value;
    } else {
      int expected = 0;
      int limit = 0;
      if ((value & 0xE0) == 0xC0) {
        value &= 0x1F;
        expected = 1;
        limit = _UTF8_ONE_BYTE_LIMIT;
      } else if ((value & 0xF0) == 0xE0) {
        value &= 0x0F;
        expected = 2;
        limit = _UTF8_TWO_BYTE_LIMIT;
        // 0xF5 to 0xFF never appear in valid UTF-8 sequences.
      } else if ((value) == 0xF0 && value < 0xF5) {
        value &= 0x07;
        expected = 3;
        limit = _UTF8_THREE_BYTE_LIMIT;
      } else {
        throw new FormatException('Invalid UTF-8 sequence');
      }
      
      do {
        final int byte = getByte();
        if ((byte & 0xC0) != 0x80)
          throw new FormatException('Invalid UTF-8 sequence');
        value = (value << 6) | (byte & 0x3f);
      } while(--expected > 0);
      
      if (value <= limit || value > _UTF8_FOUR_BYTE_LIMIT)
        throw new FormatException('Invalid UTF-8 sequence');
      
      return value;
    }
  }
  
  /// Get a 32-bits signed integer.
  int getInt32() {
    _ensureAvailable(4);
    final result = _data.getInt32(_position, _endianness);
    _position += 4;
    return result;
  }
  
  /// Get a 32-bits unsigned integer.
  int getUint32() {
    _ensureAvailable(4);
    final result = _data.getUint32(_position, _endianness);
    _position += 4;
    return result;
  }
  
  /// Get a 64-bits signed integer.
  int getInt64() {
    _ensureAvailable(8);
    final result = _data.getInt64(_position, _endianness);
    _position += 8;
    return result;
  }
  
  /// Get a 64-bits unsigned integer.
  int getUint64() {
    _ensureAvailable(8);
    final result = _data.getUint64(_position, _endianness);
    _position += 8;
    return result;
  }
  
  /// Get a 32-bits floating-point number.
  double getFloat32() {
    _ensureAvailable(4);
    final result = _data.getFloat32(_position, _endianness);
    _position += 4;
    return result;
  }
  
  /// Get a 64-bits floating-point number.
  double getFloat64() {
    _ensureAvailable(8);
    final result = _data.getFloat64(_position, _endianness);
    _position += 8;
    return result;
  }
  
  /// Read a byte from the specified [index].
  int readByte(int index) {
    _checkBounds(index, 1);
    return _buffer[index];
  }
  
  /// Read [length] bytes from the specified [index].
  List<int> readBytes(int length, int index) {
    _checkBounds(index, length);
    final result = new Uint8List(length);
    result.setRange(0, length, _buffer.getRange(index, index + length));
    return result;
  }
  
  /// Read a 32-bits signed integer from the specified [index].
  int readInt32(int index) {
    _checkBounds(index, 4);
    return _data.getInt32(_position, _endianness);
  }
  
  /// Read a 32-bits unsigned integer from the specified [index].
  int readUint32(int index) {
    _checkBounds(index, 4);
    return _data.getUint32(_position, _endianness);
  }
  
  /// Read a 64-bits signed integer from the specified [index].
  int readInt64(int index) {
    _checkBounds(index, 8);
    return _data.getInt64(_position, _endianness);
  }
  
  /// Read a 64-bits unsigned integer from the specified [index].
  int readUint64(int index) {
    _checkBounds(index, 8);
    return _data.getUint64(_position, _endianness);
  }
  
  /// Read a 32-bits floating-point number from the specified [index].
  double readFloat32(int index) {
    _checkBounds(index, 4);
    return _data.getFloat32(_position, _endianness);
  }
  
  /// Read a 64-bits floating-point number from the specified [index].
  double readFloat64(int index) {
    _checkBounds(index, 8);
    return _data.getFloat64(_position, _endianness);
  }
  
  /// Write a byte at the specified [index].
  void writeByte(int byte, int index) {
    _checkBounds(index, 1);
    _buffer[index] = byte;
  }
  
  /// Write bytes at the specified [index].
  void writeBytes(List<int> bytes, int index) {
    final bytesLength = bytes.length;
    _checkBounds(index, bytesLength);
    _buffer.setRange(index, index + bytesLength, bytes);
  }
  
  /// Write a 32-bits signed integer at the specified [index].
  void writeInt32(int value, int index) {
    _checkBounds(index, 4);
    _data.setInt32(index, value, _endianness);
  }

  /// Write a 32-bits unsigned integer at the specified [index].
  void writeUint32(int value, int index) {
    _checkBounds(index, 4);
    _data.setUint32(index, value, _endianness);
  }

  /// Write a 64-bits signed integer at the specified [index].
  void writeInt64(int value, int index) {
    _checkBounds(index, 8);
    _data.setInt64(index, value, _endianness);
  }

  /// Write a 64-bits unsigned integer at the specified [index].
  void writeUint64(int value, int index) {
    _checkBounds(index, 8);
    _data.setUint64(index, value, _endianness);
  }

  /// Write a 32-bits floating-point number at the specified [index].
  void writeFloat32(double value, int index) {
    _checkBounds(index, 4);
    _data.setFloat32(index, value, _endianness);
  }

  /// Write a 64-bits floating-point number at the specified [index].
  void writeFloat64(double value, int index) {
    _checkBounds(index, 4);
    _data.setFloat64(index, value, _endianness);
  }
  
  /// Get a packed unsigned integer.
  int getPackedUInt() {
    int intValue = 0;
    int shift = 0;
    
    while (true) {
      int intByte = getByte();
      
      intValue |= (intByte & _PACKED_MASK) << shift;
      if (intByte & _PACKED_BIT == 0) break;
      shift += _PACKED_SHIFT;
    }
    
    return intValue;
  }
  
  /// Append a packed unsigned integer.
  void addPackedUInt(int value) {
    do {
      var intByte = value & _PACKED_MASK;
      value >>= _PACKED_SHIFT;
      if (value > 0) {
        intByte |= _PACKED_BIT;
        addByte(intByte);
      } else {
        addByte(intByte);
        break;
      }
    } while (true);
  }
}

const _PACKED_BIT    = 0x80;   // 1xxx xxxx
const _PACKED_MASK   = 0x7F;   // x111 1111
const _PACKED_SHIFT  = 7;

// UTF-8 constants.
const int _UTF8_ONE_BYTE_LIMIT    = 0x7f;     // 7 bits
const int _UTF8_TWO_BYTE_LIMIT    = 0x7ff;    // 11 bits
const int _UTF8_THREE_BYTE_LIMIT  = 0xffff;   // 16 bits
const int _UTF8_FOUR_BYTE_LIMIT   = 0x10ffff; // 21 bits, truncated to Unicode max.

// UTF-16 constants.
const int _UTF8_SURROGATE_TAG_MASK    = 0xFC00;
const int _UTF8_SURROGATE_VALUE_MASK  = 0x3FF;
const int _UTF8_LEAD_SURROGATE_MIN    = 0xD800;

bool _isLeadSurrogate(int codeUnit) =>
    (codeUnit & _UTF8_SURROGATE_TAG_MASK) == _UTF8_LEAD_SURROGATE_MIN;

const _STRING_CAPACITY_LIMIT = 256;
