import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:frouter/annotation/router_register.dart';
import 'package:frouter/entity/entity.dart';
import 'package:source_gen/source_gen.dart';

class RouterGenerator extends GeneratorForAnnotation<RouterRegister> {
  static List<BuildScriptItemContentEntity> registerHostList = [];

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {

    final currentEntity =
    BuildScriptItemContentEntity(element, annotation, buildStep);
    registerHostList.add(currentEntity);
  }


}
