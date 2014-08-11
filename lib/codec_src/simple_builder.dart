part of ormicida.codec;

final SimpleBuilder simpleBuilder = new SimpleBuilder();

class SimpleBuilder implements CodecListener {
  final   _stack = [];
  var     _container;
  String  _property;
  var     _value;
  
  SimpleBuilder();
  
  void clear() {
    _stack.clear();
    _container = null;
    _property = null;
    _value = null;
  }
  
  dynamic getResult() {
    assert(_stack.length == 0);
    assert(_container == null);
    final result = _value;
    clear();
    return result;
  }
  
  Object decodeFrom(Buffer input, CodecDecoder decoder) {
    clear();
    decoder.decodeTo(input, this);
    
    final result = _value;
    clear();
    return result;
  }
  
  Object decode(List<int> bytes, CodecDecoder decoder) =>
      decodeFrom(new Buffer.fromBytes(bytes), decoder);
  
  void _pushContainer(container) {
    if (_container != null) {
      if (_container is Map) {
        assert(_property != null);
        _stack.add(_property);
      }
      _stack.add(_container);
    }
    
    _container = container;
    _value = null;
  }
  
  void _popContainer() {
    _value = _container;
    if (_stack.length > 0) {
      _container = _stack.removeLast();
      if (_container is Map) {
        _property = _stack.removeLast();
      }
    } else {
      _container = null;
    }
  }
  
  void onValue(value) {
    _value = value;
  }
  
  void onPropertyStart(String name) {
    assert(_container is Map);
    _property = name;
  }
  
  void onPropertyEnd() {
    assert(_container is Map);
    assert(_property != null);
    _container[_property] = _value;
  }
  
  void onListStart() {
    _pushContainer([]);
  }
  
  void onListEnd() {
    assert(_container is List);
    _popContainer();
  }
  
  void onMapStart([String type]) {
    final container = {};
    if (type != null) container[r'$type'] = type;
    _pushContainer(container);
  }
  
  void onMapEnd() {
    assert(_container is Map);
    _popContainer();
  }
  
  void onListElement() {
    assert(_container is List);
    (_container as List).add(_value);
  }
}
