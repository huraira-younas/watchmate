import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/services/shared_prefs.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/router/route_config.dart';
import 'package:watchmate_app/cubits/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

void main() async {
  await _initialize();
  runApp(BlocProvider(create: (_) => ThemeCubit(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appname,
          routerConfig: appRouter,
          theme: theme,
        );
      },
    );
  }
}

Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefs.instance.init();
  AppAssets.registerPreloads();
}
