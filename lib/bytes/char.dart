library ormicida.bytes.char;

class Char {
  static const BACKSLASH        = 0x5c;
  static const BACKSPACE        = 0x08;
  static const CARRIAGE_RETURN  = 0x0d;
  static const CHAR_0           = 0x30;
  static const CHAR_9           = 0x39;
  static const CHAR_A           = 0x41;
  static const CHAR_F           = 0x46;
  static const CHAR_I           = 0x49;
  static const CHAR_N           = 0x4e;
  static const CHAR_T           = 0x54;
  static const CHAR_U           = 0x55;
  static const CHAR_Z           = 0x5A;
  static const CHAR_a           = 0x61;
  static const CHAR_b           = 0x62;
  static const CHAR_e           = 0x65;
  static const CHAR_f           = 0x66;
  static const CHAR_i           = 0x69;
  static const CHAR_l           = 0x6c;
  static const CHAR_n           = 0x6e;
  static const CHAR_r           = 0x72;
  static const CHAR_s           = 0x73;
  static const CHAR_t           = 0x74;
  static const CHAR_u           = 0x75;
  static const CHAR_z           = 0x7A;
  static const COLON            = 0x3a;
  static const COMMA            = 0x2c;
  static const POINT            = 0x2e;
  static const FORM_FEED        = 0x0c;
  static const LEFT_BRACE       = 0x7b;
  static const EQUAL            = 0x3D;
  static const LEFT_BRACKET     = 0x5b;
  static const MINUS            = 0x2d;
  static const NEWLINE          = 0x0a;
  static const PLUS             = 0x2b;
  static const QUOTE            = 0x22;
  static const RIGHT_BRACE      = 0x7d;
  static const RIGHT_BRACKET    = 0x5d;
  static const SLASH            = 0x2f;
  static const SPACE            = 0x20;
  static const TAB              = 0x09;
  static const UNDERSCORE       = 0x5F;
  
  static bool isWhite(int code) =>
      code == SPACE || code == CARRIAGE_RETURN ||
      code == NEWLINE || code == TAB;
  
  static bool isAlpha(int code) =>
      (code >= CHAR_a && code <= CHAR_z)
      || (code >= CHAR_A && code <= CHAR_Z);
  
  static bool isDigit(int code) =>
      code >= CHAR_0 && code <= CHAR_9;
  
  static bool isAlphaOrDigit(int code) =>
      isAlpha(code) || isDigit(code);
  
  static bool isHex(int code) =>
      isDigit(code)
      || (code >= CHAR_a && code <= CHAR_f)
      || (code >= CHAR_A && code <= CHAR_F);
  
  static int toHex(int value) =>
      value >= 10
          ? (CHAR_A - 10) + value
          : CHAR_0 + value;
  
  static int fromHex(int code) =>
    code >= CHAR_a
        ? code - (CHAR_a - 10)
        : code >= CHAR_A
            ? code - (CHAR_A - 10)
            : code - CHAR_0;
}