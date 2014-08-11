part of ormicida.codecs.bson;

class BsonEncoder implements CodecEncoder {
  static const int _AT_ROOT = 0;
  static const int _IN_MAP = 1;
  static const int _IN_LIST = 2;
  static const int _AT_END = 3;
  
  final List<int> _stack = <int>[];
  Buffer  _output;
  int     _state = _AT_ROOT;
  int     _sizePosition = 0;
  int     _listCount = 0;
  String  _property;
  
  BsonEncoder();
  
  void clear() {
    _output = null;
    _stack.clear();
    _state = _AT_ROOT;
    //_sizePosition = 0;
    //_listCount = 0;
    _property = null;
  }
  
  void initialize(Buffer output) {
    clear();
    _output = output;
    output.setLittleEndian();
    _sizePosition = output.length;
  }
  
  void _pushState() {
    switch (_state) {
      case _IN_MAP:
        _stack.add(_sizePosition);
        _stack.add(_IN_MAP);
        break;
        
      case _IN_LIST:
        _stack.add(_listCount);
        _stack.add(_sizePosition);
        _stack.add(_IN_LIST);
        break;
        
      case _AT_ROOT:
        _stack.add(_AT_END);
        break;
        
      default:
        throw new StateError('Invalid state');
    }
  }
  
  void _popState() {
    if (_stack.length <= 0)
      throw new StateError('Invalid state');
    
    switch (_state = _stack.removeLast()) {
      case _IN_MAP:
        _sizePosition = _stack.removeLast();
        break;
        
      case _IN_LIST:
        _sizePosition = _stack.removeLast();
        _listCount = _stack.removeLast();
        break;
    }
  }
  
  int _processPropertyName([int type = 0]) {
    final output = _output;
    int result = -1;
    switch(_state) {
      case _IN_MAP:
        assert(_property != null);
        result = output.length;
        output.addByte(type);
        output.addAscii(_property);
        output.addByte(0);
        _property = null;
        break;
        
      case _IN_LIST:
        result = output.length;
        output.addByte(type);
        output.addAscii(_listCount.toString());
        output.addByte(0);
        _listCount ++;
        break;
        
      case _AT_ROOT:
        break;
        
      default:
        throw new StateError('Invalid state');
    }
    return result;
  }
  
  int _writeInt(int value) {
    if (value >= _INT32_MIN && value <= _INT32_MAX) {
      _output.addInt32(value);
      return _INT32;
    } else if (value >= _INT64_MIN && value <= _INT64_MAX) {
      _output.addInt64(value);
      return _INT64;
    } else if (value >= 0 && value <= _UINT64_MAX) {
      _output.addUint64(value);
      return _TIMESTAMP;
    } else {
      throw new RangeError('Integer too large:  $value');
    }
  }
  
  void onValue(value) {
    assert(_state == _IN_MAP || _state == _IN_LIST);
    
    final output = _output;
    
    int bsonType = -1;
    final int typePosition = _processPropertyName();
    
    if (value == null) {
      bsonType = _NULL;
      
    } else if (value == false) {
      bsonType = _BOOLEAN;
      output.addByte(0);
      
    } else if (value == true) {
      bsonType = _BOOLEAN;
      output.addByte(1);
      
    } else if (value is String) {
      bsonType = _STRING;
       final sizePosition = output.addSpace(4);
      output.addString(value);
      output.addByte(0);
      output.writeUint32(output.length - sizePosition - 4, sizePosition);
      
    } else if (value is int) {
      bsonType = _writeInt(value);
      
    } else if (value is num) {
      bsonType = _FLOAT;
      output.addFloat64(value);
      
    } else if (value is DateTime) {
      bsonType = _DATE_TIME;
      output.addInt64(value.millisecondsSinceEpoch);
      
    } else if (value is Duration) {
      bsonType = _writeInt(value.inMicroseconds);
      
    } else if (value is TypedData) {
      bsonType = _BINARY;
      output.addUint32(value.lengthInBytes);
      output.addByte(0);
      output.addBytes(value);
      
    } else if (value is SchemaId) {
      bsonType = _OBJECT_ID;
      final bytes = value.bytes;
      final length = bytes.length;
      
      if (length > 12)
        throw new ArgumentError('ObjectId too large:  $value');
      
      if (length < 12) {
        for (var count = length; count < 12; count++)
          output.addByte(0);
      }
      output.addBytes(bytes);
      
    } else if (value is RegExp) {
      bsonType = _REGEXP;
      output.addAscii(value.pattern);
      output.addByte(0);
      if (! value.isCaseSensitive)
        output.addByte(_CHAR_i);
      if (value.isMultiLine)
        output.addByte(_CHAR_m);
      output.addByte(0);
      
    } else {
      throw new UnsupportedObjectError(value);
    }
    
    if (typePosition >= 0) {
      output.writeByte(bsonType, typePosition);
    }
  }
  
  void onPropertyStart(String name) {
    assert(_state == _IN_MAP && _property == null);
    _property = name;
  }
  
  void onMapStart([String type]) {
    assert(_state == _AT_ROOT || _state == _IN_LIST
        || (_state == _IN_MAP && _property != null));
    // TODO(fmorgado): handle map type
    _processPropertyName(_OBJECT);
    _pushState();
    _state = _IN_MAP;
    _sizePosition = _output.addSpace(4);
  }
  
  void onMapEnd() {
    assert(_state == _IN_MAP);
    _output.addByte(0);
    _output.writeUint32(_output.length - _sizePosition, _sizePosition);
    _popState();
  }
  
  void onListStart() {
    assert(_state == _IN_LIST || (_state == _IN_MAP && _property != null));
    _processPropertyName(_ARRAY);
    _pushState();
    _state = _IN_LIST;
    _listCount = 0;
    _sizePosition = _output.addSpace(4);
  }
  
  void onListEnd() {
    assert(_state == _IN_LIST);
    _output.addByte(0);
    _output.writeUint32(_output.length - _sizePosition, _sizePosition);
    _popState();
  }
  
  void onListElement() {}
  
  void onPropertyEnd() {}
}
