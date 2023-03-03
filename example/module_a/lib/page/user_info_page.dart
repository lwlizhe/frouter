import 'package:flutter/material.dart';
import 'package:frouter/annotation/router.dart';
import 'package:frouter/annotation/request/request_annotation.dart';
import 'package:frouter/annotation/task/frouter_flow_task_annotation.dart';
import 'package:get/get.dart';
import 'package:module_a/entity/user_info.dart';

@FlowTask()
@RouterPath(pathUri: 'user/user_info')
class UserInfoPage extends StatelessWidget {
  final String userToken;
  final UserInfo userInfo;

  @FlowTaskInject(taskIdentifier: 'moduleA_test')
  static Function test = () async {
    Get.snackbar('moduleA', 'moduleA中的全局异步方法');
  };

  @FlowTaskInject(taskIdentifier: 'moduleA_test_parameter')
  static Function testParameter = (String testData) async {
    Get.snackbar('moduleA', '传过来的参数：$testData');
  };

  @FlowTaskInject(
      taskIdentifier: 'moduleA_init',
      dependOn: 'base_init',
      isInitTask: true,
      isNeedAwait: true)
  static Function moduleAInit = () async {
    Get.snackbar('ModuleA Module', 'ModuleA Module Init');
  };

  @FlowTaskInject(
      taskIdentifier: 'moduleA_permission',
      dependOn: 'base_init',
      isInitTask: true,
      isNeedAwait: true)
  static Function moduleAPermission = () async {
    Get.snackbar('ModuleA Module', 'ModuleA Module Permission');
  };

  const UserInfoPage(
      {@requestBody required this.userInfo,
      @RequestParam(parameterName: 'userTokenA') required this.userToken})
      : super(key: null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户信息:${userInfo.name}'),
      ),
      body: Container(
        alignment: AlignmentDirectional.center,
        child: Text(
          'moudule A 中假装的用户信息页面\n\n\n userName 为 ${userInfo.name} \n userToken 为 $userToken \n\n\n 传递的参数为 userInfo : $userInfo , userToken : $userToken',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
