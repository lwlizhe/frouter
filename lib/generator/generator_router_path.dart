import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:frouter/annotation/router.dart';
import 'package:frouter/entity/entity.dart';

import 'package:source_gen/source_gen.dart';

class RouterPathGenerator extends GeneratorForAnnotation<RouterPath> {
  static Map<String, List<BuildScriptItemContentEntity>>
      currentRegisterModuleMap = {};

  static PackageGraph? packageGraph;

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    packageGraph ??= await PackageGraph.forThisPackage();
    checkRouterMap(element, annotation, buildStep);
  }

  void checkRouterMap(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final packageType = buildStep.inputId.uri.scheme;
    var fileModule = buildStep.inputId.pathSegments.first;

    if (packageType == 'package') {
      fileModule = buildStep.inputId.package;
    }

    final currentList = (currentRegisterModuleMap[fileModule] ??= []);

    currentList
        .add(BuildScriptItemContentEntity(element, annotation, buildStep));
  }


}
