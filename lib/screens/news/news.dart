import 'package:flutter/material.dart';

import '../buildAppBar.dart';


class News extends StatefulWidget {
  const News({Key? key}) : super(key: key);

  @override
  _NewsState createState() => _NewsState();
}

class _NewsState extends State<News> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 175, 20, 1),
      appBar: buildAppBar(context, 'News'),
    );
  }
}

