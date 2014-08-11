library ormicida.bytes.utils;

bool equalBytes(List<int> bytes1, List<int> bytes2) {
  final length = bytes1.length;
  if (length != bytes2.length) return false;
  for (var index = 0; index < length; index++) {
    if (bytes1[index] != bytes2[index]) return false;
  }
  return true;
}
