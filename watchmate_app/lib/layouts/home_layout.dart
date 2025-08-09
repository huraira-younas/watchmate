import 'package:watchmate_app/common/services/socket_service/socket_service.dart';
import 'package:watchmate_app/common/widgets/dialog_boxs.dart' show errorDialogue;
import 'package:watchmate_app/common/widgets/loading/loading_screen.dart';
import 'package:watchmate_app/common/widgets/custom_bottom_nav_bar.dart';
import 'package:watchmate_app/common/cubits/navigation_cubit.dart';
import 'package:watchmate_app/router/routes/app_route_model.dart';
import 'package:watchmate_app/common/widgets/custom_appbar.dart';
import 'package:watchmate_app/features/auth/bloc/states.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/router/routes/exports.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/extensions/exports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  final _socketService = getIt<SocketNamespaceService>();
  final _navigator = getIt<NavigationCubit>();
  final _loader = LoadingScreen.instance();
  final _authBloc = getIt<AuthBloc>();

  final _screens = LayoutRoutes.all;
  final _pageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _socketService.connect(
      query: {"userId": _authBloc.user?.id},
      type: NamespaceType.auth,
    );
    _socketService.connect(
      query: {"userId": _authBloc.user?.id},
      type: NamespaceType.stream,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      bottomNavigationBar: const CustomBottomNavBar(),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          _loader.hide();

          final loading = state.loading;
          final error = state.error;

          if (error != null) {
            errorDialogue(
              message: error.message,
              title: error.title,
              context: context,
            );
          } else if (loading != null) {
            _loader.show(
              text: loading.message,
              title: loading.title,
              context: context,
            );
          } else if (state.user == null) {
            context.go(AuthRoutes.login.path);
          }
        },
        child: PageView.builder(
          physics: const NeverScrollableScrollPhysics(),
          controller: _navigator.controller,
          itemCount: _screens.length,
          key: _pageKey,
          itemBuilder: (_, idx) {
            final screen = _screens[idx];
            return PopScope(
              canPop: _navigator.currentIndex == 0,
              onPopInvokedWithResult: (_, _) {
                if (_navigator.currentIndex == 0) return;
                _navigator.navigateTo(0);
              },
              child: Column(
                children: <Widget>[
                  _getAppBar(theme, screen),
                  screen.page!.fadeIn(duration: 500.millis).expanded(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  AppBar _getAppBar(ThemeData theme, AppRoute navItem) {
    final isHome = navItem.name == "Home";

    return customAppBar(
      leadingIcon: Image.asset(AppAssets.icons.appIcon, height: 40)
          .hero(isHome ? LayoutRoutes.homeLayout.name : navItem.name)
          .padOnly(l: 10),
      title: navItem.name,
      centerTitle: false,
      context: context,
      actions: [
        IconButton(
          onPressed: () => context.push(StreamRoutes.stream.path),
          icon: Icon(
            color: theme.colorScheme.primary,
            StreamRoutes.stream.icon,
            size: 26,
          ),
        ),
        8.w,
      ],
    );
  }

  @override
  void deactivate() {
    _navigator.navigateTo(0);
    super.deactivate();
  }
}
