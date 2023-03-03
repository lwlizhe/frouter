import 'package:frouter/annotation/task/frouter_flow_task_annotation.dart';
import 'package:get/get.dart';

@FlowTask()
class Base {
  @FlowTaskInject(
      taskIdentifier: 'base_init',
      dependOn: 'base_permission',
      isInitTask: true,
      isNeedAwait: true)
  static Function baseInit = () async {
    Get.snackbar('Base Module', 'Base Module Init');
  };

  @FlowTaskInject(
      taskIdentifier: 'base_permission',
      dependOn: '',
      isInitTask: true,
      isNeedAwait: true)
  static Function basePermission = () async {
    Get.snackbar('Base Module', 'Base Module Permission');
  };
}
