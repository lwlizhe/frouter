import 'dart:convert';

typedef FRouterTransformProxy = dynamic Function(String parametersString);

T? transform<T extends Object?>(List<dynamic>? target,
    [T? defaultValue, FRouterTransformProxy? proxy]) {
  if (target is T) {
    return target as T;
  }

  if (target != null && target.isNotEmpty) {
    try {
      switch (T) {
        case String:
          return target.first as T;
        case int:
          return int.parse(target.first.toString()) as T;
        case double:
          return double.parse(target.first.toString()) as T;
        case bool:
          return (target.first.toString() == '1' ||
              target.first.toString() == 'true') as T;
        case List:
        case Map:
          return json.decode(target.toString()) as T;
        default:
          return proxy?.call(target.toString()) ?? defaultValue;
      }
    } catch (e, stackTrace) {
      print('asT<$T> error : $e , stackTrace : $stackTrace');
      return defaultValue;
    }
  }

  return defaultValue;
}
