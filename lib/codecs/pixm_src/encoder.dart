part of ormicida.codecs.pixm;

class PixmEncoder implements CodecEncoder {
  Buffer              _output;
  final List<String>  _dictionary = <String>[];
  
  PixmWriter() {}
  
  void clear() {
    _dictionary.clear();
  }
  
  void initialize(Buffer output) {
    clear();
    _output = output;
    output.setBigEndian();
  }
  
  void _writeString(final String value) {
    final length = value.length;
    for (var index = 0; index < length; index++) {
      _output.addPackedUInt(value.codeUnitAt(index));
    }
    _output.addByte(0);
  }
  
  void onValue(value) {
    if (value == null) {
      _output.addByte(_CONSTANT | _CONSTANT_NULL);
      
    } else if (value == false) {
      _output.addByte(_CONSTANT | _CONSTANT_FALSE);
      
    } else if (value == true) {
      _output.addByte(_CONSTANT | _CONSTANT_TRUE);
      
    } else if (value is String) {
      final length = value.length;
      
      if (length <= _STRING_TINY_LENGTH_MASK) {
        _output.addByte(_STRING | _STRING_TINY_LENGTH_BIT | length);
        for (var index = 0; index < length; index++) {
          _output.addPackedUInt(value.codeUnitAt(index));
        }
        
      } else {
        _output.addByte(_STRING);
        _writeString(value);
      }
      
    } else if (value is int) {
      int negBit = 0;
      if (value < 0) {
        value = -value;
        negBit = _INTEGER_NEGATIVE_BIT;
      }
      
      if (value <= _INTEGER_TINY_MASK) {
        _output.addByte(_INTEGER_TINY | negBit | value);
        
      } else {
        final numBits = value.bitLength;
        int numBytes = numBits ~/ 8;
        if (numBits % 8 > 0) numBytes ++;
        
        if (numBytes <= _INTEGER_TINY_LENGTH_MASK) {
          _output.addByte(_INTEGER_HUGE | negBit | _INTEGER_TINY_LENGTH | numBytes);
          while (numBytes-- > 0) {
            _output.addByte(value & 0xFF);
            value >>= 8;
          }
          
        } else {
          _output.addByte(_INTEGER_HUGE | negBit);
          _output.addPackedUInt(value);
        }
      }
      
    } else if (value is num) {
      if (value.isFinite) {
        if (value == 0.0) {
          _output.addByte(_CONSTANT | _CONSTANT_ZERO);
          
        } else {
          _output.addByte(_FLOAT | _FLOAT_SIZE_64);
          _output.addFloat64(value);
        }
        
      } else {
        if (value.isNaN) {
          _output.addByte(_CONSTANT | _CONSTANT_NAN);
        } else if (value == double.INFINITY) {
          _output.addByte(_CONSTANT | _CONSTANT_INF);
        } else {
          assert(value == double.NEGATIVE_INFINITY);
          _output.addByte(_CONSTANT | _CONSTANT_NEG_INF);
        }
      }
      
    } else if (value is DateTime) {
      int time = value.millisecondsSinceEpoch;
      int negBit = 0;
      if (time < 0) {
        negBit = _OTHER_NEGATIVE;
        time = -time;
      }
      _output.addByte(_OTHER | negBit | _OTHER_DATE);
      _output.addPackedUInt(time);
      
    } else if (value is Duration) {
      int time = value.inMicroseconds;
      int negBit = 0;
      if (time < 0) {
        negBit = _OTHER_NEGATIVE;
        time = -time;
      }
      _output.addByte(_OTHER | negBit | _OTHER_DURATION);
      _output.addPackedUInt(time);
      
    } else if (value is TypedData) {
      final length = value.lengthInBytes;
      
      Uint8List bytes;
      if (value is Uint8List) {
        bytes = value;
      } else {
        bytes = new Uint8List.view(value.buffer, 0, length);
      }
      
      if (length <= _BINARY_LENGTH_MASK) {
        _output.addByte(_BINARY | _BINARY_LENGTH_TINY | length);
        
      } else {
        _output.addByte(_BINARY);
        _output.addPackedUInt(length);
      }
      
      _output.addBytes(bytes);
      
    } else if (value is SchemaId) {
      _output.addByte(_OTHER | _OTHER_ID);
      final bytes = value.bytes;
      _output.addPackedUInt(bytes.length);
      _output.addBytes(bytes);
      
    } else if (value is RegExp) {
      _output.addByte(_OTHER | _OTHER_REG_EXP);
      _writeString(value.pattern);
      var flags = '';
      if (value.isMultiLine) flags += 'm';
      if (! value.isCaseSensitive) flags += 'i';
      _writeString(flags);
      
    } else {
      throw new UnsupportedObjectError(value);
    }
  }
  
  void onMapStart([String type]) {
    if (type != null) {
      final index = _dictionary.indexOf(type);
      if (index < 0) {
        _dictionary.add(type);
        _output.addByte(_COMPLEX | _COMPLEX_DICT_STRING | _COMPLEX_MAP_START);
        _writeString(type);
        
      } else {
        _output.addByte(_COMPLEX | _COMPLEX_DICT_INDEX | _COMPLEX_MAP_START);
        _output.addPackedUInt(index);
      }
      
    } else {
      _output.addByte(_COMPLEX | _COMPLEX_DICT_NONE | _COMPLEX_MAP_START);
    }
  }
  
  void onPropertyStart(String name) {
    final index = _dictionary.indexOf(name);
    
    if (index < 0) {
      _output.addByte(_COMPLEX | _COMPLEX_DICT_STRING | _COMPLEX_PROPERTY);
      _dictionary.add(name);
      _writeString(name);
      
    } else {
      _output.addByte(_COMPLEX | _COMPLEX_DICT_INDEX | _COMPLEX_PROPERTY);
      _output.addPackedUInt(index);
    }
  }
  
  void onMapEnd() {
    _output.addByte(_COMPLEX | _COMPLEX_MAP_END);
  }
  
  void onListStart() {
    _output.addByte(_COMPLEX | _COMPLEX_LIST_START);
  }
  
  void onListEnd() {
    _output.addByte(_COMPLEX | _COMPLEX_LIST_END);
  }
  
  void onListElement() {}
  
  void onPropertyEnd() {}
}
