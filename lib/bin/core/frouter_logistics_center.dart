import 'package:flutter/material.dart';
import 'package:frouter/bin/entity/frouter_meta.dart';
import 'package:frouter/bin/entity/frouter_router_map.dart';
import 'package:frouter/bin/facade/frouter_post_card.dart';
import 'package:frouter/bin/entity/frouter_warehouse.dart';

class LogisticsCenter {
  FRouterWareHouse routerWareHouse = FRouterWareHouse();

  final emptyWidget = Scaffold(
    appBar: AppBar(),
    body: const Center(
      child: Text('not find page'),
    ),
  );

  FRouterWareHouse init(FRouterRouterMap routerMap) {
    routerWareHouse = FRouterWareHouse.fromRouterMap(routerMap);
    return routerWareHouse;
  }

  void updateBundle(String routerJsonString) async {
    routerWareHouse.updateFromRouterBundle(routerJsonString);
  }

  FRouterPostCard getTarget(
      FRouterPostCard targetPostCard, FRouterWareHouse wareHouse) {
    final findRouter = wareHouse.routers[wareHouse.routerMapBundle[targetPostCard.uri?.path]];
    if (findRouter != null) {
      targetPostCard.widgetBuilder = findRouter.widgetBuilder;
      targetPostCard.type = findRouter.type;

      return targetPostCard;
    }

    final findProviderBuilder = wareHouse.providers[wareHouse.providerBundle[targetPostCard.path]];

    if (findProviderBuilder != null) {
      targetPostCard.providerBuilder = findProviderBuilder;
      targetPostCard.type = FRouterType.provider;

      return targetPostCard;
    }
    // switch (targetPostCard.type) {
    //   case FRouterType.widget:
    //     if (null != findRouter && findRouter.type == targetPostCard.type) {
    //       targetPostCard.widget = findRouter.widget;
    //     }
    //     break;
    //   case FRouterType.provider:
    //     final findProviderBuilder =
    //         wareHouse.providers[targetPostCard.group]?[targetPostCard.path];
    //     if (null != findProviderBuilder) {
    //       targetPostCard.provider =
    //           wareHouse.providers[targetPostCard.group]![targetPostCard.path];
    //     }
    //     break;
    //   case FRouterType.unKnow:
    //     // throw Exception('unKnow path , please check the config !');
    //     break;
    // }

    /// todo : 降级策略；
    return FRouterPostCard(
      path: '',
      group: '',
      widgetBuilder: (parameters) {
        return emptyWidget;
      },
    );
  }

  dynamic navigation(FRouterPostCard postCard) {
    final targetPostCard = getTarget(postCard, routerWareHouse);
    switch (targetPostCard.type) {
      case FRouterType.widget:
        return postCard.widgetBuilder?.call({
          ...(postCard.uri?.queryParametersAll ?? {}),
        });
      case FRouterType.provider:
        return postCard.providerBuilder?.call({
          ...(postCard.uri?.queryParametersAll ?? {}),
        });
      case FRouterType.unKnow:
      default:
        return emptyWidget;
    }
  }
}
