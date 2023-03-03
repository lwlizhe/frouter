import 'package:flutter/material.dart';
import 'package:frouter/bin/interface/router_intercept.dart';

abstract class BaseCartProvider extends FRouterProvider {
  @override
  void init(BuildContext context);

  bool addProductsToCart(List<String> products);
}