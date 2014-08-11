part of ormicida.codecs.json;

class JsonDecoder implements CodecDecoder {
  static const _STATE_EOF = 0;
  static const _STATE_LIST_START = 1;
  static const _STATE_LIST_END = 2;
  static const _STATE_MAP_PROPERTY = 3;
  static const _STATE_MAP_COLON = 4;
  static const _STATE_MAP_VALUE = 5;
  static const _STATE_MAP_END = 6;
  static const _STATE_TYPE_KEY = 7;
  static const _STATE_TYPE_COLON = 8;
  static const _STATE_TYPE_VALUE = 9;
  
  final StringBuffer  _buffer = new StringBuffer();
  
  JsonDecoder();
  
  void clear() {
    _buffer.clear();
  }
  
  void decodeTo(final Buffer input, final CodecListener listener) {
    clear();
    
    _readJsonToken(input, listener);
    
    int available = input.availableBytes;
    while (available > 0) {
      switch (input.getByte()) {
        case Char.SPACE:
        case Char.CARRIAGE_RETURN:
        case Char.NEWLINE:
        case Char.TAB:
          break;
        default:
          throw new FormatException('trailing bytes,' + ' position: ${input.position}');
      }
      available --;
    }
  }
  
  void _readJsonToken(final Buffer input, final CodecListener listener) {
    final List<int> stack = <int>[];
    int state = _STATE_EOF;
    
    void popStack() {
      state = stack.removeLast();
      switch (state) {
        case _STATE_MAP_END:
          listener.onPropertyEnd();
          break;
        case _STATE_LIST_END:
          listener.onListElement();
          break;
        default:
          assert(state == _STATE_EOF);
          return;
      }
    }
    
    nextToken:
    while(true) {
      final byte = input.getByte();
      switch(byte) {
        case Char.COMMA:
          switch (state) {
            case _STATE_MAP_END:
              state = _STATE_MAP_PROPERTY;
              break;
            case _STATE_LIST_END:
              state = _STATE_LIST_START;
              break;
            default:
              throw new FormatException('unexpected command,'
                  +' position: ${input.position}');
          }
          continue nextToken;
          
        case Char.QUOTE:
          switch(state) {
            case _STATE_LIST_START:
              listener.onValue(_readString(input));
              listener.onListElement();
              state = _STATE_LIST_END;
              continue nextToken;
            case _STATE_MAP_PROPERTY:
              listener.onPropertyStart(_readString(input));
              state = _STATE_MAP_COLON;
              continue nextToken;
            case _STATE_MAP_VALUE:
              listener.onValue(_readString(input));
              listener.onPropertyEnd();
              state = _STATE_MAP_END;
              continue nextToken;
            case _STATE_TYPE_KEY:
              final typeKey = _readString(input);
              if (typeKey == _MAP_TYPE_PROPERTY) {
                state = _STATE_TYPE_COLON;
              } else {
                listener.onMapStart();
                listener.onPropertyStart(typeKey);
                state = _STATE_MAP_COLON;
              }
              continue nextToken;
            case _STATE_TYPE_VALUE:
              listener.onMapStart(_readString(input));
              state = _STATE_MAP_END;
              continue nextToken;
            case _STATE_EOF:
              listener.onValue(_readString(input));
              return;
            default:
              throw new FormatException('unexpected character,'
                  +' position: ${input.position}');
          }
          break;
          
        case Char.LEFT_BRACE:
          switch (state) {
            case _STATE_LIST_START:
              stack.add(_STATE_LIST_END);
              state = _STATE_TYPE_KEY;
              continue nextToken;
            case _STATE_MAP_VALUE:
              stack.add(_STATE_MAP_END);
              state = _STATE_TYPE_KEY;
              continue nextToken;
            case _STATE_EOF:
              stack.add(_STATE_EOF);
              state = _STATE_TYPE_KEY;
              continue nextToken;
            default:
              throw new FormatException('unexpected character,'
                  +' position: ${input.position}');
          }
          break;
          
        case Char.RIGHT_BRACE:
          switch(state) {
            case _STATE_MAP_END:
            case _STATE_MAP_PROPERTY:
              listener.onMapEnd();
              state = stack.removeLast();
              switch (state) {
                case _STATE_MAP_END:
                  listener.onPropertyEnd();
                  break;
                case _STATE_LIST_END:
                  listener.onListElement();
                  break;
                default:
                  assert(state == _STATE_EOF);
                  return;
              }
              continue nextToken;
            case _STATE_TYPE_KEY:
              listener.onMapStart();
              listener.onMapEnd();
              state = stack.removeLast();
              switch (state) {
                case _STATE_MAP_END:
                  listener.onPropertyEnd();
                  break;
                case _STATE_LIST_END:
                  listener.onListElement();
                  break;
                default:
                  assert(state == _STATE_EOF);
                  return;
              }
              continue nextToken;
            default:
              throw new FormatException('unexpected character,'
                  +' position: ${input.position}');
          }
          break;
          
        case Char.COLON:
          switch (state) {
            case _STATE_MAP_COLON:
              state = _STATE_MAP_VALUE;
              continue nextToken;
            case _STATE_TYPE_COLON:
              state = _STATE_TYPE_VALUE;
              continue nextToken;
            default:
              throw new FormatException('unexpected character,'
                  +' position: ${input.position}');
          }
          assert(false);  // Should not reach!
          continue nextToken;
          
        case Char.LEFT_BRACKET:
          listener.onListStart();
          switch (state) {
            case _STATE_LIST_START:
              stack.add(_STATE_LIST_END);
              state = _STATE_LIST_START;
              continue nextToken;
            case _STATE_MAP_VALUE:
              stack.add(_STATE_MAP_END);
              state = _STATE_LIST_START;
              continue nextToken;
            case _STATE_EOF:
              stack.add(_STATE_EOF);
              state = _STATE_LIST_START;
              continue nextToken;
            default:
              throw new FormatException('unexpected character,'
                  +' position: ${input.position}');
          }
          break;
          
        case Char.RIGHT_BRACKET:
          switch(state) {
            case _STATE_LIST_END:
            case _STATE_LIST_START:
              listener.onListEnd();
              state = stack.removeLast();
              switch (state) {
                case _STATE_MAP_END:
                  listener.onPropertyEnd();
                  break;
                case _STATE_LIST_END:
                  listener.onListElement();
                  break;
                default:
                  assert(state == _STATE_EOF);
                  return;
              }
              continue nextToken;
            default:
              throw new FormatException('unexpected character,'
                  +' position: ${input.position}');
          }
          break;
          
        case Char.SPACE:
        case Char.CARRIAGE_RETURN:
        case Char.NEWLINE:
        case Char.TAB:
          break;
          
        default:
          switch(state) {
            case _STATE_LIST_START:
            case _STATE_MAP_VALUE:
            case _STATE_EOF:
              if (byte >= Char.CHAR_0 && byte <= Char.CHAR_9) {
                _buffer.writeCharCode(byte);
                _readJsonNum(input, listener, false);
                
              } else {
                var value;
                switch(byte) {
                  case Char.MINUS:
                    final int next = input.getByte();
                    if (next == Char.CHAR_i || next == Char.CHAR_I) {
                      if (_toLower(input.getByte()) == Char.CHAR_n
                          && _toLower(input.getByte()) == Char.CHAR_f) {
                        listener.onValue(double.NEGATIVE_INFINITY);
                      } else {
                        throw new FormatException('invalid constant inf,'
                            +' position: ${input.position}');
                      }
                      
                    } else if (next >= Char.CHAR_0 && next <= Char.CHAR_9) {
                      _buffer.writeCharCode(Char.MINUS);
                      _buffer.writeCharCode(next);
                      _readJsonNum(input, listener, false);
                    } else {
                      throw new FormatException('unexpected character,'
                          +' position: ${input.position}');
                    }
                    break;
                    
                  case Char.CHAR_t:
                  case Char.CHAR_T:
                    if (_toLower(input.getByte()) == Char.CHAR_r
                        && _toLower(input.getByte()) == Char.CHAR_u
                        && _toLower(input.getByte()) == Char.CHAR_e) {
                      listener.onValue(true);
                    } else {
                      throw new FormatException('unexpected character,'
                          +' position: ${input.position}');
                    }
                    break;
                    
                  case Char.CHAR_f:
                  case Char.CHAR_F:
                    if (_toLower(input.getByte()) == Char.CHAR_a
                        && _toLower(input.getByte()) == Char.CHAR_l
                        && _toLower(input.getByte()) == Char.CHAR_s
                        && _toLower(input.getByte()) == Char.CHAR_e) {
                      listener.onValue(false);
                    } else {
                      throw new FormatException('unexpected character,'
                          +' position: ${input.position}');
                    }
                    break;
                    
                  case Char.CHAR_n:
                  case Char.CHAR_N:
                    final next = input.getByte();
                    if (next == Char.CHAR_u || next == Char.CHAR_U) {
                      if (_toLower(input.getByte()) == Char.CHAR_l
                          && _toLower(input.getByte()) == Char.CHAR_l) {
                        listener.onValue(null);
                      } else {
                        throw new FormatException('unexpected character,'
                            +' position: ${input.position}');
                      }
                      
                    } else if (next == Char.CHAR_a || next == Char.CHAR_A) {
                      if (_toLower(input.getByte()) == Char.CHAR_n) {
                        listener.onValue(double.NAN);
                      } else {
                        throw new FormatException('unexpected character,'
                            +' position: ${input.position}');
                      }
                      
                    }
                    break;
                    
                  case Char.CHAR_i:
                  case Char.CHAR_I:
                    if (_toLower(input.getByte()) == Char.CHAR_n
                        && _toLower(input.getByte()) == Char.CHAR_f) {
                      listener.onValue(double.INFINITY);
                    } else {
                      throw new FormatException('unexpected character,'
                          +' position: ${input.position}');
                    }
                    break;
                    
                  case Char.POINT:
                    _buffer.writeCharCode(Char.POINT);
                    _readJsonNum(input, listener, false);
                    break;
                    
                  case Char.PLUS:
                    final int next = input.getByte();
                    if (next == Char.CHAR_i || next == Char.CHAR_I) {
                      if (_toLower(input.getByte()) == Char.CHAR_n
                          && _toLower(input.getByte()) == Char.CHAR_f) {
                        listener.onValue(double.INFINITY);
                      } else {
                        throw new FormatException('unexpected character,'
                            +' position: ${input.position}');
                      }
                      
                    } else if (next >= Char.CHAR_0 && next <= Char.CHAR_9) {
                      _buffer.writeCharCode(next);
                      _readJsonNum(input, listener, false);
                    } else {
                      throw new FormatException('unexpected character,'
                          +' position: ${input.position}');
                    }
                    break;
                    
                  default:
                    throw new FormatException('unexpected character,'
                        +' position: ${input.position}');
                }
              }
              
              switch (state) {
                case _STATE_LIST_START:
                  listener.onListElement();
                  state = _STATE_LIST_END;
                  continue nextToken;
                case _STATE_MAP_VALUE:
                  listener.onPropertyEnd();
                  state = _STATE_MAP_END;
                  continue nextToken;
                //case _STATE_EOF:
                default:
                  return; 
              }
              break;
              
            default:
              throw new FormatException('unexpected character,'
                  +' position: ${input.position}');
          }
      }
    }
  }
  
