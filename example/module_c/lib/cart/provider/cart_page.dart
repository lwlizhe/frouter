import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:frouter/annotation/router.dart';
import 'package:frouter/annotation/task/frouter_flow_task_annotation.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

@FlowTask()
class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @FlowTaskInject(
      taskIdentifier: 'moduleC_init',
      dependOn: 'base_init,moduleA_init,moduleB_init',
      isInitTask: true,
      isNeedAwait: true)
  static Function moduleCInit = () async {
    Get.snackbar('ModuleB Module', 'ModuleC Module Init');
  };


  @FlowTaskInject(
      taskIdentifier: 'moduleC_permission',
      dependOn: 'moduleB_permission',
      isInitTask: true,
      isNeedAwait: true)
  static Function moduleCPermission = () async {
    Get.snackbar('ModuleC Module', 'ModuleC Module Permission');
  };

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('CartPage'),
      ),
    );
  }
}
