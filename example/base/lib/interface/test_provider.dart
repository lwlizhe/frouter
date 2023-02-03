import 'package:flutter/material.dart';
import 'package:frouter/bin/interface/router_intercept.dart';

abstract class TestProvider extends FRouterProvider {
  @override
  void init(BuildContext context);

  void sayHello();
}