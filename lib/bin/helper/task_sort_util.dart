import 'package:frouter/annotation/task/frouter_flow_task_annotation.dart';
import 'package:frouter/bin/entity/frouter_task_meta.dart';
import 'package:collection/collection.dart';

class FRouterTaskHelper {
  /// 构建任务图
  static List<FRouterInitTaskEntity> buildTaskGraph(
      List<FRouterInitTaskEntity> sourceList) {
    Map<String, FRouterInitTaskEntity> sourceMap =
        <String, FRouterInitTaskEntity>{};
    Map<String, FRouterInitTaskEntity> metaMap =
        <String, FRouterInitTaskEntity>{};

    List<FRouterInitTaskEntity> result = [];

    for (FRouterInitTaskEntity taskInjectEntity in sourceList) {
      sourceMap[taskInjectEntity.taskIdentifier] = taskInjectEntity;
    }

    /// 实体类转换为图
    FRouterInitTaskEntity entityToGraph(
        FRouterInitTaskEntity taskInjectEntity) {
      FRouterInitTaskEntity targetMeta;
      if (metaMap.containsKey(taskInjectEntity.taskIdentifier)) {
        targetMeta = metaMap[taskInjectEntity.taskIdentifier]!;
        return targetMeta;
      } else {
        targetMeta = (metaMap[taskInjectEntity.taskIdentifier] =
            FRouterInitTaskEntity(
              isNeedAwait: taskInjectEntity.isNeedAwait,
                taskFunction: taskInjectEntity.taskFunction,
                taskIdentifier: taskInjectEntity.taskIdentifier,
                description: taskInjectEntity.description,
                deepOnString: taskInjectEntity.deepOnString));
      }

      final List<String> dependList = taskInjectEntity.deepOnString.split(',');

      for (String dependName in dependList) {
        if (dependName.isEmpty) {
          continue;
        }
        if (sourceMap.containsKey(dependName)) {
          final dependMeta = entityToGraph(sourceMap[dependName]!);
          targetMeta.taskDependOnList.add(dependMeta);
          dependMeta.taskRelyOnList.add(targetMeta);
        }
      }

      return targetMeta;
    }

    for (FRouterInitTaskEntity taskInjectEntity in sourceList) {
      final meta = entityToGraph(taskInjectEntity);
      result.add(meta);
    }

    return result;
  }

  /// 拓扑排序(kahn的出度方法)
  static List<FRouterInitTaskEntity> sortTaskGraph(
      List<FRouterInitTaskEntity> tasks) {
    List<FRouterInitTaskEntity> result = [];

    Map<String, FRouterInitTaskEntity> taskMap =
        <String, FRouterInitTaskEntity>{};
    QueueList<FRouterInitTaskEntity> zeroOutTaskQueue =
        QueueList<FRouterInitTaskEntity>();

    for (FRouterInitTaskEntity taskMeta in tasks) {
      if (taskMeta.taskDependOnList.isEmpty) {
        zeroOutTaskQueue.add(taskMeta);
      }

      taskMap[taskMeta.taskIdentifier] = taskMeta;
    }

    /// 不断将出度为0的节点移除，同时将其依赖的节点的出度减1，如果减1后入度为0，则加入队列
    while (zeroOutTaskQueue.isNotEmpty) {
      FRouterInitTaskEntity taskMeta = zeroOutTaskQueue.removeFirst();
      result.add(taskMeta);

      for (FRouterInitTaskEntity relyMeta in taskMeta.taskRelyOnList) {
        relyMeta.taskDependOnList.remove(taskMeta);
        if (relyMeta.taskDependOnList.isEmpty) {
          zeroOutTaskQueue.addLast(relyMeta);
        }
      }
    }

    /// 如果最后还有节点，说明有环
    if (result.length != tasks.length) {
      throw Exception('task graph has cycle');
    }

    return result;
  }
}
