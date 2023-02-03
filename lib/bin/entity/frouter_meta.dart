import 'package:flutter/material.dart';
import 'package:frouter/bin/builder/frouter_widget_builder.dart';

class FRouterMeta {
  FRouterType type;
  String path; // Path of route
  String group; // Group of route
  FRouterWidgetBuilder? widgetBuilder; // Widget of route
  int priority = -1; // The smaller the number, the higher the priority
  int? extra; // Extra data
  Map<String, int>? paramsType; // Param type
  String? name;

  FRouterMeta({
    required this.path,
    required this.group,
    this.widgetBuilder,
    this.name,
    this.priority = -1,
    this.extra,
    this.paramsType,
    this.type = FRouterType.unKnow,
  });
}

enum FRouterType { widget, provider, unKnow }
