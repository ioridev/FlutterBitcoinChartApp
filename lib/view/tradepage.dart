import 'dart:async';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';
import 'package:http/http.dart' as http;

class TradePage extends StatefulWidget {
  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  List<KLineEntity> datas;
  bool showLoading = true;
  MainState _mainState = MainState.NONE;
  SecondaryState _secondaryState = SecondaryState.NONE;

  @override
  void initState() {
    super.initState();
    getData('1day');
    //Timer.periodic(const Duration(seconds: 10), _onTimer);
  }

  void _onTimer(Timer timer) {
    getData('1day');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ListView(
        children: <Widget>[
          Stack(children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 1.9,
              width: double.infinity,
              child: KChartWidget(
                datas,
                mainState: _mainState,
                secondaryState: _secondaryState,
                fixedLength: 2,
                timeFormat: TimeFormat.YEAR_MONTH_DAY,
                isChinese: false,
              ),
            ),
            if (showLoading)
              Container(
                  width: MediaQuery.of(context).size.height / 1.9,
                  height: 450,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator()),
          ]),
          buildButtons(),
          FlatButton(
              onPressed: () async {
                await getData('1day');
              },
              child: const Text('更新'))
        ],
      ),
    );
  }

  Widget buildButtons() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        button('MA', onPressed: () => _mainState = MainState.MA),
        button('BOLL', onPressed: () => _mainState = MainState.BOLL),
        button('非表示', onPressed: () => _mainState = MainState.NONE),
        button('MACD', onPressed: () => _secondaryState = SecondaryState.MACD),
        button('KDJ', onPressed: () => _secondaryState = SecondaryState.KDJ),
        button('RSI', onPressed: () => _secondaryState = SecondaryState.RSI),
        button('WR', onPressed: () => _secondaryState = SecondaryState.WR),
        button('非表示', onPressed: () => _secondaryState = SecondaryState.NONE),
      ],
    );
  }

  Widget button(String text, {VoidCallback onPressed}) {
    return FlatButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
          setState(() {});
        }
      },
      child: Text('$text'),
    );
  }

  Future<void> getData(String period) async {
    final future = getIPAddress('$period');
    await future.then((result) {
      final dynamic parseJson = json.decode(result);
      final list = parseJson['data'] as List;
      datas = list
          .map((item) => KLineEntity.fromJson(item))
          .toList()
          .reversed
          .toList()
          .cast<KLineEntity>();
      DataUtil.calculate(datas);
      showLoading = false;
      setState(() {});
    }).catchError((_) {
      showLoading = true;
      setState(() {});
      print('データを取得できませんでした');
    });
  }

  Future<String> getIPAddress(String period) async {
    final url =
        'https://api-cloud.huobi.co.jp/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcjpy';
    String result;
    final response = await http.get(url);
    print(url);
    if (response.statusCode == 200) {
      result = response.body;
    } else {
      print('Failed getting IP address');
    }
    return result;
  }

  Future<SimpleDialog> indicatorMenuDialog(BuildContext context) {
    return showDialog<SimpleDialog>(
      context: context,
      builder: (context) => SimpleDialog(children: <Widget>[
        Column(
          children: <Widget>[
            buildButtons(),
            RaisedButton(
                child: const Text('閉じる'),
                onPressed: () => Navigator.pop(context))
          ],
        )
      ]),
    );
  }
}
