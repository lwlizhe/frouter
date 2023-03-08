import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:dart_style/dart_style.dart';
import 'package:frouter/entity/entity.dart';
import 'package:frouter/generator/generator_router_path.dart';
import 'package:path/path.dart' as path;

import 'generator_task.dart';

class RouterExportPostProcessBuilder extends PostProcessBuilder {
  @override
  FutureOr<void> build(PostProcessBuildStep buildStep) async {
    await _checkExportFile(buildStep);
    return;
  }

  @override
  Iterable<String> get inputExtensions => [".yaml"];

  Future<void> _checkExportFile(
    PostProcessBuildStep buildStep,
  ) async {
    final packageKey = buildStep.inputId.package;

    final contentEntity =
        RouterPathGenerator.currentRegisterModuleMap[packageKey]!.first;
    final contentList =
        RouterPathGenerator.currentRegisterModuleMap[packageKey]!;
    final taskList = TaskGenerator.registerTaskMap.values
        .where((element) => element.buildStep.inputId.package == packageKey);

    final targetAsset =
        AssetId(packageKey, 'lib/${packageKey}_route_export.dart');
    var package = RouterPathGenerator.packageGraph![targetAsset.package];
    final targetFile = File(path.join(package!.path, targetAsset.path));

    if (RouterPathGenerator.packageGraph?.root.name !=
        contentEntity.buildStep.inputId.package) {
      if (targetFile.existsSync()) {
        targetFile.deleteSync();
      }

      await _createExportFile(
          targetAsset, contentEntity, [...contentList, ...taskList]);
    }
  }

  Future<void> _createExportFile(
      AssetId targetAssetId,
      BuildScriptItemContentEntity contentEntity,
      List<BuildScriptItemContentEntity> contentList) async {
    FileBasedAssetWriter writer =
        FileBasedAssetWriter(RouterPathGenerator.packageGraph!);

    await writer.writeAsString(
        targetAssetId, await _createExportContent(contentEntity, contentList));
  }

  Future<String> _createExportContent(
      BuildScriptItemContentEntity contentEntity,
      List<BuildScriptItemContentEntity> contentList) async {
    StringBuffer sb = StringBuffer();

    sb.writeln(
        'library ${contentEntity.buildStep.inputId.package}_route_export;');

    List<String> exportList = contentList
        .map((item) => path.relative(item.buildStep.inputId.path, from: 'lib'))
        .toList();

    exportList = exportList.toSet().toList();

    for (String path in exportList) {
      sb.writeln("export '$path';");
    }

    return DartFormatter().format(sb.toString());
  }
}
