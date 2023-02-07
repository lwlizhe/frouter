import 'package:flutter/material.dart';
import 'package:frouter/bin/interface/router_intercept.dart';

typedef FRouterWidgetBuilder = Widget Function(Map<String, String>? parameters);

typedef FRouterProviderBuilder = FRouterProvider Function(Map<String, String>? parameters);
