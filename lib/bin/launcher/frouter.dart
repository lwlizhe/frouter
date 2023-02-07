import 'package:frouter/bin/core/frouter_logistics_center.dart';
import 'package:frouter/bin/entity/frouter_router_map.dart';
import 'package:frouter/bin/facade/frouter_post_card.dart';

class FRouter {
  FRouter._internal();

  factory FRouter() => _instance;

  static late final FRouter _instance = FRouter._internal();

  LogisticsCenter logisticsCenter = LogisticsCenter();

  void init(FRouterRouterMap routerMap) {
    logisticsCenter.init(routerMap);
  }

  void updateBundle(String bundleJson) {
    logisticsCenter.updateBundle(bundleJson);
  }

  FRouterPostCard build(String path) {
    if (path.isEmpty) {
      throw new Exception("Parameter is invalid!");
    } else {
      // todo : ARouter 里面有个用路由注入的单例，专门在这里用来替换path的，可以加
      return buildForGroup(path, _extractGroup(path), true);
    }
  }

  FRouterPostCard buildForGroup(String path, String extractGroup, bool bool) {
    return FRouterPostCard(group: extractGroup, path: path);
  }

  Object? navigation(FRouterPostCard postCard) {
    return logisticsCenter.navigation(postCard);
  }

  /// Extract the default group from path.
  String _extractGroup(String path) {
    if (path.isEmpty) {
      throw Exception(
          "Extract the default group failed, the path must be start with '/' and contain more than 2 '/'!");
    }

    final uri = Uri.tryParse(path);

    if ((uri?.pathSegments.length ?? 0) >= 2) {
      return uri?.pathSegments[0] ?? '';
    }

    return '';
  }
}
