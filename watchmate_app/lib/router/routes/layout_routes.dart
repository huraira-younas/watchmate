import 'package:watchmate_app/features/my_list/views/my_list_screen.dart';
import 'package:watchmate_app/features/profile/views/profile_screen.dart';
import 'package:watchmate_app/features/stream/views/stream_screen.dart';
import 'package:watchmate_app/features/chats/views/chat_screen.dart';
import 'package:watchmate_app/features/home/views/home_screen.dart';
import 'package:watchmate_app/router/routes/app_route_model.dart';
import 'package:flutter/material.dart' show Icons;

abstract class LayoutRoutes {
  static const stream = AppRoute(
    icon: Icons.settings_input_antenna_rounded,
    page: StreamScreen(),
    path: '/stream',
    name: 'Stream',
  );

  static const home = AppRoute(
    page: HomeScreen(),
    icon: Icons.home,
    path: '/home',
    name: 'Home',
  );

  static const myList = AppRoute(
    page: MyListScreen(),
    icon: Icons.view_list,
    path: '/my_list',
    name: 'My List',
  );

  static const downloads = AppRoute(
    icon: Icons.chat_rounded,
    page: ChatScreen(),
    path: '/chats',
    name: 'Chats',
  );

  static const profile = AppRoute(
    page: ProfileScreen(),
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