  String _readString(final Buffer input) {
    final buffer = _buffer;
    while(true) {
      final int code = input.getCharCode();
      
      switch(code) {
        case Char.QUOTE:
          final stringValue = _buffer.toString();
          buffer.clear();
          return stringValue;
          
        case Char.BACKSLASH:
          final int byte = input.getByte();
          
          switch (byte) {
            case Char.CHAR_b:
              buffer.writeCharCode(Char.BACKSPACE);
              break;
            case Char.CHAR_f:
              buffer.writeCharCode(Char.FORM_FEED);
              break;
            case Char.CHAR_n:
              buffer.writeCharCode(Char.NEWLINE);
              break;
            case Char.CHAR_t:
              buffer.writeCharCode(Char.TAB);
              break;
            case Char.CHAR_r:
              buffer.writeCharCode(Char.CARRIAGE_RETURN);
              break;
            case Char.SLASH:
            case Char.BACKSLASH:
            case Char.QUOTE:
              buffer.writeCharCode(byte);
              break;
            case Char.CHAR_u:
              buffer.writeCharCode(
                  (_parseHexDigit(input.getByte()) << 12)
                  | (_parseHexDigit(input.getByte()) << 8)
                  | (_parseHexDigit(input.getByte()) << 4)
                  | _parseHexDigit(input.getByte()));
              break;
            default:
              throw new FormatException('invalid escape,'
                  +' position: ${input.position}');
          }
          break;
          
        default:
          buffer.writeCharCode(code);
          break;
      }
    }
  }
  
