part of ormicida.codec;

class SchemaId {
  final List<int> bytes;
  
  const SchemaId(this.bytes);
  
  operator ==(other) =>
      other is SchemaId && equalBytes(bytes, other.bytes);
  
  String toBase64() => Base64.encodeToString(bytes);
  
  String toString() => 'SchemaId(${toBase64()})';
}
