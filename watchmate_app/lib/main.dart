import 'package:watchmate_app/features/stream/bloc/upload_bloc/bloc.dart';
import 'package:watchmate_app/features/stream/bloc/link_bloc/bloc.dart';
import 'package:watchmate_app/common/cubits/navigation_cubit.dart';
import 'package:watchmate_app/common/widgets/app_snackbar.dart';
import 'package:watchmate_app/features/my_list/bloc/bloc.dart';
import 'package:watchmate_app/common/cubits/theme_cubit.dart';
import 'package:watchmate_app/common/cubits/video_cubit.dart';
import 'package:watchmate_app/constants/app_constants.dart';
import 'package:watchmate_app/features/auth/bloc/bloc.dart';
import 'package:watchmate_app/constants/app_assets.dart';
import 'package:watchmate_app/router/route_config.dart';
import 'package:watchmate_app/utils/shared_prefs.dart';
import 'package:watchmate_app/utils/pre_loader.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:watchmate_app/di/locator.dart';
import 'package:flutter/material.dart';

void main() async {
  await _initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<NavigationCubit>()),
        BlocProvider(create: (_) => getIt<UploaderBloc>()),
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
        BlocProvider(create: (_) => getIt<VideoCubit>()),
        BlocProvider(create: (_) => getIt<ListBloc>()),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
        BlocProvider(create: (_) => getIt<LinkBloc>()),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    Preloader.preloadGlobal(context);

    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        return MaterialApp.router(
          scaffoldMessengerKey: scaffoldKey,
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

  setupLocator();

  await Future.wait([
    dotenv.load(fileName: ".env"),
    SharedPrefs.instance.init(),
  ]);
  AppAssets.registerPreloads();
}
