// Generated by lwlizhe frouter plugin, do not edit manually.
// run pub run build_runner build --delete-conflicting-outputs
// ignore_for_file: directives_ordering
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:frouter/bin/entity/frouter_router_map.dart' as _i1;
import 'package:module_a/module_a_route.dart' as _i2;
import 'package:frouter/bin/builder/frouter_widget_builder.dart' as _i3;
import 'package:module_b/module_b_route_export.dart' as _i4;
import 'package:frouter/bin/helper/safety_parameter_transform_utils.dart'
    as _i5;
import 'package:flutter/src/foundation/key.dart' as _i6;

class FRouterMap extends _i1.FRouterRouterMap {
  @override
  String get hostRouterGroup {
    return 'example';
  }

  @override
  String get currentRouterGroup {
    return 'example';
  }

  @override
  List<_i1.FRouterRouterMap> get subModule {
    return [
      _i2.FModuleRouterMap(),
    ];
  }

  @override
  Map<String, _i3.FRouterWidgetBuilder> get routerMap {
    return <String, _i3.FRouterWidgetBuilder>{
      'package:module_b/page/post_info_page.dart:PostInfoPage':
          (Map<String, String>? parameters) {
        return _i4.PostInfoPage(
          _i5.transform<List<String>>(parameters?['postTitleList'])
              as List<String>,
          key: _i5.transform<_i6.Key?>(parameters?['key']) as _i6.Key?,
        );
      },
    };
  }

  @override
  Map<String, String> get routerMapBundle {
    return <String, String>{
      'post/post_info':
          'package:module_b/page/post_info_page.dart:PostInfoPage',
    };
  }

  @override
  Map<String, _i3.FRouterProviderBuilder> get providerMap {
    return <String, _i3.FRouterProviderBuilder>{};
  }

  @override
  Map<String, String> get providerBundle {
    return <String, String>{};
  }
}
