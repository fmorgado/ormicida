part of ormicida.codecs.pixm;

class PixmDecoder implements CodecDecoder {
  final List<String>  _dictionary = <String>[];
  final StringBuffer  _stringBuffer = new StringBuffer();
  
  PixmDecoder();
  
  void clear() {
    _dictionary.clear();
    _stringBuffer.clear();
  }
  
  String _readString(final Buffer input) {
    final stringBuffer = _stringBuffer;
    while (true) {
      int charCode = input.getPackedUInt();
      if (charCode == 0) break;
      stringBuffer.writeCharCode(charCode);
    }
    final result = stringBuffer.toString();
    stringBuffer.clear();
    return result;
  }
  
  String _getIndexedString(final int index, final Buffer input) {
    if (index > _dictionary.length)
      throw new FormatException('Invalid index, position: ${input.position}');
    return _dictionary[index];
  }
  
  void readEntry(final Buffer input, final CodecListener listener) {
    clear();
    input.setBigEndian();
    
    const STATE_EOF       = 0;
    const STATE_MAP_START = 1;
    const STATE_MAP_VALUE = 2;
    const STATE_LIST      = 3;
    
    final List stack = <int>[];
    int state = STATE_EOF;
    
    do {
      final byte = input.getByte();
      final type = byte & _TYPE_MASK;
      
      if (type == _COMPLEX) {
        
        switch(byte & _COMPLEX_TYPE_MASK) {
          
          case _COMPLEX_MAP_START:
            if (state == STATE_MAP_START)
              throw new FormatException('unexpected MapStart entry, position: ${input.position}');
            
            String mapType = null;
            switch(byte & _COMPLEX_DICT_MASK) {
              case _COMPLEX_DICT_NONE:
                break;
              case _COMPLEX_DICT_STRING:
                mapType = _readString(input);
                _dictionary.add(mapType);
                break;
              case _COMPLEX_DICT_INDEX:
                mapType = _getIndexedString(input.getPackedUInt(), input);
                break;
              default:
                throw new FormatException('unexpected MapType constant, position: ${input.position}');
            }
            
            listener.onMapStart(mapType);
            stack.add(state);
            state = STATE_MAP_START;
            break;
            
          case _COMPLEX_MAP_END:
            if (state != STATE_MAP_START) {
              throw new FormatException('unexpected MapEnd entry, position: ${input.position}');
            }
            listener.onMapEnd();
            state = stack.removeLast();
            switch (state) {
              case STATE_MAP_VALUE:
                listener.onPropertyEnd();
                state = STATE_MAP_START;
                break;
              case STATE_LIST:
                listener.onListElement();
                break;
            }
            break;
            
          case _COMPLEX_PROPERTY:
            if (state != STATE_MAP_START)
              throw new FormatException('unexpected Property entry, position: ${input.position}');
            
            String name;
            switch(byte & _COMPLEX_DICT_MASK) {
              case _COMPLEX_DICT_STRING:
                name = _readString(input);
                _dictionary.add(name);
                break;
              case _COMPLEX_DICT_INDEX:
                name = _getIndexedString(input.getPackedUInt(), input);
                break;
              default:
                throw new FormatException(
                    'invalid PropertyName constant, position: ${input.position}');
            }
            
            listener.onPropertyStart(name);
            state = STATE_MAP_VALUE;
            break;
            
          case _COMPLEX_LIST_START:
            if (state == STATE_MAP_START) {
              throw new FormatException(
                  'Unexpected ListStart entry, position: ${input.position}');
            }
            listener.onListStart();
            stack.add(state);
            state = STATE_LIST;
            break;
            
          case _COMPLEX_LIST_END:
            if (state != STATE_LIST) {
              throw new FormatException(
                  'invalid ListEnd entry, position: ${input.position}');
            }
            listener.onListEnd();
            state = stack.removeLast();
            switch (state) {
              case STATE_MAP_VALUE:
                listener.onPropertyEnd();
                state = STATE_MAP_START;
                break;
              case STATE_LIST:
                listener.onListElement();
                break;
            }
            break;
            
          default:
            throw new FormatException(
                'invalid Complex constant, position: ${input.position}');
        }
        
      } else {
        
        switch (type) {
          case _CONSTANT:
            switch (byte & _CONSTANT_MASK) {
              case _CONSTANT_NULL:
                listener.onValue(null);
                break;
              case _CONSTANT_FALSE:
                listener.onValue(false);
                break;
              case _CONSTANT_TRUE:
                listener.onValue(true);
                break;
              case _CONSTANT_NAN:
                listener.onValue(double.NAN);
                break;
              case _CONSTANT_INF:
                listener.onValue(double.INFINITY);
                break;
              case _CONSTANT_NEG_INF:
                listener.onValue(double.NEGATIVE_INFINITY);
                break;
              case _CONSTANT_ZERO:
                listener.onValue(0.0);
                break;
              default:
                throw new FormatException(
                    'invalid constant type, position: ${input.position}');
            }
            break;
            
          case _STRING:
            if (byte & _STRING_TINY_LENGTH_BIT > 0) {
              final stringBuffer = _stringBuffer;
              int length = byte & _STRING_TINY_LENGTH_MASK;
              while (length-- > 0) {
                stringBuffer.writeCharCode(input.getPackedUInt());
              }
              listener.onValue(stringBuffer.toString());
              stringBuffer.clear();
              
            } else {
              listener.onValue(_readString(input));
            }
            break;
            
          case _INTEGER_TINY:
            final bool isNegative = (byte & _INTEGER_NEGATIVE_BIT) > 0;
            final value = byte & _INTEGER_TINY_MASK;
            listener.onValue(isNegative ? -value : value);
            break;
            
          case _INTEGER_HUGE:
            final bool isNegative = (byte & _INTEGER_NEGATIVE_BIT) > 0;
            int numBytes = 0;
            
            if (byte & _INTEGER_TINY_LENGTH > 0) {
              numBytes = byte & _INTEGER_TINY_LENGTH_MASK;
              int value = 0;
              int shift = 0;
              while (numBytes-- > 0) {
                value = value | (input.getByte() << shift);
                shift += 8;
              }
              listener.onValue(isNegative ? -value : value);
              
            } else {
              final int value = input.getPackedUInt();
              listener.onValue(isNegative ? -value : value);
            }
            break;
            
          case _FLOAT:
            switch (byte & _FLOAT_SIZE_MASK) {
              case _FLOAT_SIZE_32:
                listener.onValue(input.getFloat32());
                break;
              case _FLOAT_SIZE_64:
                listener.onValue(input.getFloat64());
                break;
              default:
                throw new FormatException(
                    'invalid Float constant, position: ${input.position}');
            }
            break;
            
          case _BINARY:
            int length = 0;
            if (byte & _BINARY_LENGTH_TINY > 0) {
              length = byte & _BINARY_LENGTH_MASK;
            } else {
              length = input.getPackedUInt();
            }
            listener.onValue(input.getBytes(length));
            break;
            
          case _OTHER:
            final bool isNeg = byte & _OTHER_NEGATIVE > 0;
            
            switch (byte & _OTHER_MASK) {
              case _OTHER_DATE:
                final time = input.getPackedUInt();
                listener.onValue(new DateTime.fromMillisecondsSinceEpoch(isNeg ? -time : time));
                break;
                
              case _OTHER_DURATION:
                final time = input.getPackedUInt();
                listener.onValue(new Duration(microseconds: isNeg ? -time : time));
                break;
                
              case _OTHER_ID:
                final length = input.getPackedUInt();
                listener.onValue(new SchemaId(input.getBytes(length)));
                break;
                
              case _OTHER_REG_EXP:
                final pattern = _readString(input);
                final flags = _readString(input);
                listener.onValue(new RegExp(pattern,
                    multiLine: flags.indexOf('m') >= 0,
                    caseSensitive: flags.indexOf('i') < 0));
                break;
                
              default:
                throw new FormatException(
                    'invalid "Other" constant, position: ${input.position}');
            }
            break;
            
          default:
            throw new FormatException(
                'invalid entry constant, position: ${input.position}');
            break;
        }
        
        switch (state) {
          case STATE_MAP_VALUE:
            listener.onPropertyEnd();
            state = STATE_MAP_START;
            break;
          case STATE_LIST:
            listener.onListElement();
            break;
          case STATE_EOF:
            break;
          default:
            throw new FormatException('invalid Value entry,' 
                + ' expected MapProperty or MapEnd entries,'
                + ' position: ${input.position}');
        }
      }
      
    } while (state != STATE_EOF);
  }
  
  void decodeTo(final Buffer input, final CodecListener listener) {
    readEntry(input, listener);
    if (input.availableBytes > 0)
      throw new FormatException('trailing bytes, position: ${input.position}');
  }
}
