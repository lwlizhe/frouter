// ignore_for_file: directives_ordering
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:frouter/builder/builder.dart' as _i2;
import 'package:source_gen/builder.dart' as _i3;
import 'dart:isolate' as _i4;
import 'package:build_runner/build_runner.dart' as _i5;
import 'dart:io' as _i6;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(
    r'frouter:path_builder',
    [_i2.pathBuilder],
    _i1.toDependentsOf(r'frouter'),
    hideOutput: true,
  ),
  _i1.apply(
    r'frouter:router_register_builder',
    [_i2.routerRegisterBuilder],
    _i1.toDependentsOf(r'frouter'),
    hideOutput: true,
    appliesBuilders: const [r'frouter:map_builder'],
  ),
  _i1.apply(
    r'frouter:router_task_builder',
    [_i2.routerTaskBuilder],
    _i1.toDependentsOf(r'frouter'),
    hideOutput: true,
    appliesBuilders: const [r'frouter:task_builder'],
  ),
  _i1.apply(
    r'source_gen:combining_builder',
    [_i3.combiningBuilder],
    _i1.toNoneByDefault(),
    hideOutput: false,
    appliesBuilders: const [r'source_gen:part_cleanup'],
  ),
  _i1.applyPostProcess(
    r'source_gen:part_cleanup',
    _i3.partCleanup,
  ),
  _i1.applyPostProcess(
    r'frouter:map_builder',
    _i2.mapPostProcessBuilder,
  ),
  _i1.applyPostProcess(
    r'frouter:task_builder',
    _i2.taskPostBuilder,
  ),
];
void main(
  List<String> args, [
  _i4.SendPort? sendPort,
]) async {
  var result = await _i5.run(
    args,
    _builders,
  );
  sendPort?.send(result);
  _i6.exitCode = result;
}
