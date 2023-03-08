import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class BuildScriptItemContentEntity {
  Element element;
  ConstantReader annotation;
  BuildStep buildStep;

  BuildScriptItemContentEntity(this.element, this.annotation, this.buildStep);
}
