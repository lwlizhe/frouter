class FlowTask {
  const FlowTask();
}

class FlowTaskInject {
  final String taskIdentifier;
  final String description;
  final String dependOn;
  final bool isNeedAwait;
  final bool isInitTask;

  const FlowTaskInject(
      {required this.taskIdentifier,
      this.dependOn = '',
      this.description = '',
      this.isNeedAwait = false,
      this.isInitTask = false});
}
