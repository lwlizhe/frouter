import 'package:flutter/material.dart';
import 'package:frouter/annotation/router.dart';

@RouterPath(pathUri: 'post/post_info')
class PostInfoPage extends StatelessWidget {
  final List<String> postTitleList;

  const PostInfoPage(this.postTitleList, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('用户信息'),
      ),
      body: Container(
        alignment: AlignmentDirectional.center,
        child: const Text('moudule B 中假装的帖子详情页面'),
      ),
    );
  }
}
