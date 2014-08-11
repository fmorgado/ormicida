part of ormicida.codec;

const _INDENT = '    ';

class Stringifier implements CodecListener {
  static const _IN_LIST = 0;
  static const _IN_MAP = 1;
  
  final   _buffer = new StringBuffer();
  final   _stack = <int>[];
  String  _property;
  bool    _hadItem = true;
  
  Stringifier();
  
  void clear() {
    _stack.clear();
    _buffer.clear();
    _hadItem = true;
    _property = null;
  }
  
  String getResult() {
    final result = _buffer.toString();
    clear();
    return result;
  }
  
  bool get _inList => _stack.length > 0 && _stack.last == _IN_LIST;
  bool get _inMap => _stack.length > 0 && _stack.last == _IN_MAP;
  
  void _indentBuffer() {
    if (_buffer.isNotEmpty) {
      _buffer.writeCharCode(Char.NEWLINE);
      
      int length = _stack.length;
      while (length-- > 0) {
        _buffer.write(_INDENT);
      }
    }
    
    if (_property != null) {
      _buffer.write(_property);
      _buffer.writeCharCode(Char.COLON);
      _buffer.writeCharCode(Char.SPACE);
      _property = null;
    }
  }
  
  void onValue(value) {
    if (_inMap && _property == null)
      throw new StateError('Property name not set');
    
    _indentBuffer();
    
    if (value is String) {
      _buffer.writeCharCode(Char.QUOTE);
      //TODO(fmorgado): escape string
      _buffer.write(value);
      _buffer.writeCharCode(Char.QUOTE);
    } else {
      _buffer.write(value);
    }
    
    if (_stack.length > 0) {
      _buffer.writeCharCode(Char.COMMA);
    }
  }
  
  void onPropertyStart(String name) {
    if (! _inMap)
      throw new StateError('Not in a map');
    if (_property != null)
      throw new StateError('Property name already set');
    
    _property = name;
  }
  
  void onListStart() {
    if (_inMap && _property == null)
      throw new StateError('Property name not set');
    _hadItem = false;
    _indentBuffer();
    _stack.add(_IN_LIST);
    _buffer.writeCharCode(Char.LEFT_BRACKET);
  }
  
  void onListEnd() {
    if (! _inList)
      throw new StateError('Not in a list');
    _stack.removeLast();
    if (_hadItem) _indentBuffer();
    _hadItem = true;
    _buffer.writeCharCode(Char.RIGHT_BRACKET);
    if (_stack.length > 0) _buffer.writeCharCode(Char.COMMA);
  }
  
  void onMapStart([String type]) {
    if (_inMap && _property == null)
      throw new StateError('Property name not set');
    _hadItem = false;
    _indentBuffer();
    _stack.add(_IN_MAP);
    if (type != null) {
      onPropertyStart(_MAP_TYPE_PROPERTY);
      onValue(type);
      onPropertyEnd();
    }
    _buffer.writeCharCode(Char.LEFT_BRACE);
  }
  
  void onMapEnd() {
    if (! _inMap) throw new StateError('Not in a map');
    _stack.removeLast();
    if (_hadItem) _indentBuffer();
    _hadItem = true;
    _buffer.writeCharCode(Char.RIGHT_BRACE);
    if (_stack.length > 0) _buffer.writeCharCode(Char.COMMA);
  }
  
  void onListElement() {
    _hadItem = true;
  }
  
  void onPropertyEnd() {
    _hadItem = true;
  }
}

const _MAP_TYPE_PROPERTY = '\$type';
