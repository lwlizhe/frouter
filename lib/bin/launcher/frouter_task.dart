import 'dart:async';

import 'package:frouter/bin/core/frouter_flow_task_center.dart';
import 'package:frouter/bin/entity/frouter_router_task.dart';
import 'package:frouter/bin/entity/frouter_task_meta.dart';
import 'package:frouter/bin/facade/frouter_task_post_card.dart';
import 'package:frouter/bin/helper/task_sort_util.dart';

class FRouterTask {
  FRouterTask._internal();

  factory FRouterTask() => _instance;

  static late final FRouterTask _instance = FRouterTask._internal();

  FRouterFlowTaskCenter logisticsCenter = FRouterFlowTaskCenter();

  FRouterTask init(FRouterFlowTask flowTask) {
    logisticsCenter.registerTask(flowTask);
    return this;
  }

  FRouterTaskPostCard? loadTaskMeta(String taskIdentifier) {
    return logisticsCenter.loadTaskMeta(taskIdentifier);
  }

  Future startInitTask() async {
    final List<FRouterInitTaskEntity> initTaskList = logisticsCenter
        .initTaskMap.values
        .whereType<FRouterInitTaskEntity>()
        .toList();

    List<FRouterInitTaskEntity> graphList =
        FRouterTaskHelper.buildTaskGraph(initTaskList);

    List<FRouterInitTaskEntity> sortList =
        FRouterTaskHelper.sortTaskGraph(graphList);

    Future.forEach<FRouterInitTaskEntity>(sortList, (meta) async {
      if (meta.isNeedAwait) {
        await Function.apply(meta.taskFunction, []);
      } else {
        unawaited(Function.apply(meta.taskFunction, []));
      }
    });
  }
}
