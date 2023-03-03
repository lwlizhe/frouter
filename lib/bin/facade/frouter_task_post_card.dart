import 'package:frouter/bin/entity/frouter_task_meta.dart';

class FRouterTaskPostCard {
  FRouterTaskPostCard(this.taskIdentifier);

  String taskIdentifier;
  late final FRouterTaskInjectEntity? _taskMeta;

  Function? get taskFunction => _taskMeta?.taskFunction;

  FRouterTaskPostCard setTaskMeta(FRouterTaskInjectEntity? taskMeta) {
    _taskMeta = taskMeta;
    return this;
  }

  dynamic apply({List<dynamic> parameters = const []}) {
    if (taskFunction != null) {
      return Function.apply(taskFunction!, parameters);
    }
  }
}
