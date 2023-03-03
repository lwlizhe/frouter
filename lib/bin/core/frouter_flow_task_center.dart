import 'package:frouter/bin/entity/frouter_router_task.dart';
import 'package:frouter/bin/entity/frouter_task_meta.dart';
import 'package:frouter/bin/facade/frouter_task_post_card.dart';

const String tagBeforeInitialization = "TAG_BEFORE_INITIALIZATION";
const String tagAfterInitialization = "TAG_AFTER_INITIALIZATION";

class FRouterFlowTaskCenter {
  Map<String, FRouterInitTaskEntity> initTaskMap = {};
  Map<String, FRouterNormalTaskEntity> normalTaskMap = {};

  Map<String, String> taskMapBundle = {};

  FRouterFlowTaskCenter registerTask(FRouterFlowTask flowTask) {
    if (flowTask.subTaskModule.isNotEmpty) {
      for (var element in flowTask.subTaskModule) {
        final subTask = registerTask(element);
        initTaskMap.addAll(subTask.initTaskMap);
        taskMapBundle.addAll(subTask.taskMapBundle);
      }
    }

    flowTask.taskMap.forEach((key, value) {
      if (value is FRouterInitTaskEntity) {
        initTaskMap[key] = value;
      } else if (value is FRouterNormalTaskEntity) {
        normalTaskMap[key] = value;
      }
    });

    taskMapBundle.addAll(flowTask.taskBundleMap);

    return this;
  }

  void updateTaskBundle(Map<String, String> taskBundleMap) {
    taskMapBundle = taskBundleMap;
  }

  FRouterTaskPostCard? loadTaskMeta(String taskIdentifier) {
    if (taskMapBundle.containsKey(taskIdentifier)) {
      return FRouterTaskPostCard(taskIdentifier)
        ..setTaskMeta(normalTaskMap[taskMapBundle[taskIdentifier]]);
    }

    return null;
  }

  List<FRouterTaskInjectEntity> loadTaskMetaByTag(String tag) {
    return normalTaskMap.values.where((element) => element.tag == tag).toList();
  }
}
