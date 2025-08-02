import 'package:watchmate_app/features/home/views/movies_tab.dart';
import 'package:watchmate_app/features/home/views/stream_tab.dart';
import 'package:watchmate_app/common/widgets/custom_tabbar.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, Widget> _tabs = {
    "Movies": MoviesTab(),
    "Stream": StreamTab(),
  };

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final widgets = _tabs.entries.map((e) => e.value).toList();
    final keys = _tabs.entries.map((e) => e.key).toList();

    return Column(
      children: <Widget>[
        CustomTabBar(tabs: keys, controller: _tabController),
        TabBarView(controller: _tabController, children: widgets).expanded(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
