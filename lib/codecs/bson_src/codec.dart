part of ormicida.codecs.bson;

final BsonCodec bson = new BsonCodec();

class BsonCodec extends SchemaCodec {
  final CodecDecoder decoder = new BsonDecoder();
  final CodecEncoder encoder = new BsonEncoder();
}
