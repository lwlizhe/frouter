import 'package:frouter/generator/builder_export.dart';
import 'package:frouter/generator/builder_map.dart';
import 'package:frouter/generator/builder_task.dart';
import 'package:frouter/generator/generator_router_path.dart';
import 'package:frouter/generator/generator_router_map.dart';
import 'package:frouter/generator/generator_task.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

/// Does not generate files here
/// 这里并不生成文件
Builder pathBuilder(BuilderOptions options) =>
    LibraryBuilder(RouterPathGenerator(), generatedExtension: ".empty");

/// 生成".router.dart"结尾的文件
/// Generate a file ending with ".router.dart"
Builder routerRegisterBuilder(BuilderOptions options) =>
    LibraryBuilder(RouterGenerator(), generatedExtension: ".router");

// /// 生成".router.dart"结尾的文件
// /// Generate a file ending with ".router.dart"
// Builder mapBuilder(BuilderOptions options) => RouterMapBuilder();

/// 生成".router.dart"结尾的文件
/// Generate a file ending with ".router.dart"
PostProcessBuilder mapPostProcessBuilder(BuilderOptions options) =>
    RouterMapPostProcessBuilder();

Builder routerTaskBuilder(BuilderOptions options) =>
    LibraryBuilder(TaskGenerator(), generatedExtension: ".task");

PostProcessBuilder taskPostBuilder(BuilderOptions options) =>
    RouterTaskPostProcessBuilder();

PostProcessBuilder exportFileBuilder(BuilderOptions options) =>
    RouterExportPostProcessBuilder();
