import 'package:flutter/material.dart';
import 'package:frouter/bin/builder/frouter_widget_builder.dart';
import 'package:frouter/bin/entity/frouter_meta.dart';
import 'package:frouter/bin/entity/frouter_warehouse.dart';
import 'package:frouter/bin/interface/router_intercept.dart';
import 'package:frouter/bin/launcher/frouter.dart';

class FRouterPostCard<D> extends FRouterMeta {
  // Base
  Uri? uri;
  Object? tag; // A tag prepare for some thing wrong. inner params, DO NOT USE!
  D? data; // Data to transform
  int flags = 0; // Flags of route
  int timeout = 300; // Navigation timeout, TimeUnit.Second
  bool greenChannel = false;
  String action = '';

  FRouterProviderBuilder?
      providerBuilder; // It will be set value, if this postcard was provider.

  // Animation
  int enterAnim = -1;
  int exitAnim = -1;

  FRouterPostCard({
    required String path,
    required String group,
    FRouterWidgetBuilder? widgetBuilder,
  }) : super(path: path, group: group, widgetBuilder: widgetBuilder){
    uri = Uri.tryParse(path);
  }

  /// Navigation to the route with path in postcard.
  Object? navigation(BuildContext context) {
    return FRouter().navigation(
      context,
      this,
    );
  }
}
