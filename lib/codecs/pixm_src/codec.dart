part of ormicida.codecs.pixm;

final PixmCodec pixm = new PixmCodec();

class PixmCodec extends SchemaCodec {
  final CodecDecoder decoder = new PixmDecoder();
  final CodecEncoder encoder = new PixmEncoder();
}
