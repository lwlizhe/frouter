import 'package:frouter/annotation/task/frouter_flow_task_annotation.dart';
import 'package:frouter/bin/entity/frouter_task_meta.dart';
import 'package:frouter/bin/helper/task_sort_util.dart';

void main() {
  List<FRouterInitTaskEntity> sourceList = [
    FRouterInitTaskEntity(
      taskIdentifier: 'moduleA_request_permission',
      deepOnString: 'base_init',
      taskFunction: () {
        print('A 模块执行权限申请\n');
      },
    ),
    FRouterInitTaskEntity(
        taskIdentifier: 'moduleA_int',
        deepOnString: 'moduleA_request_permission,base_init',
        taskFunction: () {
          print('A 模块执行初始化\n');
        }),
    FRouterInitTaskEntity(
        taskIdentifier: 'moduleB_request_permission',
        deepOnString: 'base_init',
        taskFunction: () {
          print('B 模块执行权限申请\n');
        }),
    // FRouterTaskInjectEntity(
    //     taskIdentifier: 'moduleB_business_permission',
    //     dependOn: 'moduleB_int',
    //     taskFunction: () {
    //       print('B 模块执行业务初始化\n');
    //     }),
    FRouterInitTaskEntity(
        taskIdentifier: 'moduleB_int',
        deepOnString:
            'moduleB_request_permission,base_init,moduleB_business_permission',
        taskFunction: () {
          print('B 模块执行初始化\n');
        }),
    FRouterInitTaskEntity(
        taskIdentifier: 'base_init',
        deepOnString: '',
        taskFunction: () {
          print('Base 模块执行初始化\n');
        }),
    FRouterInitTaskEntity(
        taskIdentifier: 'business_init',
        deepOnString:
            'moduleA_request_permission,moduleB_request_permission,base_init',
        taskFunction: () {
          print('启动整体业务任务\n');
        }),
    FRouterInitTaskEntity(
        taskIdentifier: 'special_task',
        deepOnString: '',
        taskFunction: () {
          print('独立任务\n');
        }),
  ];

  List<FRouterInitTaskEntity> target =
      FRouterTaskHelper.buildTaskGraph(sourceList);

  List<FRouterInitTaskEntity> result = FRouterTaskHelper.sortTaskGraph(target);

  for (FRouterInitTaskEntity meta in result) {
    Function.apply(meta.taskFunction, []);
  }
}
