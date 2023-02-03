import 'dart:ffi';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:code_builder/code_builder.dart';
import 'package:frouter/annotation/router.dart';
import 'package:frouter/entity/entity.dart';

class GeneratorTemplateUtil {
  static StringSink getTemplate(
      {required PackageGraph packageGraph,
      required PostProcessBuildStep buildStep,
      required Map<String, List<RouterItemScriptContentEntity>> sourceMap}) {
    bool isRoot = buildStep.inputId.package == packageGraph.root.name;

    final routerMapClass = Class((b) => b
      ..name = isRoot ? 'FRouterMap' : 'FModuleRouterMap'
      ..extend = refer('FRouterRouterMap',
          'package:frouter/bin/entity/frouter_router_map.dart')
      ..methods.addAll([
        _buildWareHouseGroupInfoMethod(
            'hostRouterGroup', packageGraph.root.name),
        _buildWareHouseGroupInfoMethod(
            'currentRouterGroup', buildStep.inputId.package),

        isRoot
            ? _rootGroupGetMethod(packageGraph, sourceMap)
            : _subGroupGetMethod(packageGraph, buildStep, sourceMap),

        _buildWareHouseRouterMapMethod(
            buildStep,
            sourceMap,
            'routerMap',
            'FRouterWidgetBuilder',
            'package:frouter/bin/builder/frouter_widget_builder.dart',
            'Widget'),
        _buildWareHouseRouterMapMethod(
            buildStep,
            sourceMap,
            'providerMap',
            'FRouterProviderBuilder',
            'package:frouter/bin/builder/frouter_widget_builder.dart',
            'FRouterProvider'),

        /// todo: 拦截器部分，暂时懒得做了
        // if(isRoot) _buildLogicCenter(),
      ]));

    final library = Library((b) => b.body.add(routerMapClass));

    final emitter = DartEmitter(
        allocator: Allocator.simplePrefixing(), useNullSafetySyntax: true);
    return library.accept(emitter);
  }

  static Method _rootGroupGetMethod(PackageGraph packageGraph,
          Map<String, List<RouterItemScriptContentEntity>> sourceMap) =>
      Method((methodBuilder) {
        methodBuilder
          ..name = 'subModule'
          ..type = MethodType.getter
          ..annotations.add(refer('override'))
          ..returns = TypeReference(
            (b) => b
              ..symbol = 'List'
              ..types.addAll(
                [
                  refer('FRouterRouterMap',
                      'package:frouter/bin/entity/frouter_router_map.dart'),
                ],
              ),
          )
          ..body = Block((b) => b
            ..statements.addAll([
              Code('return ['),
              ...packageGraph.root.dependencies
                  .where((element) => sourceMap.keys.contains(element.name))
                  .map((e) => refer('FModuleRouterMap(),',
                          'package:${e.name}/${e.name}_route.dart')
                      .code),
              Code('];'),
            ]));
      });

  static Method _subGroupGetMethod(
          PackageGraph packageGraph,
          PostProcessBuildStep currentBuildStep,
          Map<String, List<RouterItemScriptContentEntity>> sourceMap) =>
      Method((methodBuilder) {
        methodBuilder
          ..name = 'subModule'
          ..type = MethodType.getter
          ..annotations.add(refer('override'))
          ..returns = TypeReference(
            (b) => b
              ..symbol = 'List'
              ..types.addAll(
                [
                  refer('FRouterRouterMap',
                      'package:frouter/bin/entity/frouter_router_map.dart'),
                ],
              ),
          )
          ..body = Block((b) => b
            ..statements.addAll([
              Code('return ['),
              ...packageGraph.root.dependencies
                  .firstWhere((element) =>
                      currentBuildStep.inputId.package == element.name)
                  .dependencies
                  .where((element) => sourceMap.keys.contains(element.name))
                  .map((e) => refer('FRouterRouterMap(),',
                          'package:${e.name}/${e.name}_route.dart')
                      .code),
              Code('];'),
            ]));
      });

