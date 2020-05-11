import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BfchatPage extends StatefulWidget {
  @override
  _BfchatPageState createState() => _BfchatPageState();
}

class _BfchatPageState extends State<BfchatPage> {
  List bfchat;
  List bfChatData;

  @override
  void initState() {
    super.initState();
    getChatData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('BFチャット'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.help), onPressed: null)
          ],
        ),
        body: RefreshIndicator(
            onRefresh: getChatData,
            child: ListView.builder(
              itemCount: bfchat == null ? 0 : 100,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${bfchat[index]["nickname"]} ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16, left: 16),
                        child: Text('${bfchat[index]["message"]}'),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '${bfchat[index]["date"]}',
                              style: TextStyle(
                                color: Colors.blueGrey,
                              ),
                            ),
                          ])
                    ],
                  ),
                );
              },
            )));
  }

  Future<void> getChatData() async {
    const url = 'https://api.bitflyer.com/v1/getchats';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;
      bfchat = jsonData.reversed.toList();

      setState(() {});
    } else {
      throw Exception('Failed to load');
    }
  }
}
