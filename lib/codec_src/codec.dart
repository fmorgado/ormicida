part of ormicida.codec;

/// The interface used between the various components.
/// For instance, the Json codec has a parser which feeds a
/// [SchemaListener] instance, and an encoder which implements
/// [SchemaListener] and is fed by an object inspector.
abstract class CodecListener {
  
  /// Called when a value is found.
  void onValue(value);
  
  /// Called when a reference is found.
  //void onReference(int index);
  
  /// Called to start a property.
  void onPropertyStart(String name);
  
  /// Called when the value of the current property has been set.
  void onPropertyEnd();
  
  /// Called to begin an object.
  /// [type] represents the type of the object.
  void onMapStart([String type]);
  
  /// Called to close the current object.
  void onMapEnd();
  
  /// Called to begin a list.
  void onListStart();
  
  /// Called when a list element has been set.
  void onListElement();
  
  /// Called to close the current list.
  void onListEnd();
}

abstract class CodecDecoder {
  void clear();
  void decodeTo(Buffer input, CodecListener listener);
}

abstract class CodecEncoder extends CodecListener {
  void clear();
  void initialize(Buffer output);
}

abstract class SchemaCodec {
  CodecDecoder get decoder;
  CodecEncoder get encoder;
  
  Object decodeFrom(Buffer input)
      => simpleBuilder.decodeFrom(input, decoder);
  
  Object decode(List<int> bytes)
      => simpleBuilder.decode(bytes, decoder);
  
  void encodeTo(object, Buffer output) {
    simpleInspector.encodeTo(object, encoder, output);
  }
  
  List<int> encode(object)
      => simpleInspector.encode(object, encoder);
}
