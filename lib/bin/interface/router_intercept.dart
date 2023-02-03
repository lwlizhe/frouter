import 'package:flutter/material.dart';
import 'package:frouter/bin/entity/frouter_meta.dart';

abstract class FRouterIntercept extends FRouterProvider {}

abstract class FRouterProvider {
  void init(BuildContext context);
}

abstract class IRouteGroup {
  /// Fill the atlas with routes in group.
  void loadInto(Map<String, FRouterMeta> atlas);
}