import 'package:flutter/material.dart';
import 'package:frouter/annotation/router.dart';
import 'package:frouter/annotation/task/frouter_flow_task_annotation.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

@FlowTask()
@RouterPath(pathUri: 'post/post_info')
class PostInfoPage extends StatelessWidget {
  final List<String> postTitleList;

  @FlowTaskInject(
      taskIdentifier: 'moduleB_test',
      dependOn: '',
      isInitTask: true,
      isNeedAwait: false)
  static Function test = () {
    showToast('moduleB的同步方法,立马用toast展示', duration: const Duration(seconds: 5));
  };

  @FlowTaskInject(
      taskIdentifier: 'moduleB_init',
      dependOn: 'base_init,moduleA_init,moduleC_init',
      isInitTask: true,
      isNeedAwait: true)
  static Function moduleBInit = () async {
    Get.snackbar('ModuleB Module', 'ModuleB Module Init',
        duration: const Duration(seconds: 1));
  };


  @FlowTaskInject(
      taskIdentifier: 'moduleB_permission',
      dependOn: 'base_init',
      isInitTask: true,
      isNeedAwait: true)
  static Function moduleBPermission = () async {
    Get.snackbar('ModuleB Module', 'ModuleB Module Permission',
        duration: const Duration(seconds: 1));
  };

  const PostInfoPage(this.postTitleList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户信息'),
      ),
      body: Container(
        alignment: AlignmentDirectional.center,
        child: const Text(
            'moudule B 中假装的帖子详情页面',
            textAlign: TextAlign.center),
      ),
    );
  }
}
