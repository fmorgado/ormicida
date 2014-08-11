part of ormicida.orm.schema;

class IsString extends IsDynamic {
  final int           minLen;
  final int           maxLen;
  final RegExp        pattern;
  final List<String>  options;
  
  const IsString({this.minLen, this.maxLen,
          this.pattern, this.options, bool nullable: false})
      : super(nullable);
  
  Map _getLengthArgument() {
    final result = {};
    if (minLen != null) result['minLen'] = minLen;
    if (maxLen != null) result['maxLen'] = maxLen;
    return result;
  }
  
  Object normalizeAndValidate(value) {
    if (value is! String) {
      throw new SchemaException(SchemaException.NOT_A_STRING);
    } else if (minLen != null && value.length < minLen) {
      throw new SchemaException(SchemaException.STRING_TOO_SHORT, _getLengthArgument());
    } else if (maxLen != null && value.length > maxLen) {
      throw new SchemaException(SchemaException.STRING_TOO_LONG, _getLengthArgument());
    } else if (options != null) {
      final index = options.indexOf(value);
      if (index < 0)
        throw new SchemaException(SchemaException.NOT_AN_OPTION);
      // Keep constant value instead
      return options[index];
    } else if (pattern != null && !pattern.hasMatch(value)) {
      throw new SchemaException(SchemaException.INVALID_FORMAT);
    }
    return value;
  }
}
