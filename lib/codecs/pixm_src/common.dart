part of ormicida.codecs.pixm;

/// The mask used to retrieve the type.
const _TYPE_MASK                = 0xE0;   // 111x xxxx

/// Map or List. See [_COMPLEX_*] values.
const _COMPLEX                  = 0x00;   // 000x xxxx
/// The value is a constant. See [_CONSTANT_*] values.
const _CONSTANT                 = 0x20;   // 001x xxxx
const _STRING                   = 0x40;   // 010x xxxx
const _INTEGER_TINY             = 0x60;   // 011x xxxx
const _INTEGER_HUGE             = 0x80;   // 100x xxxx
const _FLOAT                    = 0xA0;   // 101x xxxx
const _BINARY                   = 0xC0;   // 110x xxxx
const _OTHER                    = 0xE0;   // 111x xxxx

const _CONSTANT_MASK            = 0x0F;   // xxxx 1111
const _CONSTANT_NULL            = 0x00;   // xxxx 0000
const _CONSTANT_FALSE           = 0x01;   // xxxx 0001
const _CONSTANT_TRUE            = 0x02;   // xxxx 0010
const _CONSTANT_NAN             = 0x03;   // xxxx 0011
const _CONSTANT_INF             = 0x04;   // xxxx 0100
const _CONSTANT_NEG_INF         = 0x05;   // xxxx 0101
const _CONSTANT_ZERO            = 0x06;   // xxxx 0110

const _INTEGER_NEGATIVE_BIT     = 0x10;   // xxx1 xxxx
const _INTEGER_TINY_MASK        = 0x0F;   // xxxx 1111
const _INTEGER_TINY_LENGTH      = 0x08;   // xxxx 1xxx
const _INTEGER_TINY_LENGTH_MASK = 0x07;   // xxxx x111

const _STRING_TINY_LENGTH_BIT   = 0x10;   // xxx1 xxxx
const _STRING_TINY_LENGTH_MASK  = 0x0F;   // xxxx 1111

const _FLOAT_SIZE_MASK          = 0x0F;   // xxxx 1111
const _FLOAT_SIZE_32            = 0x00;   // xxxx 0000
const _FLOAT_SIZE_64            = 0x01;   // xxxx 0001

const _BINARY_LENGTH_TINY       = 0x10;   // xxx1 xxxx
const _BINARY_LENGTH_MASK       = 0x0F;   // xxxx 1111

const _OTHER_NEGATIVE           = 0x10;   // xxx1 xxxx
const _OTHER_MASK               = 0x0F;   // xxxx 1111
const _OTHER_DATE               = 0x00;   // xxxx 0000
const _OTHER_DURATION           = 0x01;   // xxxx 0001
const _OTHER_ID                 = 0x02;   // xxxx 0010
const _OTHER_REG_EXP            = 0x03;   // xxxx 0011

const _COMPLEX_DICT_MASK        = 0x18;   // xxx1 1xxx
const _COMPLEX_DICT_NONE        = 0x00;   // xxx0 0xxx
const _COMPLEX_DICT_STRING      = 0x08;   // xxx0 1xxx
const _COMPLEX_DICT_INDEX       = 0x10;   // xxx1 0xxx

const _COMPLEX_TYPE_MASK        = 0x07;   // xxxx x111
const _COMPLEX_MAP_START        = 0x00;   // xxxx x000
const _COMPLEX_MAP_END          = 0x01;   // xxxx x001
const _COMPLEX_PROPERTY         = 0x02;   // xxxx x010
const _COMPLEX_LIST_START       = 0x03;   // xxxx x011
const _COMPLEX_LIST_END         = 0x04;   // xxxx x100
