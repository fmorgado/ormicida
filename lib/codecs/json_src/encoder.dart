part of ormicida.codecs.json;

const _STRING_CAPACITY_LIMIT = 256;

class JsonEncoder implements CodecEncoder {
  static const _STATE_EXPECT_NOTHING      = 0;
  static const _STATE_EXPECT_VALUE        = 1;
  static const _STATE_EXPECT_MAP_FIRST    = 2;
  static const _STATE_EXPECT_MAP_PROPERTY = 3;
  static const _STATE_EXPECT_MAP_VALUE    = 4;
  static const _STATE_EXPECT_LIST_FIRST   = 5;
  static const _STATE_EXPECT_LIST_VALUE   = 6;
  
  Buffer        _output;
  final List    _stateStack = [];
  int           _state = _STATE_EXPECT_VALUE;
  
  JsonEncoder();
  
  void clear() {
    _output = null;
    _stateStack.clear();
    _state = _STATE_EXPECT_VALUE;
  }
  
  void initialize(Buffer output) {
    clear();
    _output = output;
  }
  
  static int _hexDigit(int x) => x < 10 ? 48 + x : 87 + x;
  
  void _writeJsonNum(num value) {
    if (value.isFinite) {
      _output.addAscii(value.toString());
    } else if (value.isNaN) {
      _output.addAscii('nan');
    } else if (value == double.INFINITY) {
      _output.addAscii('inf');
    } else {
      _output.addAscii('-inf');
    }
  }
  
  void _writeJsonString(String value) {
    final length = value.length;
    _output.addByte(Char.QUOTE);
    for (int i = 0; i < length; i++) {
      int charCode = value.codeUnitAt(i);
      if (charCode < 32) {
        _output.addByte(Char.BACKSLASH);
        switch (charCode) {
          case Char.BACKSPACE:        _output.addByte(Char.CHAR_b); break;
          case Char.TAB:              _output.addByte(Char.CHAR_t); break;
          case Char.NEWLINE:          _output.addByte(Char.CHAR_n); break;
          case Char.FORM_FEED:        _output.addByte(Char.CHAR_f); break;
          case Char.CARRIAGE_RETURN:  _output.addByte(Char.CHAR_r); break;
          default:
            _output.addByte(Char.CHAR_u);
            _output.addByte(_hexDigit((charCode >> 12) & 0xf));
            _output.addByte(_hexDigit((charCode >> 8) & 0xf));
            _output.addByte(_hexDigit((charCode >> 4) & 0xf));
            _output.addByte(_hexDigit(charCode & 0xf));
            break;
        }
      } else if (charCode == Char.QUOTE || charCode == Char.BACKSLASH) {
        _output.addByte(Char.BACKSLASH);
        _output.addByte(charCode);
      } else {
        _output.addCharCode(charCode);
      }
    }
    _output.addByte(Char.QUOTE);
  }
  
  void _writeJsonValue(value) {
    if (value is String) {
      _writeJsonString(value);
    } else if (value is num) {
      _writeJsonNum(value);
    } else if (identical(value, true)) {
      _output.addAscii('true');
    } else if (identical(value, false)) {
      _output.addAscii('false');
    } else if (value == null) {
      _output.addAscii('null');
    } else if (value is SchemaId) {
      _output.addBase64(value.bytes);
    } else if (value is DateTime) {
      _writeJsonString(value.toString());
    } else if (value is Duration) {
      _writeJsonNum(value.inMicroseconds);
    } else if (value is TypedData) {
      _output.addByte(Char.QUOTE);
      _output.addBase64(value is Uint8List ? value : new Uint8List.view(value.buffer));
      _output.addByte(Char.QUOTE);
    } else {
      throw new UnsupportedObjectError(value);
    }
  }
  
  void _writeJsonProperty(String name) {
    _output.addByte(Char.QUOTE);
    _output.addAscii(name);
    _output.addByte(Char.QUOTE);
    _output.addByte(Char.COLON);
  }
  
  void onValue(value) {
    switch(_state) {
      case _STATE_EXPECT_MAP_VALUE:
        _writeJsonValue(value);
        _state = _STATE_EXPECT_MAP_PROPERTY;
        break;
      case _STATE_EXPECT_LIST_FIRST:
        _writeJsonValue(value);
        _state = _STATE_EXPECT_LIST_VALUE;
        break;
      case _STATE_EXPECT_LIST_VALUE:
        _output.addByte(Char.COMMA);
        _writeJsonValue(value);
        //_state stays the same
        break;
      case _STATE_EXPECT_VALUE:
        _writeJsonValue(value);
        _state = _STATE_EXPECT_NOTHING;
        break;
      default:
        throw new StateError('unepected onValue call');
    }
  }
  
