import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:dart_style/dart_style.dart';
import 'package:frouter/annotation/router_register.dart';
import 'package:frouter/entity/entity.dart';
import 'package:frouter/generator/generator_path.dart';
import 'package:source_gen/source_gen.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class RouterGenerator extends GeneratorForAnnotation<RouterRegister> {
  static List<RouterHostContentEntity> registerHostList = [];

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {

    final currentEntity =
        RouterHostContentEntity(element, annotation, buildStep);
    registerHostList.add(currentEntity);
  }


}
