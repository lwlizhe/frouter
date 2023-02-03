import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:build/build.dart';
import 'package:build_runner_core/build_runner_core.dart';
import 'package:dart_style/dart_style.dart';
import 'package:frouter/entity/entity.dart';
import 'package:frouter/generator/generator_path.dart';
import 'package:frouter/generator/generator_router.dart';
import 'package:frouter/generator/util/template_util.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

final _log = Logger('Entrypoint');

class RouterMapPostProcessBuilder extends PostProcessBuilder {
  static Map<String, List<RouterItemScriptContentEntity>> _routerMap = {};

  @override
  FutureOr<void> build(PostProcessBuildStep buildStep) async {
    print(buildStep.inputId);

    await Future.forEach<String>(
        RouterPathGenerator.currentRegisterModuleMap.keys, (moduleKey) async {
      await _checkExportFile(
          RouterPathGenerator.currentRegisterModuleMap[moduleKey]!.first,
          RouterPathGenerator.currentRegisterModuleMap[moduleKey]!);
    });

    checkRouterHost();
    checkCreateRouterMap(buildStep);
    return;
  }

  @override
  // TODO: implement inputExtensions
  Iterable<String> get inputExtensions => [".yaml"];

  Future<void> _checkExportFile(RouterItemScriptContentEntity contentEntity,
      List<RouterItemScriptContentEntity> contentList) async {
    final targetAsset = AssetId(contentEntity.buildStep.inputId.package,
        'lib/${contentEntity.buildStep.inputId.package}_route_export.dart');
    var package = RouterPathGenerator.packageGraph![targetAsset.package];
    final targetFile = File(path.join(package!.path, targetAsset.path));

    if (!targetFile.existsSync() &&
        RouterPathGenerator.packageGraph?.root.name !=
            contentEntity.buildStep.inputId.package) {
      await _createExportFile(targetAsset, contentEntity, contentList);
    }
  }

  Future<void> _createExportFile(
      AssetId targetAssetId,
      RouterItemScriptContentEntity contentEntity,
      List<RouterItemScriptContentEntity> contentList) async {
    FileBasedAssetWriter writer =
    FileBasedAssetWriter(RouterPathGenerator.packageGraph!);

    await writer.writeAsString(
        targetAssetId, await _createExportContent(contentEntity, contentList));
  }

  Future<String> _createExportContent(
      RouterItemScriptContentEntity contentEntity,
      List<RouterItemScriptContentEntity> contentList) async {
    StringBuffer sb = StringBuffer();

    sb.writeln(
        'library ${contentEntity.buildStep.inputId.package}_route_export;');

    for (RouterItemScriptContentEntity item in contentList) {
      sb.writeln(
          "export '${path.relative(item.buildStep.inputId.path, from: 'lib')}';");
    }

    return DartFormatter().format(sb.toString());
  }

  void checkRouterHost() {
    if (_routerMap.isEmpty) {
      final packageGraph = RouterPathGenerator.packageGraph;
      final registerHostModuleList = RouterGenerator.registerHostList;

      final subRegisterModuleList = registerHostModuleList.where((element) {
        return element.buildStep.inputId.package != packageGraph!.root.name;
      }).toList();

      for (RouterHostContentEntity subModule in subRegisterModuleList) {
        _routerMap[subModule.buildStep.inputId.package] = List.from(
            RouterPathGenerator.currentRegisterModuleMap[
                subModule.buildStep.inputId.package]!);
        RouterPathGenerator.currentRegisterModuleMap
            .remove(subModule.buildStep.inputId.package);
      }

      final leftRouterList =
          RouterPathGenerator.currentRegisterModuleMap.keys.expand((element) {
        return RouterPathGenerator.currentRegisterModuleMap[element]!;
      });
      _routerMap[packageGraph!.root.name] = List.from(leftRouterList);
    }
  }

  void checkCreateRouterMap(PostProcessBuildStep buildStep) {
    if (_routerMap.keys.contains(buildStep.inputId.package)) {
      final targetAsset = AssetId(buildStep.inputId.package,
          'lib/${buildStep.inputId.package}_route.dart');
      var package = RouterPathGenerator.packageGraph![targetAsset.package];
      final targetFile = File(path.join(package!.path, targetAsset.path));

      if (!targetFile.existsSync()) {
        _createRouterMapFile(
            targetAsset, buildStep, _routerMap[buildStep.inputId.package]!);
      }
    }
  }