  void onPropertyStart(String name) {
    switch(_state) {
      case _STATE_EXPECT_MAP_PROPERTY:
        _output.addByte(Char.COMMA);
        _writeJsonProperty(name);
        _state = _STATE_EXPECT_MAP_VALUE;
        break;
      case _STATE_EXPECT_MAP_FIRST:
        _writeJsonProperty(name);
        _state = _STATE_EXPECT_MAP_VALUE;
        break;
      default:
        throw new StateError('unexpected onProperty call');
    }
  }
  
  void _writeMapStart(String type) {
    _output.addByte(Char.LEFT_BRACE);
    if (type != null) {
      _output.addByte(Char.QUOTE);
      _output.addAscii(_MAP_TYPE_PROPERTY);
      _output.addByte(Char.QUOTE);
      _output.addByte(Char.COLON);
      _output.addByte(Char.QUOTE);
      _output.addAscii(type);
      _output.addByte(Char.QUOTE);
      _state = _STATE_EXPECT_MAP_PROPERTY;
    } else {
      _state = _STATE_EXPECT_MAP_FIRST;
    }
  }
  
  void onMapStart([String type]) {
    switch (_state) {
      case _STATE_EXPECT_MAP_VALUE:
        _writeMapStart(type);
        _stateStack.add(_STATE_EXPECT_MAP_PROPERTY);
        break;
      case _STATE_EXPECT_LIST_FIRST:
        _writeMapStart(type);
        _stateStack.add(_STATE_EXPECT_LIST_VALUE);
        break;
      case _STATE_EXPECT_LIST_VALUE:
        _output.addByte(Char.COMMA);
        _writeMapStart(type);
        _stateStack.add(_STATE_EXPECT_LIST_VALUE);
        break;
      case _STATE_EXPECT_VALUE:
        _writeMapStart(type);
        _stateStack.add(_STATE_EXPECT_NOTHING);
        break;
      default:
        throw new StateError('unexpected onMapStart call');
    }
  }
  
  void onMapEnd() {
    switch (_state) {
      case _STATE_EXPECT_MAP_FIRST:
      case _STATE_EXPECT_MAP_PROPERTY:
        _output.addByte(Char.RIGHT_BRACE);
        _state = _stateStack.removeLast();
        break;
      default:
        throw new StateError('unexpected onMapEnd call');
    }
  }
  
  void onListStart() {
    switch (_state) {
      case _STATE_EXPECT_MAP_VALUE:
        _output.addByte(Char.LEFT_BRACKET);
        _stateStack.add(_STATE_EXPECT_MAP_PROPERTY);
        _state = _STATE_EXPECT_LIST_FIRST;
        break;
      case _STATE_EXPECT_LIST_FIRST:
        _output.addByte(Char.LEFT_BRACKET);
        _stateStack.add(_STATE_EXPECT_LIST_VALUE);
        _state = _STATE_EXPECT_LIST_FIRST;
        break;
      case _STATE_EXPECT_LIST_VALUE:
        _output.addByte(Char.COMMA);
        _output.addByte(Char.LEFT_BRACKET);
        _stateStack.add(_STATE_EXPECT_LIST_VALUE);
        _state = _STATE_EXPECT_LIST_FIRST;
        break;
      case _STATE_EXPECT_VALUE:
        _output.addByte(Char.LEFT_BRACKET);
        _stateStack.add(_STATE_EXPECT_NOTHING);
        _state = _STATE_EXPECT_LIST_FIRST;
        break;
      default:
        throw new StateError('unexpected onListStart call');
    }
  }
  
  void onListEnd() {
    switch (_state) {
      case _STATE_EXPECT_LIST_FIRST:
      case _STATE_EXPECT_LIST_VALUE:
        _output.addByte(Char.RIGHT_BRACKET);
        _state = _stateStack.removeLast();
        break;
      default:
        throw new StateError('unexpected onListEnd call');
    }
  }
  
  void onListElement() {}
  
  void onPropertyEnd() {}
}
