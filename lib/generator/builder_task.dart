import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:frouter/entity/entity.dart';
import 'package:frouter/generator/generator_router_path.dart';
import 'package:frouter/generator/generator_task.dart';
import 'package:dart_style/dart_style.dart';
import 'package:frouter/generator/util/task_template_util.dart';
import 'package:path/path.dart' as path;

class RouterTaskPostProcessBuilder extends PostProcessBuilder {
  static final Map<String, List<BuildScriptItemContentEntity>> _taskMap = {};

  @override
  FutureOr<void> build(PostProcessBuildStep buildStep) async {
    for (BuildScriptItemContentEntity entity in TaskGenerator.registerTaskMap.values) {
      final currentPackage = entity.buildStep.inputId.package;

      if (!_taskMap.containsKey(currentPackage)) {
        _taskMap[currentPackage] = [];
      }
      if (!(_taskMap[currentPackage]?.contains(entity) ?? true)) {
        _taskMap[currentPackage]!.add(entity);
      }
    }

    _checkTaskFile(buildStep);

    return;
  }

  @override
  Iterable<String> get inputExtensions => [".yaml"];

  void _checkTaskFile(PostProcessBuildStep buildStep) {
    if (_taskMap.containsKey(buildStep.inputId.package) ||
        (RouterPathGenerator.packageGraph!
                .allPackages[buildStep.inputId.package]?.dependencies
                .where((element) => _taskMap.containsKey(element.name))
                .isNotEmpty ??
            false)) {
      final targetAsset = AssetId(buildStep.inputId.package,
          'lib/${buildStep.inputId.package}_task.dart');
      var package = RouterPathGenerator.packageGraph![targetAsset.package];
      final targetFile = File(path.join(package!.path, targetAsset.path));

      if (targetFile.existsSync()) {
        targetFile.deleteSync();
      }

      _buildTaskFile(targetAsset, buildStep, _taskMap);
    }
  }

  void _buildTaskFile(AssetId targetAsset, PostProcessBuildStep buildStep,
      Map<String, List<BuildScriptItemContentEntity>> taskMap) {
    FileBasedAssetWriter writer =
        FileBasedAssetWriter(RouterPathGenerator.packageGraph!);

    final content = StringBuffer();
    content
      ..writeln('// Generated by lwlizhe frouter plugin, do not edit manually.')
      ..writeln(
          '// run pub run build_runner build --delete-conflicting-outputs')
      ..writeln('// ignore_for_file: directives_ordering')
      ..writeln(GeneratorTaskUtil.getTaskContent(
          packageGraph: RouterPathGenerator.packageGraph!,
          buildStep: buildStep,
          sourceMap: taskMap));

    writer.writeAsString(
        targetAsset, DartFormatter().format(content.toString()));
  }
}
