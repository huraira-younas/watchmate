import 'package:watchmate_app/features/my_list/views/my_list_screen.dart';
import 'package:watchmate_app/features/profile/views/profile_screen.dart';
import 'package:watchmate_app/features/chats/views/chat_screen.dart';
import 'package:watchmate_app/features/home/views/home_screen.dart';
import 'package:watchmate_app/router/routes/app_route_model.dart';
import 'package:watchmate_app/layouts/home_layout.dart';
import 'package:flutter/material.dart' show Icons;

abstract class LayoutRoutes {
  static const homeLayout = AppRoute(
    path: '/home_layout',
    page: HomeLayout(),
    icon: Icons.home,
    name: 'Home',
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

  static const all = [home, myList, downloads, profile];
}
