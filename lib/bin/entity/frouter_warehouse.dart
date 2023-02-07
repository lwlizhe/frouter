import 'dart:convert';
import 'dart:core';

import 'package:frouter/bin/builder/frouter_widget_builder.dart';
import 'package:frouter/bin/entity/frouter_meta.dart';
import 'package:frouter/bin/entity/frouter_router_map.dart';
import 'package:frouter/bin/interface/router_intercept.dart';

class FRouterWareHouse {
  String currentGroup = '';

  Map<String, FRouterWareHouse> subGroups = {};

  // Cache route and metas
  Map<String, Map<String, FRouterMeta>> routers = {};
  Map<String, String> routerMapBundle = {};

  // Cache provider
  Map<String, Map<String, FRouterProviderBuilder>> providers = {};
  Map<String, String> providerBundle = {};

  // Cache interceptor
  List<FRouterIntercept> interceptors = [];


  static FRouterWareHouse fromRouterMap(FRouterRouterMap routerMap) {
    FRouterWareHouse wareHouse = FRouterWareHouse();

    for (var element in routerMap.subModule) {
      final subWareHouse = FRouterWareHouse.fromRouterMap(element);
      wareHouse.subGroups[element.currentRouterGroup] = subWareHouse;
    }

    wareHouse.currentGroup = routerMap.currentRouterGroup;

    for (var path in routerMap.routerMapBundle.keys) {
      final pathUri = Uri.tryParse(path);
      if (pathUri != null && pathUri.pathSegments.length >= 2) {
        final groupKey = pathUri.pathSegments[0];
        if (wareHouse.routers[groupKey] == null) {
          wareHouse.routers[groupKey] = {};
        }

        wareHouse.routers[groupKey]![path] = FRouterMeta(
          path: path,
          group: groupKey,
          type: FRouterType.widget,
          widgetBuilder: routerMap.routerMap[routerMap.routerMapBundle[path]],
        );
      }
    }

    for (var path in routerMap.providerBundle.keys) {
      final pathUri = Uri.tryParse(path);
      if (pathUri != null && pathUri.pathSegments.length >= 2) {
        final groupKey = pathUri.pathSegments[0];
        final routerProvider =
        routerMap.providerMap[routerMap.routerMapBundle[path]];
        if (routerProvider != null) {
          if (wareHouse.providers[groupKey] == null) {
            wareHouse.providers[groupKey] = {};
          }
          wareHouse.providers[groupKey]![path] = routerProvider;
        }
      }
    }

    wareHouse.interceptors.addAll(routerMap.interceptList);

    wareHouse.routerMapBundle.addAll(routerMap.routerMapBundle);
    wareHouse.providerBundle.addAll(routerMap.providerBundle);


    wareHouse = _addAllFromSubGroup(wareHouse);

    return wareHouse;
  }

  void updateFromRouterBundle(String routerBundleJsonString) {
    Map<String, String> newRouterBundle = json.decode(routerBundleJsonString);
    routerMapBundle = Map.from(newRouterBundle);
  }

  static FRouterWareHouse _addAllFromSubGroup(
      FRouterWareHouse targetWareHouse) {
    for (var subGroup in targetWareHouse.subGroups.values) {
      for (var groupKey in subGroup.routers.keys) {
        for (var pathKey in subGroup.routers[groupKey]?.keys ?? <String>[]) {
          if (targetWareHouse.routers[groupKey] == null) {
            targetWareHouse.routers[groupKey] = {};
          }
          if (subGroup.routers[groupKey] == null) {
            subGroup.routers[groupKey] = {};
          }
          targetWareHouse.routers[groupKey]![pathKey] =
          subGroup.routers[groupKey]![pathKey]!;
        }
      }

      for (var groupKey in subGroup.providers.keys) {
        for (var pathKey
        in (subGroup.providers[groupKey]?.keys ?? <String>[])) {
          final routerProvider = subGroup.providers[groupKey]![pathKey];
          if (routerProvider != null) {
            if (targetWareHouse.providers[groupKey] == null) {
              targetWareHouse.providers[groupKey] = {};
            }
            targetWareHouse.providers[groupKey]![pathKey] = routerProvider;
          }
        }
      }

      targetWareHouse.interceptors.addAll(subGroup.interceptors);

      targetWareHouse.routerMapBundle.addAll(subGroup.routerMapBundle);
      targetWareHouse.providerBundle.addAll(subGroup.providerBundle);
    }

    return targetWareHouse;
  }

  void clear() {
    subGroups.clear();
    routers.clear();
    providers.clear();
    interceptors.clear();
  }
}
