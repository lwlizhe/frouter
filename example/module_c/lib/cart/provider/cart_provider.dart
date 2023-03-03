import 'package:base/base_route_export.dart';
import 'package:flutter/material.dart';
import 'package:frouter/annotation/router.dart';
import 'package:base/const/base_const_value.dart';
import 'package:get/get.dart';

class CartProvider extends BaseCartProvider {
  @override
  bool addProductsToCart(List<String> products) {
    return true;
  }

  @override
  void init(BuildContext context) {}
}

@RouterPath(pathUri: CommonValue.providerLiveCart)
class LiveCartProvider extends CartProvider {
  @override
  bool addProductsToCart(List<String> products) {
    Get.snackbar('直播往购物车塞入的商品', '假装调用Get.find，往Controller中加入了这些商品:\n${products.join('\n')}');
    return true;
  }
}

@RouterPath(pathUri: 'cart/PostCartProvider')
class PostCartProvider extends CartProvider {
  @override
  bool addProductsToCart(List<String> products) {
    Get.snackbar('直播往购物车塞入的商品', '假装调用Get.find，往Controller中加入了这些商品:\n ${products.join('\n')}');

    return true;
  }
}
