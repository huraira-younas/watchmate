import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/features/profile/views/widgets/user_tile.dart';
import 'package:watchmate_app/features/profile/views/widgets/my_tile.dart';
import 'package:watchmate_app/common/cubits/theme_cubit.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/router/routes/exports.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _socket = getIt<SocketNamespaceService>();
  final _authBloc = getIt<AuthBloc>();

  void _logout() => _authBloc.add(AuthLogout(onSuccess: _dispose));
  void _dispose() {
    _socket.disposeAll();
    context.go(AuthRoutes.login.path);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            10.h,
            const UserTile(),
            30.h,
            MyTile(
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () => context.push(
                AuthRoutes.editProfile.path,
                extra: _authBloc.user,
              ),
            ),
            MyTile(
              icon: isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
              onTap: () => getIt<ThemeCubit>().toggleTheme(),
              title: "Toggle Theme",
            ),
            MyTile(
              icon: Icons.logout_rounded,
              iconColor: Colors.red,
              title: "Logout",
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
