import 'package:base/interface/base_cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:frouter/annotation/router.dart';
import 'package:frouter/frouter.dart';
import 'package:base/const/base_const_value.dart';

@RouterPath(pathUri: 'app/live')
class LivePage extends StatelessWidget {
  const LivePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('直播'),
      ),
      body: Container(
        alignment: AlignmentDirectional.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '假装这里有个嘎子在带货嘎子牌手机',
              textAlign: TextAlign.center,
            ),
            TextButton(
                onPressed: () {

                  final provider = FRouter()
                      .build(CommonValue.providerLiveCart)
                      .navigation() as BaseCartProvider;

                  provider.addProductsToCart([
                    '嘎子牌手机',
                    '嘎子的贴心正版保障',
                    '嘎子牌假酒？不对，嘎子说过他这里没有假货',
                  ]);

                },
                child: const Text('冒着被笑两年半的风险也要支持家人！下单！'))
          ],
        ),
      ),
    );
  }
}
