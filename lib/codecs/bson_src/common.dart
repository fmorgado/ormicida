part of ormicida.codecs.bson;

/// Bson Number 64-bits
const _FLOAT      = 0x01;
/// Bson UTF-8 String, null-terminated
const _STRING     = 0x02;
/// Bson Object
const _OBJECT     = 0x03;
/// Bson Array
const _ARRAY      = 0x04;
/// Bson Binary
const _BINARY     = 0x05;
/// Bson ObjectId, 12-bytes
const _OBJECT_ID  = 0x07;
/// Bson Boolean, 1 byte
const _BOOLEAN    = 0x08;
/// Bson DateTime, 64-bits
const _DATE_TIME  = 0x09;
/// Bson Null, void
const _NULL       = 0x0A;
/// Bson RegExp, cstring cstring
const _REGEXP     = 0x0B;
/// Bson Int32, 4 bytes
const _INT32      = 0x10;
/// Bson TimeStamp, 64-bits
const _TIMESTAMP  = 0x11;
/// Bson Int64, 8 bytes
const _INT64      = 0x12;

const _INT32_MIN  = -0x80000000;
const _INT32_MAX  = 0x7fffffff;

const _INT64_MIN  = -0x8000000000000000;
const _INT64_MAX  = 0x7fffffffffffffff;

const _UINT64_MAX = 0xFFFFFFFFFFFFFFFF;

const _CHAR_i = 105;
const _CHAR_m = 109;
