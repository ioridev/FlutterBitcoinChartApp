import 'dart:convert' show utf8;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webfeed/webfeed.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  static const String rssurl =
      'https://jp.cointelegraph.com/rss/category/market-analysis';
  RssFeed _feed;

  static const String placeholderImg = 'images/no_image.png';
  GlobalKey<RefreshIndicatorState> _refreshKey;

  updateFeed(feed) {
    setState(() {
      _feed = feed as RssFeed;
    });
  }

  Future<void> openFeed(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: false,
      );
      return;
    }
  }

  Future<void> load() async {
    await loadFeed().then((result) async {
      if (null == result || result.toString().isEmpty) {
        return;
      }
      updateFeed(result);
    });
  }

  Future<RssFeed> loadFeed() async {
    try {
      final client = http.Client();
      final response = await client.get(rssurl);
      final responseBody = utf8.decode(response.bodyBytes);
      return RssFeed.parse(responseBody);
    } on Exception {
      //
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    load();
  }

  Widget title(title) {
    return Text(
      title as String,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget subtitle(subTitle) {
    return Text(
      subTitle as String,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w100),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget thumbnail(imageUrl) {
    return CachedNetworkImage(
      placeholder: (context, url) => Image.asset(placeholderImg),
      imageUrl: imageUrl as String,
      alignment: Alignment.center,
      fit: BoxFit.fill,
    );
  }

  Widget list() {
    return ListView.builder(
      itemCount: _feed.items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = _feed.items[index];
        return GestureDetector(
          onTap: () => openFeed(item.link),
          child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    thumbnail(item.enclosure.url),
                    title(item.title),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[subtitle(item.pubDate)],
                    )
                  ],
                ),
              )),
        );
      },
    );
  }

  bool isFeedEmpty() {
    return null == _feed || null == _feed.items;
  }

  Widget body() {
    return isFeedEmpty()
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            key: _refreshKey,
            child: list(),
            onRefresh: () async => load(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('暗号通貨ニュース'),
        centerTitle: true,
      ),
      body: body(),
    );
  }
}
