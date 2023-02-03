import 'package:flutter/material.dart';
import 'package:frouter/annotation/router.dart';
import 'package:frouter/annotation/request/request_annotation.dart';
import 'package:module_a/entity/user_info.dart';

@RouterPath(pathUri: 'user/user_info')
class UserInfoPage extends StatelessWidget {
  final String userToken;

  const UserInfoPage(
      {@requestBody required UserInfo? userInfo,
      @RequestParam(parameterName: 'userTokenA') required this.userToken})
      : super(key: null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户信息'),
      ),
      body: Container(
        alignment: AlignmentDirectional.center,
        child: const Text('moudule A 中假装的用户信息页面'),
      ),
    );
  }
}
