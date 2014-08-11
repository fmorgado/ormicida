part of ormicida.codecs.json;

const _MAP_TYPE_PROPERTY = r'$type';

final JsonCodec json = new JsonCodec();

class JsonCodec extends SchemaCodec {
  final CodecDecoder decoder = new JsonDecoder();
  final CodecEncoder encoder = new JsonEncoder();
  
  String encodeToString(object) => UTF8.decode(encode(object));
}
