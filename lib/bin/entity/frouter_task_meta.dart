class FRouterTaskInjectEntity {
  Function taskFunction;
  String taskIdentifier;
  String? description;
  bool isNeedAwait;
  String? tag;

  FRouterTaskInjectEntity(
      {required this.taskFunction,
      required this.taskIdentifier,
      this.description,
      this.isNeedAwait = false,
      this.tag});

  FRouterTaskInjectEntity deepCopy() {
    return FRouterTaskInjectEntity(
      taskFunction: taskFunction,
      taskIdentifier: taskIdentifier,
      description: description,
      isNeedAwait: isNeedAwait,
      tag: tag,
    );
  }
}

class FRouterNormalTaskEntity extends FRouterTaskInjectEntity {
  FRouterNormalTaskEntity({
    required Function taskFunction,
    required String taskIdentifier,
    String? description,
    bool isAsync = false,
    String? tag,
  }) : super(
          taskFunction: taskFunction,
          taskIdentifier: taskIdentifier,
          description: description,
          isNeedAwait: isAsync,
          tag: tag,
        );

  @override
  FRouterNormalTaskEntity deepCopy() {
    return FRouterNormalTaskEntity(
      taskFunction: taskFunction,
      taskIdentifier: taskIdentifier,
      description: description,
      isAsync: isNeedAwait,
      tag: tag,
    );
  }
}

class FRouterInitTaskEntity extends FRouterTaskInjectEntity {
  String deepOnString = '';

  List<FRouterInitTaskEntity> taskDependOnList = [];
  List<FRouterInitTaskEntity> taskRelyOnList = [];

  FRouterInitTaskEntity({
    required Function taskFunction,
    required String taskIdentifier,
    required this.deepOnString,
    bool isNeedAwait = false,
    List<FRouterInitTaskEntity> taskDependOnList = const [],
    List<FRouterInitTaskEntity> taskRelyOnList = const [],
    String? description,
    String? tag,
  }) : super(
          taskFunction: taskFunction,
          taskIdentifier: taskIdentifier,
          description: description,
          isNeedAwait: isNeedAwait,
          tag: tag,
        ) {
    this.taskDependOnList = List.from(taskDependOnList);
    this.taskRelyOnList = List.from(taskRelyOnList);
  }

  int get taskInCount => taskRelyOnList.length;

  @override
  FRouterInitTaskEntity deepCopy() {
    return FRouterInitTaskEntity(
      taskFunction: taskFunction,
      taskIdentifier: taskIdentifier,
      description: description,
      isNeedAwait: isNeedAwait,
      deepOnString: '',
    )
      ..taskDependOnList = List.from(taskDependOnList.map((e) => e.deepCopy()))
      ..taskRelyOnList = List.from(taskRelyOnList.map((e) => e.deepCopy()));
  }
}