  static List<Code> _buildParameterCodeList(
      RouterItemScriptContentEntity routerItem) {
    // buildParameterString

    List<Code> buildParameterCodeList(ConstructorElement constructor) {
      List<Code> codeList = [];

      List<Code> buildNormalCodeList(ParameterElement parameter) {
        List<Code> result = [];
        String parameterKey = parameter.name;
        String parameterName = parameter.name;
        String parameterType = parameter.type.element2?.name ?? '';
        String parameterTypeWithNullable = parameter.type.getDisplayString(withNullability: true);
        String parameterUrl = parameter
                .type.element2?.enclosingElement3?.source?.uri
                .toString() ??
            '';
        final requestParameterList = parameter.metadata.where((element) =>
            element.element?.source?.uri.toString() ==
                'package:frouter/annotation/request/request_annotation.dart' &&
            element.element?.displayName == 'RequestParam');
        if (requestParameterList.isNotEmpty) {
          parameterName = requestParameterList.first
                  .computeConstantValue()
                  ?.getField('parameterName')
                  ?.toStringValue() ??
              parameterName;
        }

        Code parameterReferCode = refer(parameterTypeWithNullable).code;

        if (parameterType != "String" &&
            parameterType != "int" &&
            parameterType != "double" &&
            parameterType != "bool" &&
            parameterType != "List" &&
            parameterType != "Map" &&
            parameterType != "dynamic") {
          parameterReferCode =
              refer(parameterTypeWithNullable, parameterUrl).code;
        }

        List<Code> normalCodeBuilderList = [
          refer('transform<',
                  'package:frouter/bin/helper/safety_parameter_transform_utils.dart')
              .code,
          parameterReferCode,
          Code('>(parameters?[\'$parameterName\'])'),
          const Code(' as '),
          parameterReferCode,
          const Code(',')
        ];

        if (parameter.isRequiredPositional) {
          result.addAll(normalCodeBuilderList);
        } else if (parameter.isNamed) {
          result.add(Code('$parameterKey:'));
          result.addAll(normalCodeBuilderList);
        }

        return result;
      }

      List<Code> buildRequestBodyCodeList(ParameterElement parameter) {
        List<Code> result = [];
        String parameterType =
            parameter.type.getDisplayString(withNullability: false);
        String parameterUrl = parameter
                .type.element2?.enclosingElement3?.source?.uri
                .toString() ??
            '';
        ConstructorElement? requestBodyConstructor =
            (parameter.type.element2 as ClassElement?)?.constructors.first;

        result.add(refer(parameterType, parameterUrl).code);
        result.add(Code('('));
        result.addAll(requestBodyConstructor?.parameters
                .expand((element) => buildNormalCodeList(element)) ??
            []);
        result.add(Code('),'));

        return result;
      }

      for (ParameterElement parameter in constructor.parameters) {
        // String parameterKey = parameter.name;
        // String parameterType =
        //     parameter.type.getDisplayString(withNullability: true);
        // String parameterUrl = parameter
        //         .type.element2?.enclosingElement3?.source?.uri
        //         .toString() ??
        //     '';

        if (parameter.metadata.any((element) =>
            element.element?.source?.uri.toString() ==
                'package:frouter/annotation/request/request_annotation.dart' &&
            element.element?.name == 'requestBody')) {
          if (parameter.isNamed) {
            codeList.add(Code('${parameter.name}:'));
          }
          codeList.addAll(buildRequestBodyCodeList(parameter));
        } else {
          codeList.addAll(buildNormalCodeList(parameter));
        }
      }

      return codeList;
    }

    // todo: 目前的原则：能跑就行～～ 罗永浩抽象图.jpg
    return [
      Code(
          '\'${(routerItem.annotation.objectValue.getField('pathUri')?.toStringValue() ?? '')}\':'),
      Code('('),
      refer('BuildContext', 'package:flutter/material.dart').code,
      Code(' context,Map<String,String>? parameters) {'),
      Code('return '),
      refer(
              (routerItem.element as ClassElement)
                  .constructors
                  .first
                  .returnType
                  .toString(),
              AssetId(routerItem.buildStep.inputId.package,
                      'lib/${routerItem.buildStep.inputId.package}_route_export.dart')
                  .uri
                  .toString())
          .code,
      Code('('),
      ...buildParameterCodeList(
          (routerItem.element as ClassElement).constructors.first),
      Code(');'),
      Code('},'),
    ];
  }

