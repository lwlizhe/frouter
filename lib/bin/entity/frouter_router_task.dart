import 'package:frouter/bin/entity/frouter_task_meta.dart';

class FRouterFlowTask {

  List<FRouterFlowTask> subTaskModule = [];

  Map<String, String> taskBundleMap = {};

  Map<String, FRouterTaskInjectEntity> taskMap = {};

  FRouterFlowTask();
}
