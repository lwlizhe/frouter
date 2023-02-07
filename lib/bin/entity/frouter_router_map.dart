import 'package:frouter/bin/builder/frouter_widget_builder.dart';
import 'package:frouter/bin/interface/router_intercept.dart';

class FRouterRouterMap {
  String hostRouterGroup = '';
  String currentRouterGroup = '';

  List<FRouterRouterMap> subModule = [];

  Map<String, FRouterWidgetBuilder> routerMap = {};
  Map<String,String> routerMapBundle = {};

  Map<String, FRouterProviderBuilder> providerMap = {};
  Map<String,String> providerBundle = {};

  List<FRouterIntercept> interceptList = [];

  FRouterRouterMap({
    this.hostRouterGroup = '',
    this.currentRouterGroup = '',
    this.subModule = const [],
    this.routerMap = const {},
    this.providerMap = const {},
    this.interceptList = const [],
  });

}
