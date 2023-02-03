import 'dart:convert';

typedef FRouterTransformProxy = dynamic Function(String parametersString);

T? transform<T extends Object?>(dynamic target,
    [T? defaultValue, FRouterTransformProxy? proxy]) {
  if (target is T) {
    return target;
  }

  if (target != null) {
    try {
      final String valueString = target.toString();
      switch (T.runtimeType) {
        case String:
          return valueString as T;
        case int:
          return int.parse(valueString) as T;
        case double:
          return double.parse(valueString) as T;
        case bool:
          return (valueString == '1' || valueString == 'true') as T;
        case List:
        case Map:
          return json.decode(valueString) as T;
        default:
          return proxy?.call(valueString) ?? defaultValue;
      }
    } catch (e, stackTrace) {
      print('asT<$T> error : $e , stackTrace : $stackTrace');
      return defaultValue;
    }
  }

  return defaultValue;
}
