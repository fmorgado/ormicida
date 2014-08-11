part of ormicida.codec;

final SimpleInspector simpleInspector = new SimpleInspector();

class CyclicError extends Error {
  final object;
  CyclicError(this.object);
}

class UnsupportedObjectError extends Error {
  final object;
  UnsupportedObjectError(this.object);
}

class SimpleInspector {
  final List<Object>  _seen = [];
  CodecListener      _listener;
  
  SimpleInspector();
  
  void clear() {
    _seen.clear();
    _listener = null;
  }
  
  void _pushSeen(object) {
    if (_seen.contains(object))
      throw new CyclicError(object);
    _seen.add(object);
  }
  
  void _popSeen() {
    _seen.removeLast();
  }
  
  void _inspect(final object, final CodecListener listener) {
    if (object == null) {
      listener.onValue(null);
      
    } else if (object is Map) {
      _pushSeen(object);
      listener.onMapStart();
      object.forEach((String key, value) {
        listener.onPropertyStart(key);
        _inspect(value, listener);
        listener.onPropertyEnd();
      });
      listener.onMapEnd();
      _popSeen();
      
    } else if (object is List && object is! TypedData) {
      _pushSeen(object);
      listener.onListStart();
      final length = object.length;
      for (var index = 0; index < length; index++) {
        _inspect(object[index], listener);
        listener.onListElement();
      }
      listener.onListEnd();
      _popSeen();
      
    } else {
      listener.onValue(object);
    }
  }
  
  void inspect(final object, final CodecListener listener) {
    clear();
    _listener = listener;
    _inspect(object, listener);
  }
  
  void encodeTo(object, CodecEncoder encoder, Buffer output) {
    encoder.initialize(output);
    inspect(object, encoder);
    encoder.clear();
  }
  
  List<int> encode(object, CodecEncoder encoder) {
    globalBuffer.clear();
    encodeTo(object, encoder, globalBuffer);
    final result = globalBuffer.bytes;
    globalBuffer.clear();
    return result;
  }
  
  String stringify(object) {
    final listener = new Stringifier();
    inspect(object, listener);
    return listener.getResult();
  }
  
  void printObject(object) {
    print(stringify(object));
  }
  
  dynamic copy(object) {
    simpleBuilder.clear();
    inspect(object, simpleBuilder);
    return simpleBuilder.getResult();
  }
}
