import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class RouterItemScriptContentEntity {
  Element element;
  ConstantReader annotation;
  BuildStep buildStep;

  RouterItemScriptContentEntity(this.element, this.annotation, this.buildStep);
}

class RouterHostContentEntity {
  Element element;
  ConstantReader annotation;
  BuildStep buildStep;

  RouterHostContentEntity(this.element, this.annotation, this.buildStep);
}
