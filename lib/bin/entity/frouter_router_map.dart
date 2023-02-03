import 'package:flutter/material.dart';
import 'package:frouter/bin/builder/frouter_widget_builder.dart';
import 'package:frouter/bin/interface/router_intercept.dart';
import 'package:flutter/material.dart';
import 'package:frouter/bin/interface/router_intercept.dart';

abstract class FRouterRouterMap {
  String hostRouterGroup = '';
  String currentRouterGroup = '';

  List<FRouterRouterMap> subModule = [];

  Map<String, FRouterWidgetBuilder> routerMap = {};

  Map<String, FRouterProviderBuilder> providerMap = {};

  List<FRouterIntercept> interceptList = [];
}
