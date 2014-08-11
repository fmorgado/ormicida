part of ormicida.orm.schema;

class SchemaException {
  static const NOT_NULLABLE         = 'schema.notNullable';
  static const NOT_EQUAL            = 'schema.notEqual';
  static const NOT_A_BOOLEAN        = 'schema.notBool';
  static const NOT_AN_INTEGER       = 'schema.notInt';
  static const NOT_A_DURATION       = 'schema.notDuration';
  static const NOT_AN_ID            = 'schema.notId';
  static const NOT_A_NUMBER         = 'schema.notNum';
  static const NOT_A_STRING         = 'schema.notString';
  static const NOT_A_MAP            = 'schema.notMap';
  static const STRING_TOO_SHORT     = 'schema.stringTooShort';
  static const STRING_TOO_LONG      = 'schema.stringTooLong';
  static const NOT_AN_OPTION        = 'schema.notAnOption';
  static const INVALID_FORMAT       = 'schema.invalidFormat';
  static const NAN_NOT_ALLOWED      = 'schema.isNaN';
  static const INF_NOT_ALLOWED      = 'schema.isInf';
  static const NEG_INF_NOT_ALLOWED  = 'schema.isNegInf';
  static const NOT_HIGHER_EQUAL     = 'schema.notHigherEqual';
  static const NOT_LOWER_EQUAL      = 'schema.notLowerEqual';
  static const NOT_HIGHER_THAN      = 'schema.notHigherThan';
  static const NOT_LOWER_THAN       = 'schema.notLowerThan';
  static const NOT_A_DATE           = 'schema.notDate';
  static const INVALID_DATE_FORMAT  = 'schema.notInvalidDateFormat';
  static const DATE_OUT_OF_BOUNDS   = 'schema.outOfBoundsDate';
  static const NOT_A_LIST           = 'schema.notList';
  static const NOT_TYPED            = 'schema.notTyped';
  static const LIST_TOO_SHORT       = 'schema.listTooShort';
  static const LIST_TOO_LONG        = 'schema.listTooLong';
  static const NOT_AN_OBJECT        = 'schema.notObject';
  static const INVALID_FIELD        = 'schema.invalidField';
  static const DUPLICATED_FIELD     = 'schema.duplicatedField';
  static const MISSING_FIELD        = 'schema.missingField';
  /// The alias is not supported by the union.
  static const UNSUPPORTED_ALIAS    = 'schema.unsupportedAlias';
  /// An unexpected alias was encountered where none is expected.
  static const UNEXPECTED_ALIAS     = 'schema.unexpectedTyped';
  /// An alias was not provided where one was expected.
  static const ALIAS_EXPECTED       = 'schema.aliasExpected';
  
  final String  code;
  final Map     argument;
  
  SchemaException(this.code, [Map arg])
      : argument = arg != null ? arg : {};
  
  String toString() => 'SchemaException($code${argument == null ? '' : ', $argument'})';
}