  void _readJsonNum(final Buffer input, final CodecListener listener, bool isDouble) {
    final buffer = _buffer;
    while(input.availableBytes > 0) {
      final byte = input.getByte();
      
      if (byte >= Char.CHAR_0 && byte <= Char.CHAR_9) {
        buffer.writeCharCode(byte);
        
      } else if (byte == Char.POINT) {
        if (isDouble)
          throw new FormatException('unexpected character,'
              + ' position: ${input.position}');
        isDouble = true;
        buffer.writeCharCode(byte);
        
      } else {
        input.position --;
        break;
      }
    }
    
    listener.onValue(isDouble
        ? double.parse(buffer.toString())
        : int.parse(buffer.toString()));
    buffer.clear();
  }
  
  int _toLower(final int byte) =>
    byte >= Char.CHAR_A && byte <= Char.CHAR_Z
      ? byte + (Char.CHAR_a - Char.CHAR_A)
      : byte;
  
  int _parseHexDigit(final int byte) {
    if (byte >= Char.CHAR_0 && byte <= Char.CHAR_9) {
      return byte - Char.CHAR_0;
    } else if (byte >= Char.CHAR_A && byte <= Char.CHAR_F) {
      return byte - (Char.CHAR_A - 10);
    } else if (byte >= Char.CHAR_a && byte <= Char.CHAR_f) {
      return byte - (Char.CHAR_a - 10);
    } else {
      throw new FormatException('invalid hexadecimal,'
          + 'code: $byte: char: ${new String.fromCharCode(byte)},');
    }
  }
}
