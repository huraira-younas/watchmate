typedef ValidatorFunction = String? Function(String? value);

class ValidatorBuilder {
  final List<ValidatorFunction> _validators = [];

  ValidatorBuilder._();

  static ValidatorBuilder chain() => ValidatorBuilder._();

  ValidatorBuilder required([String message = 'Required field']) {
    _validators.add((value) {
      if (value == null || value.trim().isEmpty) return message;
      return null;
    });
    return this;
  }

  ValidatorBuilder email([String message = 'Invalid email']) {
    final regex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
    );

    _validators.add((value) {
      if (value == null || value.isEmpty) return null;
      return regex.hasMatch(value.trim()) ? null : message;
    });
    return this;
  }

  ValidatorBuilder min(int len, [String? message]) {
    _validators.add((value) {
      if (value == null || value.isEmpty) return null;
      return value.length >= len
          ? null
          : (message ?? 'Minimum $len characters');
    });
    return this;
  }

  ValidatorBuilder max(int len, [String? message]) {
    _validators.add((value) {
      if (value == null || value.isEmpty) return null;
      return value.length <= len
          ? null
          : (message ?? 'Maximum $len characters');
    });
    return this;
  }

  ValidatorBuilder length(int len, [String? message]) {
    _validators.add((value) {
      if (value == null || value.isEmpty) return null;
      return value.length == len
          ? null
          : (message ?? 'Must be $len characters');
    });
    return this;
  }

  ValidatorBuilder matches(
    RegExp pattern, [
    String message = 'Invalid format',
  ]) {
    _validators.add((value) {
      if (value == null || value.isEmpty) return null;
      return pattern.hasMatch(value) ? null : message;
    });
    return this;
  }

  ValidatorBuilder oneOf(
    String? Function() other, [
    String message = 'Values must match',
  ]) {
    _validators.add((value) {
      if (value == null || other() == null) return null;
      return value == other() ? null : message;
    });
    return this;
  }

  ValidatorBuilder custom(ValidatorFunction fn) {
    _validators.add(fn);
    return this;
  }

  ValidatorFunction build() {
    return (value) {
      for (final validator in _validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