  static Method _buildWareHouseGroupInfoMethod(
      String methodName, String methodContent) {
    return Method((methodBuilder) {
      methodBuilder
        ..name = methodName
        ..annotations.add(refer('override'))
        ..type = MethodType.getter
        // ..requiredParameters.add(Parameter((b) => b
        //   ..name = parameterName
        //   ..type = refer('String')))
        ..returns = refer('String')
        ..body = Block((b) {
          b.statements.addAll([
            Code('return \'$methodContent\';'),
          ]);
        });
    });
  }

  static Method _buildWareHouseRouterMapMethod(
      PostProcessBuildStep buildStep,
      Map<String, List<RouterItemScriptContentEntity>> sourceMap,
      String methodName,
      String parameterType,
      String parameterUrl,
      String filterType) {
    final contentList =
        (sourceMap[buildStep.inputId.package] ?? []).expand((routerItem) {
      if (routerItem.element is ClassElement &&
          ((routerItem.element as ClassElement)
              .allSupertypes
              .where((element) =>
                  filterType == element.getDisplayString(withNullability: true))
              .isNotEmpty)) {
        return _buildParameterCodeList(routerItem);
      } else {
        return [];
      }
    });

    return Method((methodBuilder) {
      methodBuilder
        ..name = methodName
        ..annotations.add(refer('override'))
        ..type = MethodType.getter
        // ..requiredParameters.add(Parameter((b) => b
        //   ..name = parameterName
        //   ..type = refer('String')))
        ..returns = TypeReference((b) => b
          ..symbol = 'Map'
          ..types.addAll([
            refer('String'),
            TypeReference((b) => b
              ..symbol = parameterType
              ..url = parameterUrl
              ..isNullable = false),
          ]))
        ..body = Block((b) {
          b.statements.addAll([
            Code('return <'),
            refer(
              'String',
            ).code,
            Code(','),
            refer(parameterType, parameterUrl).code,
            Code('>{'),
          ]);

          if (contentList.isNotEmpty) {
            b.statements.addAll([
              ...contentList,
            ]);
          }

          b.statements.add(Code('};'));
        });
    });
  }

  static Field _interceptField() => Field(
        (b) => b
          ..name = 'interceptList'
          ..type = TypeReference((b) => b
            ..symbol = 'List'
            ..types.add(TypeReference((b) => b
              ..symbol = 'FRouterIntercept'
              ..url = 'package:frouter/bin/interface/router_intercept.dart'
              ..isNullable = false)))
          ..assignment = Block.of([
            Code('['),
            Code(']'),
          ]),
      );

  /// A method forwarding to `run`.
  Method _main() => Method((b) => b
    ..name = 'main'
    ..returns = refer('void')
    ..modifier = MethodModifier.async
    ..requiredParameters.add(Parameter((b) => b
      ..name = 'args'
      ..type = TypeReference((b) => b
        ..symbol = 'List'
        ..types.add(refer('String')))))
    ..optionalParameters.add(Parameter((b) => b
      ..name = 'sendPort'
      ..type = TypeReference((b) => b
        ..symbol = 'SendPort'
        ..url = 'dart:isolate'
        ..isNullable = true)))
    ..body = Block.of([
      refer('run', 'package:build_runner/build_runner.dart')
          .call([refer('args'), refer('_builders')])
          .awaited
          .assignVar('result')
          .statement,
      refer('sendPort')
          .nullSafeProperty('send')
          .call([refer('result')]).statement,
      refer('exitCode', 'dart:io').assign(refer('result')).statement,
    ]));
}
