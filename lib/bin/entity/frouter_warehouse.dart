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

  // Cache provider
  Map<String, Map<String, FRouterProviderBuilder>> providers = {};

  // Cache interceptor
  List<FRouterIntercept> interceptors = [];

  static FRouterWareHouse fromRouterMap(FRouterRouterMap routerMap) {
    FRouterWareHouse wareHouse = FRouterWareHouse();

    routerMap.subModule.forEach((element) {
      final subWareHouse = FRouterWareHouse.fromRouterMap(element);
      wareHouse.subGroups[element.currentRouterGroup] = subWareHouse;
    });

    wareHouse.currentGroup = routerMap.currentRouterGroup;

    routerMap.routerMap.keys.forEach((path) {
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
          widgetBuilder: routerMap.routerMap[path],
        );
      }
    });

    routerMap.providerMap.keys.forEach((path) {
      final pathUri = Uri.tryParse(path);
      if (pathUri != null && pathUri.pathSegments.length >= 2) {
        final groupKey = pathUri.pathSegments[0];
        final routerProvider = routerMap.providerMap[path];
        if (routerProvider != null) {
          if (wareHouse.providers[groupKey] == null) {
            wareHouse.providers[groupKey] = {};
          }
          wareHouse.providers[groupKey]![path] = routerProvider;
        }
      }
    });

    wareHouse.interceptors.addAll(routerMap.interceptList);

    wareHouse = _addAllFromSubGroup(wareHouse);

    return wareHouse;
  }

  static FRouterWareHouse _addAllFromSubGroup(
      FRouterWareHouse targetWareHouse) {
    targetWareHouse.subGroups.values.forEach((subGroup) {
      subGroup.routers.keys.forEach((groupKey) {
        subGroup.routers[groupKey]?.keys.forEach((pathKey) {
          if (targetWareHouse.routers[groupKey] == null) {
            targetWareHouse.routers[groupKey] = {};
          }
          if (subGroup.routers[groupKey] == null) {
            subGroup.routers[groupKey] = {};
          }
          targetWareHouse.routers[groupKey]![pathKey] =
              subGroup.routers[groupKey]![pathKey]!;
        });
      });

      subGroup.providers.keys.forEach((groupKey) {
        subGroup.providers[groupKey]?.keys.forEach((pathKey) {
          final routerProvider = subGroup.providers[groupKey]![pathKey];
          if (routerProvider != null) {
            if (targetWareHouse.providers[groupKey] == null) {
              targetWareHouse.providers[groupKey] = {};
            }
            targetWareHouse.providers[groupKey]![pathKey] = routerProvider;
          }
        });
      });

      targetWareHouse.interceptors.addAll(subGroup.interceptors);
    });

    return targetWareHouse;
  }

  void clear() {
    subGroups.clear();
    routers.clear();
    providers.clear();
    interceptors.clear();
  }
}
