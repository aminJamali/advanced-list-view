import 'dart:io';

import 'package:advanced_list_view/advanced_list_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'person_view_model.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced List View',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Advanced List View Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _hasMoreData = true;
  int offset = 1;
  final int limit = 10;
  bool showErrorWidget = false,
      showEmptyWidget = false,
      showLoadingWidget = true;

  final List<PersonViewModel> listItems = [];

  Future<void> _onRefresh() async {
    listItems.clear();
    offset = 1;
    setState(() {
      showLoadingWidget = true;
      showErrorWidget = false;
      showEmptyWidget = false;
    });
    _onLoadMoreData();
  }

  Future<void> _onLoadMoreData() async {
    setState(() {
      showErrorWidget = false;
      showEmptyWidget = false;
      showLoadingWidget = true;
    });

    final response = await Dio()
        .get('https://retoolapi.dev/cXYQ5x/data?_page=$offset&_limit=$limit');

    if (offset == 1) {
      listItems.clear();
    }

    List<PersonViewModel> receivedItems = [];

    receivedItems = (response.data as List)
        .map(
          (final e) => PersonViewModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();

    listItems.addAll(receivedItems);

    setState(() {
      showLoadingWidget = false;
    });
    if (receivedItems.length < limit) {
      _hasMoreData = false;
    }
    offset++;
  }

  @override
  void initState() {
    _onLoadMoreData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: _bottomNavBar(),
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: AdvancedListView<PersonViewModel>(
        items: listItems,
        canRefresh: true,
        showLoadingWidget: showLoadingWidget,
        showErrorWidget: showErrorWidget,
        shrinkWrap: true,
        showEmptyWidget: showEmptyWidget,
        onRefresh: _onRefresh,
        onLoadMoreData: _onLoadMoreData,
        hasMoreData: _hasMoreData,
        itemBuilder:
            (final BuildContext context, final int index, final item) =>
                ListTile(
          title: Text(item.name),
        ),
      ),
    );
  }

  Widget _bottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.green,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _errorButton(),
          _emptyButton(),
        ],
      ),
    );
  }

  Widget _emptyButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          showEmptyWidget = true;
        });
      },
      child: const Text('show empty widget'),
    );
  }

  Widget _errorButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          showErrorWidget = true;
        });
      },
      child: const Text('show error widget'),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
