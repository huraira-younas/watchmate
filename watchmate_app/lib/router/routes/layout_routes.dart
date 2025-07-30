import 'package:watchmate_app/features/downloads/views/downloads_screen.dart';
import 'package:watchmate_app/features/my_list/views/my_list_screen.dart';
import 'package:watchmate_app/features/home/views/home_screen.dart';
import 'package:watchmate_app/router/routes/app_route_model.dart';
import 'package:flutter/material.dart' show Icons;

abstract class LayoutRoutes {
  static const home = AppRoute(
    page: HomeScreen(),
    icon: Icons.home,
    path: '/home',
    name: 'Home',
  );

  static const myList = AppRoute(
    page: MyListScreen(),
    icon: Icons.list,
    path: '/my_list',
    name: 'My List',
  );

  static const downloads = AppRoute(
    page: DownloadsScreen(),
    icon: Icons.download,
    path: '/downloads',
    name: 'Downloads',
  );

  static const profile = AppRoute(
    page: DownloadsScreen(),
    icon: Icons.person,
    path: '/profile',
    name: 'Profile',
  );

  static final all = [home, myList, downloads, profile];

  static AppRoute getByPath(String path) {
    return all.firstWhere(
      (item) => path.startsWith(item.path),
      orElse: () => all.first,
    );
  }

  static int getIndex(String path) {
    return all
        .indexWhere((item) => path.startsWith(item.path))
        .clamp(0, all.length - 1);
  }
}
