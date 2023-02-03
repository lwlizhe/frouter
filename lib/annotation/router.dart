import 'package:frouter/bin/entity/frouter_parameter.dart';

class RouterPath {
  final String pathUri;
  final Type? binding;
  final FRouterCustomParameterInterface? customParameterType;

  const RouterPath({required this.pathUri,this.binding,this.customParameterType});
}
