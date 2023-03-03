import 'package:flutter/material.dart';
import 'package:frouter/frouter.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    TextEditingController testController2 = TextEditingController();

    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('我是example 主工程中的TestPageA'),
            SizedBox(
              height: 50,
            ),
            TextButton(
                onPressed: () {
                  Get.toNamed('/user/user_info', parameters: {
                    'name': '法外狂徒张三',
                    'userTokenA': '终身编号：9527',
                  });
                  // Navigator.of(context).pushNamed(
                  //     'moduleA/testB?requiredArgument=testRequiredArgument&argument=testArgument&intArgument=1');
                },
                child: Text('跳转到 moduleA 中的UserInfoPage')),
            TextButton(
                onPressed: () {
                  Get.toNamed('/post/post_info', arguments: {
                    'postTitleList': <String>[
                      '震惊，这个帖子竟然是假的',
                      '到底是人性的扭曲还是道德的沦丧'
                    ],
                  });
                  // Navigator.of(context).pushNamed(
                  //     'moduleA/testB?requiredArgument=testRequiredArgument&argument=testArgument&intArgument=1');
                },
                child: Text('跳转到 moduleB 中的PostInfoPage')),
            TextButton(
                onPressed: () {
                  Get.toNamed('/app/live');
                  // Navigator.of(context).pushNamed(
                  //     'moduleA/testB?requiredArgument=testRequiredArgument&argument=testArgument&intArgument=1');
                },
                child: Text('跳转到 moduleA 中的 LivePage')),
            TextButton(
                onPressed: () {
                  FRouterTask().startInitTask();
                  // Get.toNamed('/app/live');
                  // Navigator.of(context).pushNamed(
                  //     'moduleA/testB?requiredArgument=testRequiredArgument&argument=testArgument&intArgument=1');
                },
                child: Text('假装这里是闪屏页，点击生成有向无环图并拓扑排序最后调用')),
            TextButton(
                onPressed: () {
                  FRouterTask()
                      .loadTaskMeta('moduleA_test_parameter')
                      ?.apply(parameters: ['燕子，没有你我可怎么活啊']);
                  // Get.toNamed('/app/live');
                  // Navigator.of(context).pushNamed(
                  //     'moduleA/testB?requiredArgument=testRequiredArgument&argument=testArgument&intArgument=1');
                },
                child: Text('调用一下其他模块的全局方法')),
            TextButton(
                onPressed: () {
                  FRouterTask()
                      .loadTaskMeta('moduleA_test_parameter')
                      ?.apply(parameters: [testController2.text]);
                  // Get.toNamed('/app/live');
                  // Navigator.of(context).pushNamed(
                  //     'moduleA/testB?requiredArgument=testRequiredArgument&argument=testArgument&intArgument=1');
                },
                child: Text('调用一下其他模块的全局方法（带参数）')),
            TextField(
              controller: testController2,
              decoration: const InputDecoration(
                hintText: '全局方法携带的参数',
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Text('通过纯手动输入的方式实现路由跳转'),
            TextField(
              controller: controller,
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(controller.text);
              },
              child: Text('跳转'),
            ),
            SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () {
                FRouter().updateBundle(
                    '{"post/post_info":"package:base/common/common_web_page.dart:CommonWebPage"}');
              },
              child: Text('替换更新路由表'),
            ),
          ],
        ),
      )),
    );
  }
}
