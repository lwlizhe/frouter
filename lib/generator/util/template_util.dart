import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:code_builder/code_builder.dart';
import 'package:frouter/entity/entity.dart';

class GeneratorTemplateUtil {
  static StringSink getTemplate(
      {required PackageGraph packageGraph,
      required PostProcessBuildStep buildStep,
      required Map<String, List<BuildScriptItemContentEntity>> sourceMap}) {
    bool isRoot = buildStep.inputId.package == packageGraph.root.name;

    final routerMapClass = Class((b) {
      b
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
        ]);

      final List<BuildScriptItemContentEntity> routerSourceList = [];
      final List<BuildScriptItemContentEntity> providerSourceList = [];

      for (var routerItem in (sourceMap[buildStep.inputId.package] ?? [])) {
        if (routerItem.element is ClassElement) {
          final supportList =
              ((routerItem.element as ClassElement).allSupertypes);

          if (supportList
              .where((element) =>
                  'Widget' == element.getDisplayString(withNullability: true))
              .isNotEmpty) {
            routerSourceList.add(routerItem);
          } else if (supportList
              .where((element) =>
                  'FRouterProvider' ==
                  element.getDisplayString(withNullability: true))
              .isNotEmpty) {
            providerSourceList.add(routerItem);
          }
        }
      }

      b.methods.add(_RouterBuilder.buildRouterMapMethod(routerSourceList));
      b.methods
          .add(_RouterBuilder.buildRouterMapBundleMethod(routerSourceList));

      b.methods
          .add(_ProviderBuilder.buildProviderMapMethod(providerSourceList));
      b.methods.add(
          _ProviderBuilder.buildProviderMapBundleMethod(providerSourceList));
    });

    final library = Library((b) => b.body.add(routerMapClass));

    final emitter = DartEmitter(
        allocator: Allocator.simplePrefixing(), useNullSafetySyntax: true);
    return library.accept(emitter);
  }

  static Method _rootGroupGetMethod(PackageGraph packageGraph,
          Map<String, List<BuildScriptItemContentEntity>> sourceMap) =>
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
          Map<String, List<BuildScriptItemContentEntity>> sourceMap) =>
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
}

class _BuilderHelper {

  static List<Code> _buildElementConstructorParameterCodeList(ConstructorElement constructor) {
    List<Code> codeList = [];

    List<Code> buildNormalCodeList(ParameterElement parameter) {
      List<Code> result = [];
      String parameterKey = parameter.name;
      String parameterName = parameter.name;
      String parameterType = parameter.type.element2?.name ?? '';
      String parameterTypeWithNullable =
          parameter.type.getDisplayString(withNullability: true);
      String parameterUrl =
          parameter.type.element2?.enclosingElement3?.source?.uri.toString() ??
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
      String parameterUrl =
          parameter.type.element2?.enclosingElement3?.source?.uri.toString() ??
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

  static List<Code> _buildParameterCodeList(
      BuildScriptItemContentEntity routerItem) {
    // buildParameterString

    // todo: 目前的原则：能跑就行～～ 罗永浩抽象图.jpg
    return [
      Code(
          '\'${'${routerItem.element.source?.uri.toString() ?? ''}:${routerItem.element.displayName}'}\':'),
      Code('('),
      Code('Map<String,List<String>>? parameters) {'),
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
      ..._buildElementConstructorParameterCodeList(
          (routerItem.element as ClassElement).constructors.first),
      Code(');'),
      Code('},'),
    ];
  }
}

class _RouterBuilder {
  static const String _routerMapSymbol = 'FRouterWidgetBuilder';
  static const String _routerMapSymbolUrl =
      'package:frouter/bin/builder/frouter_widget_builder.dart';

  static Method buildRouterMapMethod(
      List<BuildScriptItemContentEntity> sourceList) {
    return Method((methodBuilder) {
      methodBuilder
        ..name = 'routerMap'
        ..annotations.add(refer('override'))
        ..type = MethodType.getter
        ..returns = TypeReference((b) => b
          ..symbol = 'Map'
          ..types.addAll([
            refer('String'),
            TypeReference((b) => b
              ..symbol = _routerMapSymbol
              ..url = _routerMapSymbolUrl
              ..isNullable = false),
          ]))
        ..body = Block((b) {
          b.statements.addAll([
            const Code('return <String,'),
            refer(_routerMapSymbol, _routerMapSymbolUrl).code,
            const Code('>{'),
            ...sourceList
                .expand((element) =>
                    _BuilderHelper._buildParameterCodeList(element))
                .toList(),
            const Code('};'),
          ]);
        });
    });
  }

  static Method buildRouterMapBundleMethod(
      List<BuildScriptItemContentEntity> sourceList) {
    return Method((methodBuilder) {
      methodBuilder
        ..name = 'routerMapBundle'
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
            ...sourceList.expand((element) => [
                  Code(
                      '\'${(element.annotation.objectValue.getField('pathUri')?.toStringValue() ?? '')}\':'),
                  Code(
                      '\'${'${element.element.source?.uri.toString() ?? ''}:${element.element.displayName}'}\','),
                ]),
            const Code('};'),
          ]);
        });
    });
  }
}

class _ProviderBuilder {
  static const String _routerMapSymbol = 'FRouterProviderBuilder';
  static const String _routerMapSymbolUrl =
      'package:frouter/bin/builder/frouter_widget_builder.dart';

  static Method buildProviderMapMethod(
      List<BuildScriptItemContentEntity> sourceList) {
    return Method((methodBuilder) {
      methodBuilder
        ..name = 'providerMap'
        ..annotations.add(refer('override'))
        ..type = MethodType.getter
        ..returns = TypeReference((b) => b
          ..symbol = 'Map'
          ..types.addAll([
            refer('String'),
            TypeReference((b) => b
              ..symbol = _routerMapSymbol
              ..url = _routerMapSymbolUrl
              ..isNullable = false),
          ]))
        ..body = Block((b) {
          b.statements.addAll([
            const Code('return <String,'),
            refer(_routerMapSymbol, _routerMapSymbolUrl).code,
            const Code('>{'),
            ...sourceList
                .expand((element) =>
                    _BuilderHelper._buildParameterCodeList(element))
                .toList(),
            const Code('};'),
          ]);
        });
    });
  }

  static Method buildProviderMapBundleMethod(
      List<BuildScriptItemContentEntity> sourceList) {
    return Method((methodBuilder) {
      methodBuilder
        ..name = 'providerBundle'
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
            ...sourceList.expand((element) => [
                  Code(
                      '\'${(element.annotation.objectValue.getField('pathUri')?.toStringValue() ?? '')}\':'),
                  Code(
                      '\'${'${element.element.source?.uri.toString() ?? ''}:${element.element.displayName}'}\','),
                ]),
            const Code('};'),
          ]);
        });
    });
  }
}