  void _createRouterMapFile(AssetId targetAsset, PostProcessBuildStep buildStep,
      List<RouterItemScriptContentEntity> list) {
    FileBasedAssetWriter writer =
        FileBasedAssetWriter(RouterPathGenerator.packageGraph!);

    final content = StringBuffer();
    content
      ..writeln('// Generated by lwlizhe frouter plugin, do not edit manually.')
      ..writeln(
          '// run pub run build_runner build --delete-conflicting-outputs')
      ..writeln('// ignore_for_file: directives_ordering')
      ..writeln(GeneratorTemplateUtil.getTemplate(
          packageGraph: RouterPathGenerator.packageGraph!,
          buildStep: buildStep,
          sourceMap: _routerMap));

    writer.writeAsString(
        targetAsset, DartFormatter().format(content.toString()));
  }
}

class RouterMapBuilder extends Builder {
  PackageGraph? packageGraph;

  /// Converts [Future], [Iterable], and [Stream] implementations
  /// containing [String] to a single [Stream] while ensuring all thrown
  /// exceptions are forwarded through the return value.
  Stream<String> normalizeGeneratorOutput(Object? value) {
    if (value == null) {
      return const Stream.empty();
    } else if (value is Future) {
      return StreamCompleter.fromFuture(value.then(normalizeGeneratorOutput));
    } else if (value is String) {
      value = [value];
    }

    if (value is Iterable) {
      value = Stream.fromIterable(value);
    }

    if (value is Stream) {
      return value.where((e) => e != null).map((e) {
        if (e is String) {
          return e.trim();
        }

        throw _argError(e as Object);
      }).where((e) => e.isNotEmpty);
    }
    throw _argError(value);
  }

  ArgumentError _argError(Object value) => ArgumentError(
        'Must be a String or be an Iterable/Stream containing String values. '
        'Found `${Error.safeToString(value)}` (${value.runtimeType}).',
      );

  @override
  // TODO: implement buildExtensions
  Map<String, List<String>> get buildExtensions => {
        '.dart': [
          '.map',
        ]
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final currentRouterItemMap = RouterPathGenerator.currentRegisterModuleMap;

    if (packageGraph == null) {
      packageGraph = await PackageGraph.forThisPackage();

      if (currentRouterItemMap.keys.isNotEmpty) {
        final registerModuleList = currentRouterItemMap.keys.toList();

        /// todo 在注册组件列表的目录下，生成引用文件
        // for (String key in registerModuleList) {
        //   final configList = currentRouterItemMap[key];
        //   Element element = configList![0] as Element;
        //   ConstantReader annotation = configList[1] as ConstantReader;
        //   BuildStep buildStep = configList[2] as BuildStep;
        //
        //   print(element);
        // }

        /// todo 生成路由表；

      }

      // final library = await buildStep.resolver
      //     .libraryFor(buildStep.inputId, allowSyntaxErrors: false);
      // final LibraryReader libraryReader = LibraryReader(library);
      // final typeElementList = libraryReader.annotatedWith(typeChecker);
      // final environment = IOEnvironment(packageGraph!);
      //
      // final assetGraphId = AssetId(packageGraph!.root.name, assetGraphPath);
      // if (!await environment.reader.canRead(assetGraphId)) {
      //   return null;
      // }
      //
      // var cachedGraph = AssetGraph.deserialize(
      //     await environment.reader.readAsBytes(assetGraphId));
      // _matchingPrimaryInputs('example', 0, cachedGraph, packageGraph!)
      //     .then((value) {
      //   print(value);
      // });
    }

    final values = <String>{};

    try {
      final content = StringBuffer();
      content..writeln('// ignore_for_file: directives_ordering');
      // ..writeln(
      //     GeneratorTemplateUtil.getTemplate(packageGraph: packageGraph!));

      await for (var value in normalizeGeneratorOutput(
          DartFormatter().format(content.toString()))) {
        assert(value.length == value.trim().length);
        values.add(value);
      }
    } catch (e) {
      _log.severe('Generated build script could not be parsed.\n'
          'This is likely caused by a misconfigured builder definition.');
      throw CannotBuildException();
    }

    String content = values.join('\n\n');

    return;
  }
}