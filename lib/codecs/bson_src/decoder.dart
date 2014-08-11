part of ormicida.codecs.bson;

class BsonDecoder implements CodecDecoder {
  CodecListener       _listener;
  Buffer              _input;
  final StringBuffer  _buffer = new StringBuffer();
  
  BsonDecoder();
  
  void clear() {
    _listener = null;
    _input = null;
    _buffer.clear();
  }
  
  void decodeTo(Buffer input, CodecListener listener) {
    clear();
    _input = input;
    _listener = listener;
    input.setLittleEndian();
    
    _readObject();
  }
  
  void _readObject() {
    final end = _input.position + _input.getUint32();
    _listener.onMapStart();
    
    while (true) {
      final type = _input.getByte();
      if (type == 0) break;
      
      final buffer = _buffer;
      buffer.clear();
      while (true) {
        final code = _input.getByte();
        if (code == 0) break;
        buffer.writeCharCode(code);
      }
      _listener.onPropertyStart(buffer.toString());
      buffer.clear();
      _readValue(type);
      _listener.onPropertyEnd();
    }
    
    _listener.onMapEnd();
  }
  
  void _readValue(int type) {
    final input = _input;
    
    switch(type) {
      case _STRING:
        final lengthInBytes = input.getUint32();
        final buffer = _buffer;
        buffer.clear();
        while (true) {
          final code = input.getCharCode();
          if (code == 0) break;
          buffer.writeCharCode(code);
        }
        _listener.onValue(buffer.toString());
        buffer.clear();
        break;
        
      case _OBJECT_ID:
        _listener.onValue(new SchemaId(input.getBytes(12)));
        break;
        
      case _OBJECT:
        _readObject();
        break;
        
      case _ARRAY:
        final length = input.getUint32();
        _listener.onListStart();
        
        while (true) {
          final type = input.getByte();
          if (type == 0) break;
          
          // Skip index
          while (true) {
            final code = input.getByte();
            if (code == 0) break;
          }
          
          _readValue(type);
          _listener.onListElement();
        }
        
        _listener.onListEnd();
        break;
        
      case _INT32:
        _listener.onValue(input.getInt32());
        break;
        
      case _INT64:
        _listener.onValue(input.getInt64());
        break;
        
      case _NULL:
        _listener.onValue(null);
        break;
        
      case _BOOLEAN:
        _listener.onValue(input.getByte() > 0);
        break;
        
      case _FLOAT:
        _listener.onValue(input.getFloat64());
        break;
        
      case _DATE_TIME:
        _listener.onValue(
            new DateTime.fromMillisecondsSinceEpoch(
                input.getInt64()));
        break;
        
      case _BINARY:
        final length = input.getUint32();
        final binaryType = input.getByte();
        _listener.onValue(input.getBytes(length));
        break;
        
      case _REGEXP:
        final buffer = _buffer;
        buffer.clear();
        while (true) {
          final code = input.getByte();
          if (code == 0) break;
          buffer.writeCharCode(code);
        }
        final pattern = buffer.toString();
        buffer.clear();
        
        bool isCaseSensitive = true;
        bool isMultiLine = false;
        while (true) {
          final code = input.getByte();
          if (code == 0) break;
          switch (code) {
            case _CHAR_i:
              isCaseSensitive = false;
              break;
            case _CHAR_m:
              isMultiLine = true;
              break;
          }
        }
        
        _listener.onValue(new RegExp(pattern,
            caseSensitive: isCaseSensitive,
            multiLine: isMultiLine));
        break;
        
      case _TIMESTAMP:
        _listener.onValue(input.getUint64());
        break;
        
      default:
        throw new UnimplementedError('Unimplemented BSON type: 0x${type.toRadixString(16)}');
    }
  }
}
