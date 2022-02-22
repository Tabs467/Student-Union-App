import 'package:flutter/material.dart';
import '../buildAppBar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  _NewsState createState() => _NewsState();
}

// Widget to display the Salford Student Union's most recent Tweets
class _NewsState extends State<News> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'News'),
      body: const WebView(
        initialUrl: 'https://twitter.com/salfordsu',
        // Allow JavaScript from the Twitter page to be run freely so it can
        // be loaded
        javascriptMode: JavascriptMode.unrestricted,
      )
    );
  }
}
