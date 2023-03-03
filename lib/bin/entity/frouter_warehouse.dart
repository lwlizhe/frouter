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
  Map<String, FRouterMeta> routers = {};
  Map<String, String> routerMapBundle = {};

  // Cache provider
  Map<String, FRouterProviderBuilder> providers = {};
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

    for (var bundleKey in routerMap.routerMapBundle.keys) {
      final pathUri = Uri.tryParse(bundleKey);
      final bundleValue = routerMap.routerMapBundle[bundleKey] ?? '';
      if (pathUri != null && pathUri.pathSegments.length >= 2) {
        final groupKey = pathUri.pathSegments[0];

        wareHouse.routers[bundleValue] = FRouterMeta(
          path: bundleValue,
          group: groupKey,
          type: FRouterType.widget,
          widgetBuilder: routerMap.routerMap[bundleValue],
        );
      }
    }

    for (var bundleKey in routerMap.providerBundle.keys) {
      final pathUri = Uri.tryParse(bundleKey);
      final bundleValue = routerMap.providerBundle[bundleKey] ?? '';
      if (pathUri != null && pathUri.pathSegments.length >= 2) {
        final routerProvider = routerMap.providerMap[bundleValue];
        if (routerProvider != null) {
          wareHouse.providers[bundleValue] = routerProvider;
        }
      }
    }

    wareHouse.routerMapBundle.addAll(routerMap.routerMapBundle);
    wareHouse.providerBundle.addAll(routerMap.providerBundle);

    wareHouse = _addAllFromSubGroup(wareHouse);

    return wareHouse;
  }

  void updateFromRouterBundle(String routerBundleJsonString) {
    final newRouterBundle = json.decode(routerBundleJsonString);
    newRouterBundle.keys.forEach((currentBundleKey) {
      final currentBundleValue = newRouterBundle[currentBundleKey];
      final originalBundleValue = routerMapBundle[currentBundleKey];
      if (currentBundleValue != originalBundleValue) {
        routerMapBundle[currentBundleKey] = currentBundleValue;
      }
    });
  }

  static FRouterWareHouse _addAllFromSubGroup(
      FRouterWareHouse targetWareHouse) {
    for (var subGroup in targetWareHouse.subGroups.values) {
      for (var bundleValue in subGroup.routers.keys) {
        if (subGroup.routers[bundleValue] != null) {
          targetWareHouse.routers[bundleValue] = subGroup.routers[bundleValue]!;
        }
      }

      for (var bundleValue in subGroup.providers.keys) {
        final routerProvider = subGroup.providers[bundleValue];
        if (routerProvider != null) {
          targetWareHouse.providers[bundleValue] = routerProvider;
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
