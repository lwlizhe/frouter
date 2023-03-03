import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:code_builder/code_builder.dart';
import 'package:frouter/entity/entity.dart';

class GeneratorTaskUtil {
  static StringSink getTaskContent(
      {required PackageGraph packageGraph,
      required PostProcessBuildStep buildStep,
      required Map<String, List<TaskContentEntity>> sourceMap}) {
    bool isRoot = buildStep.inputId.package == packageGraph.root.name;

    final routerMapClass = Class((b) {
      b
        ..name = 'FRouterFlowTask'
        ..extend = refer('FRouterFlowTask',
            'package:frouter/bin/entity/frouter_router_task.dart')
        ..methods.addAll(
            getMatchFunctionList(isRoot, packageGraph, buildStep, sourceMap));
    });

    final library = Library((b) => b.body.add(routerMapClass));

    final emitter = DartEmitter(
        allocator: Allocator.simplePrefixing(), useNullSafetySyntax: true);
    return library.accept(emitter);
  }

  static List<Method> getMatchFunctionList(
      bool isRoot,
      PackageGraph packageGraph,
      PostProcessBuildStep buildStep,
      Map<String, List<TaskContentEntity>> sourceMap) {
    return [
      Method((methodBuilder) {
        methodBuilder
          ..name = 'taskBundleMap'
          ..annotations.add(refer('override'))
          ..type = MethodType.getter
          ..returns = TypeReference((b) => b
            ..symbol = 'Map'
            ..types.addAll([
              refer('String'),
              refer('String'),
            ]))
          ..body = Block((b) {
            b.statements.addAll([
              const Code('return <String,String>{'),
              ...(sourceMap[buildStep.inputId.package] ?? [])
                  .expand((element) => [
                        Code(
                            '\'${(element.annotation.objectValue.getField('taskIdentifier')?.toStringValue() ?? '')}\':'),
                        Code(
                            '\'${'${element.element.source?.uri.toString() ?? ''}:${element.element.displayName}'}\','),
                      ]),
              const Code('};'),
            ]);
          });
      }),
      buildTaskSubModuleMethod(isRoot, packageGraph, buildStep, sourceMap),
      buildTaskMapMethod(sourceMap[buildStep.inputId.package] ?? []),
    ];
  }

  static Method buildTaskSubModuleMethod(
      bool isRoot,
      PackageGraph packageGraph,
      PostProcessBuildStep buildStep,
      Map<String, List<TaskContentEntity>> sourceMap) {
    List<PackageNode> sourceModuleList = packageGraph
            .allPackages[buildStep.inputId.package]?.dependencies
            .where((element) => sourceMap.containsKey(element.name))
            .map((e) => e)
            .toList() ??
        [];

    return Method((methodBuilder) {
      methodBuilder
        ..name = 'subTaskModule'
        ..annotations.add(refer('override'))
        ..type = MethodType.getter
        ..returns = TypeReference((b) => b
          ..symbol = 'List'
          ..types.addAll([
            refer('FRouterFlowTask',
                'package:frouter/bin/entity/frouter_router_task.dart'),
          ]))
        ..body = Block((b) {
          b.statements.addAll([
            const Code('return ['),
            ...sourceModuleList.map((e) => refer('FRouterFlowTask(),',
                    'package:${e.name}/${e.name}_task.dart')
                .code),
            // ...sourceList.expand((element) => [
            //       Code(
            //           '\'${(element.annotation.objectValue.getField('taskIdentifier')?.toStringValue() ?? '')}\':'),
            //       Code(
            //           '\'${'${element.element.source?.uri.toString() ?? ''}:${element.element.displayName}'}\','),
            //     ]),
            const Code('];'),
          ]);
        });
    });
  }

  static Method buildTaskMapMethod(List<TaskContentEntity> sourceList) {
    Code buildInitTaskCode(TaskContentEntity entity) {
      return refer('FRouterInitTaskEntity',
              'package:frouter/bin/entity/frouter_task_meta.dart')
          .newInstance([], {
        'taskFunction': refer(
            '${entity.element.enclosingElement3?.name ?? ''}.${entity.element.name ?? ''}',
            AssetId(entity.buildStep.inputId.package,
                    'lib/${entity.buildStep.inputId.package}_route_export.dart')
                .uri
                .toString()),
        'taskIdentifier': literalString(entity.annotation.objectValue
                .getField('taskIdentifier')
                ?.toStringValue() ??
            ''),
        'deepOnString': literalString(entity.annotation.objectValue
                .getField('dependOn')
                ?.toStringValue() ??
            ''),
        'isNeedAwait': literalBool(entity.annotation.objectValue
                .getField('isNeedAwait')
                ?.toBoolValue() ??
            false),
      }, []).code;
    }

    Code buildNormalTaskCode(TaskContentEntity entity) {
      return refer('FRouterNormalTaskEntity',
              'package:frouter/bin/entity/frouter_task_meta.dart')
          .newInstance([], {
        'taskFunction': refer(
            '${entity.element.enclosingElement3?.name ?? ''}.${entity.element.name ?? ''}',
            AssetId(entity.buildStep.inputId.package,
                    'lib/${entity.buildStep.inputId.package}_route_export.dart')
                .uri
                .toString()),
        'taskIdentifier': literalString(entity.annotation.objectValue
                .getField('taskIdentifier')
                ?.toStringValue() ??
            ''),
      }, []).code;
    }

    return Method((methodBuilder) {
      methodBuilder
        ..name = 'taskMap'
        ..annotations.add(refer('override'))
        ..type = MethodType.getter
        ..returns = TypeReference((b) => b
          ..symbol = 'Map'
          ..types.addAll([
            refer('String'),
            refer('FRouterTaskInjectEntity',
                'package:frouter/bin/entity/frouter_task_meta.dart'),
          ]))
        ..body = Block((b) {
          b.statements.addAll([
            const Code('return <String,'),
            refer('FRouterTaskInjectEntity',
                    'package:frouter/bin/entity/frouter_task_meta.dart')
                .code,
            const Code('>{'),
            ...sourceList.expand((element) {
              bool isInitTask = element.annotation.objectValue
                      .getField('isInitTask')
                      ?.toBoolValue() ??
                  false;
              return [
                Code(
                    '\'${'${element.element.source?.uri.toString() ?? ''}:${element.element.displayName}'}\':'),
                isInitTask
                    ? buildInitTaskCode(element)
                    : buildNormalTaskCode(element),
                const Code(',')
              ];
            }),
            const Code('};'),
          ]);
        });
    });
  }
}
