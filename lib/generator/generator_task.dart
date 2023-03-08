import 'package:analyzer/dart/constant/value.dart';
import 'package:build/build.dart';
import 'package:frouter/annotation/task/frouter_flow_task_annotation.dart';
import 'package:frouter/entity/entity.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

class TaskGenerator extends GeneratorForAnnotation<FlowTask> {
  static Map<String, BuildScriptItemContentEntity> registerTaskMap = {};

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is ClassElement) {
      for (var fieldElement in element.fields) {
        if (fieldElement.isStatic) {
          List<DartObject> objectList =
              const TypeChecker.fromRuntime(FlowTaskInject)
                  .annotationsOfExact(fieldElement)
                  .toList();
          for (var element in objectList) {
            final currentEntity = BuildScriptItemContentEntity(
                fieldElement, ConstantReader(element), buildStep);
            registerTaskMap[ConstantReader(element)
                    .objectValue
                    .getField('taskIdentifier')
                    ?.toStringValue() ??
                ''] = currentEntity;
          }
        }
      }
    }
  }
}
